import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:airspothealth/features/factory_test/widgets/automatic_tests_tab.dart';
import 'package:airspothealth/features/factory_test/widgets/manual_tests_tab.dart';
import 'package:airspothealth/features/factory_test/widgets/submit_results_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceFactoryTestPage extends ConsumerStatefulWidget {
  const DeviceFactoryTestPage({
    super.key,
    required this.deviceId,
    this.showHeader = true,
  });

  final String deviceId;
  final bool showHeader;

  @override
  ConsumerState<DeviceFactoryTestPage> createState() => _FactoryTestPageState();
}

class _FactoryTestPageState extends ConsumerState<DeviceFactoryTestPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
  }

  @override
  void dispose() {
    // Clean up controllers
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Check if any tests are currently in progress
  bool _isTestInProgress(DeviceFactoryTestState state) {
    // Check if automatic tests are running
    if (state.automaticTests.isRunning) return true;

    // Check if in connecting/factory mode setup phases
    if (state.phase == DeviceFactoryTestPhase.connecting ||
        state.phase == DeviceFactoryTestPhase.enteringFactoryMode ||
        state.phase == DeviceFactoryTestPhase.reconnecting ||
        state.phase == DeviceFactoryTestPhase.runningAutomaticTests ||
        state.phase == DeviceFactoryTestPhase.runningManualTests) {
      return true;
    }

    // Check if any manual tests have been started (not in notStarted state)
    if (state.manualTests.tests.any((test) =>
        test.status == DeviceTestStatus.running ||
        test.status == DeviceTestStatus.pass ||
        test.status == DeviceTestStatus.fail)) {
      return true;
    }

    return false;
  }

  /// Handle back navigation with confirmation if tests are in progress
  Future<bool> _handleBackNavigation() async {
    final factoryTestState = ref.read(factoryTestProvider(widget.deviceId));

    if (_isTestInProgress(factoryTestState)) {
      return await _showExitConfirmationDialog() ?? false;
    }

    return true; // Allow navigation if no tests in progress
  }

  /// Show confirmation dialog when trying to exit during tests
  Future<bool?> _showExitConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: AppColors.brandColorRed,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Exit Factory Test?',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Tests are currently in progress. If you exit now:\n\n'
          '• All test data will be lost\n'
          '• The device will restart in normal mode\n'
          '• You will need to start the factory test process again\n\n'
          'Are you sure you want to continue?',
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Stay',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              // Send 0xDE command to end factory test mode and restart device in normal mode
              final notifier =
                  ref.read(factoryTestProvider(widget.deviceId).notifier);
              await notifier.endFactoryTestMode();
              notifier.dispose();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandColorRed,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Exit & Restart Device',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final factoryTestState = ref.watch(factoryTestProvider(widget.deviceId));

    // Auto-update tab based on test progress
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTabBasedOnProgress(factoryTestState);
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final navigator = Navigator.of(context);
        final shouldPop = await _handleBackNavigation();
        if (shouldPop && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundSecondary,
        body: Column(
          children: [
            if (widget.showHeader) _buildHeader(factoryTestState),
            // Only show status container during initial phases and errors
            if (_shouldShowStatusContainer(factoryTestState))
              _buildConnectionStatusContainer(factoryTestState),
            _buildTabCards(factoryTestState),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  if (_isTabEnabled(index, factoryTestState)) {
                    _tabController.animateTo(index);
                  } else {
                    // Don't allow swiping to disabled pages
                    _pageController.animateToPage(
                      _tabController.index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    _showTabRestrictedMessage(index);
                  }
                },
                children: [
                  AutomaticTestsTab(deviceId: widget.deviceId),
                  ManualTestsTab(deviceId: widget.deviceId),
                  SubmitResultsTab(deviceId: widget.deviceId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DeviceFactoryTestState state) {
    String deviceName = 'Select Device';
    String? sensorInfo;

    deviceName = state.selectedDevice.name;

    // Add sensor variant info if detected
    if (state.selectedDeviceVariant != null) {
      final sensorType = state.selectedDeviceVariant == 0 ? 'SCD40' : 'SCD41';
      sensorInfo = 'Sensor: $sensorType';
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final shouldPop = await _handleBackNavigation();
                  if (shouldPop && mounted) {
                    navigator.pop();
                  }
                },
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.textOnPrimary),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Factory Test',
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      deviceName,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    if (sensorInfo != null)
                      Text(
                        sensorInfo,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _shouldShowStatusContainer(DeviceFactoryTestState state) {
    switch (state.phase) {
      case DeviceFactoryTestPhase.connecting:
      case DeviceFactoryTestPhase.enteringFactoryMode:
      case DeviceFactoryTestPhase.reconnecting:
      case DeviceFactoryTestPhase.error:
        return true;
      case DeviceFactoryTestPhase.runningAutomaticTests:
      case DeviceFactoryTestPhase.runningManualTests:
      case DeviceFactoryTestPhase.completed:
        return false;
    }
  }

  Widget _buildConnectionStatusContainer(DeviceFactoryTestState state) {
    String statusText;
    IconData statusIcon;
    Color statusColor;
    bool showProgress = false;

    switch (state.phase) {
      case DeviceFactoryTestPhase.connecting:
        statusText = 'Connecting to device...';
        statusIcon = Icons.bluetooth_searching;
        statusColor = AppColors.primaryColor;
        showProgress = true;
        break;
      case DeviceFactoryTestPhase.enteringFactoryMode:
        statusText = 'Entering factory mode...';
        statusIcon = Icons.settings;
        statusColor = AppColors.primaryColor;
        showProgress = true;
        break;
      case DeviceFactoryTestPhase.reconnecting:
        statusText = 'Device restarting, waiting for reconnection...';
        statusIcon = Icons.restart_alt;
        statusColor = AppColors.primaryColor;
        showProgress = true;
        break;
      case DeviceFactoryTestPhase.runningAutomaticTests:
        statusText = 'Running automatic tests...';
        statusIcon = Icons.science;
        statusColor = AppColors.primaryColor;
        showProgress = true;
        break;
      case DeviceFactoryTestPhase.runningManualTests:
        statusText = 'Manual tests in progress';
        statusIcon = Icons.touch_app;
        statusColor = AppColors.primaryColor;
        break;
      case DeviceFactoryTestPhase.completed:
        statusText = 'All tests completed successfully';
        statusIcon = Icons.check_circle;
        statusColor = AppColors.brandColorGreen;
        break;
      case DeviceFactoryTestPhase.error:
        statusText = state.error ?? 'Unknown error occurred';
        statusIcon = Icons.error;
        statusColor = AppColors.brandColorRed;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: state.phase == DeviceFactoryTestPhase.connecting ||
              state.phase == DeviceFactoryTestPhase.enteringFactoryMode ||
              state.phase == DeviceFactoryTestPhase.reconnecting ||
              state.phase == DeviceFactoryTestPhase.error
          ? 56
          : 48,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (showProgress) ...[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: statusColor,
                ),
              ),
            ] else ...[
              Icon(
                statusIcon,
                color: statusColor,
                size: 16,
              ),
            ],
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                statusText,
                style: context.textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (state.phase == DeviceFactoryTestPhase.error) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.warning,
                color: statusColor,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabCards(DeviceFactoryTestState state) {
    return Container(
      color: AppColors.backgroundSecondary,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
              child: _buildStepperItem('Automatic\nTests', 0, state,
                  isFirst: true)),
          _buildConnector(0, state),
          Expanded(child: _buildStepperItem('Manual\nTests', 1, state)),
          _buildConnector(1, state),
          Expanded(
              child:
                  _buildStepperItem('Submit\nResults', 2, state, isLast: true)),
        ],
      ),
    );
  }

  Widget _buildConnector(int fromIndex, DeviceFactoryTestState state) {
    final isCompleted = _isTabCompleted(fromIndex, state);
    return Container(
      height: 2,
      width: 20,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color:
            isCompleted ? AppColors.brandColorGreen : AppColors.borderSecondary,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildStepperItem(
      String title, int index, DeviceFactoryTestState state,
      {bool isFirst = false, bool isLast = false}) {
    final isActive = _tabController.index == index;
    final isEnabled = _isTabEnabled(index, state);
    final isCompleted = _isTabCompleted(index, state);
    final isRunning = _isTabRunning(index, state);

    Color circleColor;
    Color textColor;
    Widget centerWidget;

    if (isCompleted) {
      circleColor = AppColors.brandColorGreen;
      textColor = AppColors.brandColorGreen;
      centerWidget =
          const Icon(Icons.check, color: AppColors.textOnPrimary, size: 16);
    } else if (isRunning) {
      circleColor = AppColors.primaryColor;
      textColor = AppColors.primaryColor;
      centerWidget = SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.textOnPrimary,
        ),
      );
    } else if (isActive && isEnabled) {
      circleColor = AppColors.primaryColor;
      textColor = AppColors.primaryColor;
      centerWidget = Text(
        '${index + 1}',
        style: const TextStyle(
          color: AppColors.textOnPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      );
    } else if (isEnabled) {
      circleColor = AppColors.backgroundPrimary;
      textColor = AppColors.textPrimary;
      centerWidget = Text(
        '${index + 1}',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      );
    } else {
      circleColor = AppColors.backgroundTertiary;
      textColor = AppColors.textDisabled;
      centerWidget = Text(
        '${index + 1}',
        style: TextStyle(
          color: AppColors.textDisabled,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      );
    }

    // Add progress subtitle for tests
    String subtitle = '';
    if (index == 0) {
      final completed = state.automaticTests.tests
          .where((r) =>
              r.status == DeviceTestStatus.pass ||
              r.status == DeviceTestStatus.fail)
          .length;
      final total = state.automaticTests.tests.length;
      if (total > 0) subtitle = '$completed/$total';
    } else if (index == 1 && state.automaticTests.isComplete) {
      final completed = state.manualTests.tests
          .where((r) =>
              r.status == DeviceTestStatus.pass ||
              r.status == DeviceTestStatus.fail)
          .length;
      final total = state.manualTests.tests.length;
      if (total > 0) subtitle = '$completed/$total';
    }

    return GestureDetector(
      onTap: isEnabled ? () => _onTabTapped(index, state) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circle with number/icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isEnabled ? circleColor : AppColors.borderSecondary,
                width: isActive && !isCompleted && !isRunning ? 2 : 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: circleColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(child: centerWidget),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: 11,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Optional subtitle for progress
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                subtitle,
                style: TextStyle(
                  color: textColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isTabEnabled(int index, DeviceFactoryTestState state) {
    switch (index) {
      case 0: // Auto Tests - enabled if device connected
        return true;
      case 1: // Manual Tests - enabled if auto tests completed
        return state.automaticTests.isComplete;
      case 2: // Results - enabled if all tests completed
        return state.isTestingComplete;
      default:
        return false;
    }
  }

  bool _isTabCompleted(int index, DeviceFactoryTestState state) {
    switch (index) {
      case 0:
        return state.automaticTests.isComplete;
      case 1:
        return state.manualTests.isComplete;
      case 2:
        return state.isTestingComplete;
      default:
        return false;
    }
  }

  bool _isTabRunning(int index, DeviceFactoryTestState state) {
    switch (index) {
      case 0:
        return state.phase == DeviceFactoryTestPhase.runningAutomaticTests ||
            state.automaticTests.isRunning;
      case 1:
        return state.phase == DeviceFactoryTestPhase.runningManualTests;
      case 2:
        return false;
      default:
        return false;
    }
  }

  void _updateTabBasedOnProgress(DeviceFactoryTestState state) {
    int newIndex = _tabController.index;

    debugPrint('_updateTabBasedOnProgress called with phase: ${state.phase}');
    debugPrint('Current tab index: ${_tabController.index}');

    switch (state.phase) {
      case DeviceFactoryTestPhase.connecting:
      case DeviceFactoryTestPhase.enteringFactoryMode:
      case DeviceFactoryTestPhase.reconnecting:
      case DeviceFactoryTestPhase.runningAutomaticTests:
        newIndex = 0;
        break;
      case DeviceFactoryTestPhase.runningManualTests:
        newIndex = 1;
        break;
      case DeviceFactoryTestPhase.completed:
        newIndex = 2;
        break;
      case DeviceFactoryTestPhase.error:
        // Don't auto-change for these states
        break;
    }

    debugPrint('Calculated new tab index: $newIndex');

    if (newIndex != _tabController.index && mounted) {
      debugPrint('Switching to tab $newIndex');
      _tabController.animateTo(newIndex);
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      debugPrint('No tab switch needed or widget not mounted');
    }
  }

  void _onTabTapped(int index, DeviceFactoryTestState state) {
    if (!_isTabEnabled(index, state)) {
      _showTabRestrictedMessage(index);
      return;
    }

    _tabController.animateTo(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showTabRestrictedMessage(int index) {
    String message;
    switch (index) {
      case 0:
        message = 'Automatic tests are ready to run';
        break;
      case 1:
        message = 'Complete automatic tests first';
        break;
      case 2:
        message = 'Complete all tests first';
        break;
      default:
        message = 'Step not available yet';
    }

    context.showSnackBar(message);
  }
}
