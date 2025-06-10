import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:airspothealth/features/factory_test/widgets/automatic_tests_tab.dart';
import 'package:airspothealth/features/factory_test/widgets/device_selection_tab.dart';
import 'package:airspothealth/features/factory_test/widgets/manual_tests_tab.dart';
import 'package:airspothealth/features/factory_test/widgets/submit_results_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FactoryTestPage extends ConsumerStatefulWidget {
  const FactoryTestPage({super.key});

  @override
  ConsumerState<FactoryTestPage> createState() => _FactoryTestPageState();
}

class _FactoryTestPageState extends ConsumerState<FactoryTestPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pageController = PageController();

    // Auto-start scanning when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(factoryTestProvider.notifier).startScanning();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Check if any tests are currently in progress
  bool _isTestInProgress(FactoryTestState state) {
    // Check if automatic tests are running
    if (state.automaticTests.isRunning) return true;

    // Check if in connecting/factory mode setup phases
    if (state.phase == FactoryTestPhase.connecting ||
        state.phase == FactoryTestPhase.enteringFactoryMode ||
        state.phase == FactoryTestPhase.reconnecting ||
        state.phase == FactoryTestPhase.runningAutomaticTests ||
        state.phase == FactoryTestPhase.runningManualTests) {
      return true;
    }

    // Check if any manual tests have been started (not in notStarted state)
    if (state.manualTests.tests.any((test) =>
        test.status == TestStatus.running ||
        test.status == TestStatus.pass ||
        test.status == TestStatus.fail)) {
      return true;
    }

    return false;
  }

  /// Handle back navigation with confirmation if tests are in progress
  Future<bool> _handleBackNavigation() async {
    final factoryTestState = ref.read(factoryTestProvider);

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
              await ref.read(factoryTestProvider.notifier).endFactoryTestMode();
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
    final factoryTestState = ref.watch(factoryTestProvider);

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
            _buildHeader(factoryTestState),
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
                children: const [
                  DeviceSelectionTab(),
                  AutomaticTestsTab(),
                  ManualTestsTab(),
                  SubmitResultsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(FactoryTestState state) {
    String deviceName = 'Select Device';
    String? sensorInfo;

    if (state.selectedDeviceId != null) {
      final device = state.availableDevices
          .where((d) => d.deviceId == state.selectedDeviceId)
          .firstOrNull;
      if (device != null) {
        deviceName = device.name;
      }
    }

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
              if (state.phase != FactoryTestPhase.deviceSelection)
                IconButton(
                  onPressed: () => _showResetDialog(context, ref),
                  icon:
                      const Icon(Icons.refresh, color: AppColors.textOnPrimary),
                  tooltip: 'Reset Test',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabCards(FactoryTestState state) {
    return Container(
      color: AppColors.backgroundSecondary,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
              child: _buildStepperItem('Device\nSelection', 0, state,
                  isFirst: true)),
          _buildConnector(0, state),
          Expanded(child: _buildStepperItem('Automatic\nTests', 1, state)),
          _buildConnector(1, state),
          Expanded(child: _buildStepperItem('Manual\nTests', 2, state)),
          _buildConnector(2, state),
          Expanded(
              child:
                  _buildStepperItem('Submit\nResults', 3, state, isLast: true)),
        ],
      ),
    );
  }

  Widget _buildConnector(int fromIndex, FactoryTestState state) {
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

  Widget _buildStepperItem(String title, int index, FactoryTestState state,
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
    if (index == 1 && state.selectedDeviceId != null) {
      final completed = state.automaticTests.tests
          .where(
              (r) => r.status == TestStatus.pass || r.status == TestStatus.fail)
          .length;
      final total = state.automaticTests.tests.length;
      if (total > 0) subtitle = '$completed/$total';
    } else if (index == 2 && state.automaticTests.isComplete) {
      final completed = state.manualTests.tests
          .where(
              (r) => r.status == TestStatus.pass || r.status == TestStatus.fail)
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

  bool _isTabEnabled(int index, FactoryTestState state) {
    switch (index) {
      case 0: // Device Selection - always enabled to allow changing devices
        return true;
      case 1: // Auto Tests - enabled if device connected
        return state.selectedDeviceId != null;
      case 2: // Manual Tests - enabled if auto tests completed
        return state.automaticTests.isComplete;
      case 3: // Results - enabled if all tests completed
        return state.isTestingComplete;
      default:
        return false;
    }
  }

  bool _isTabCompleted(int index, FactoryTestState state) {
    switch (index) {
      case 0:
        return state.selectedDeviceId != null;
      case 1:
        return state.automaticTests.isComplete;
      case 2:
        return state.manualTests.isComplete;
      case 3:
        return state.isTestingComplete;
      default:
        return false;
    }
  }

  bool _isTabRunning(int index, FactoryTestState state) {
    switch (index) {
      case 0:
        return state.phase == FactoryTestPhase.connecting ||
            state.phase == FactoryTestPhase.enteringFactoryMode ||
            state.phase == FactoryTestPhase.reconnecting;
      case 1:
        return state.phase == FactoryTestPhase.runningAutomaticTests ||
            state.automaticTests.isRunning;
      case 2:
        return state.phase == FactoryTestPhase.runningManualTests;
      case 3:
        return false;
      default:
        return false;
    }
  }

  void _updateTabBasedOnProgress(FactoryTestState state) {
    int newIndex = _tabController.index;

    switch (state.phase) {
      case FactoryTestPhase.connecting:
      case FactoryTestPhase.enteringFactoryMode:
      case FactoryTestPhase.reconnecting:
      case FactoryTestPhase.runningAutomaticTests:
        newIndex = 1;
        break;
      case FactoryTestPhase.runningManualTests:
        newIndex = 2;
        break;
      case FactoryTestPhase.completed:
        newIndex = 3;
        break;
      case FactoryTestPhase.deviceSelection:
      case FactoryTestPhase.error:
        // Don't auto-change for these states
        break;
    }

    if (newIndex != _tabController.index && mounted) {
      _tabController.animateTo(newIndex);
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onTabTapped(int index, FactoryTestState state) {
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
      case 1:
        message = 'Please connect to a device first';
        break;
      case 2:
        message = 'Complete automatic tests first';
        break;
      case 3:
        message = 'Complete all tests first';
        break;
      default:
        message = 'Step not available yet';
    }

    context.showSnackBar(message);
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Reset Factory Test',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to reset the factory test? This will disconnect the device and start over.',
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(factoryTestProvider.notifier).resetFactoryTest();
              _tabController.animateTo(0);
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
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
              'Reset',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
