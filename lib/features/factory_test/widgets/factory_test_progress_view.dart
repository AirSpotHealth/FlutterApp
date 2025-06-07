import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:flutter/material.dart';

class FactoryTestProgressView extends StatelessWidget {
  final FactoryTestPhase phase;
  final FactoryTestConnectionState connectionState;

  const FactoryTestProgressView({
    super.key,
    required this.phase,
    required this.connectionState,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            const SizedBox(height: 32),
            Text(
              _getPhaseTitle(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _getPhaseDescription(),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildProgressSteps(),
          ],
        ),
      ),
    );
  }

  String _getPhaseTitle() {
    switch (phase) {
      case FactoryTestPhase.connecting:
        return 'Connecting to Device';
      case FactoryTestPhase.enteringFactoryMode:
        return 'Entering Factory Mode';
      case FactoryTestPhase.reconnecting:
        return 'Reconnecting to Device';
      default:
        return 'Processing...';
    }
  }

  String _getPhaseDescription() {
    switch (phase) {
      case FactoryTestPhase.connecting:
        return 'Establishing Bluetooth connection with the selected device...';
      case FactoryTestPhase.enteringFactoryMode:
        return 'Sending factory mode command. Device will restart in factory mode...';
      case FactoryTestPhase.reconnecting:
        return 'Device has restarted in factory mode. Reconnecting...';
      default:
        return 'Please wait while the operation completes...';
    }
  }

  Widget _buildProgressSteps() {
    final steps = [
      _ProgressStep(
        title: 'Connect to Device',
        isCompleted: _isStepCompleted(0),
        isActive: _isStepActive(0),
      ),
      _ProgressStep(
        title: 'Enter Factory Mode',
        isCompleted: _isStepCompleted(1),
        isActive: _isStepActive(1),
      ),
      _ProgressStep(
        title: 'Device Restart',
        isCompleted: _isStepCompleted(2),
        isActive: _isStepActive(2),
      ),
      _ProgressStep(
        title: 'Reconnect',
        isCompleted: _isStepCompleted(3),
        isActive: _isStepActive(3),
      ),
    ];

    return Column(
      children: steps.map((step) => _buildStepWidget(step)).toList(),
    );
  }

  bool _isStepCompleted(int stepIndex) {
    switch (stepIndex) {
      case 0: // Connect to Device
        return connectionState != FactoryTestConnectionState.connecting;
      case 1: // Enter Factory Mode
        return phase != FactoryTestPhase.connecting &&
            phase != FactoryTestPhase.enteringFactoryMode;
      case 2: // Device Restart
        return connectionState == FactoryTestConnectionState.reconnecting ||
            connectionState == FactoryTestConnectionState.factoryModeReady;
      case 3: // Reconnect
        return connectionState == FactoryTestConnectionState.factoryModeReady;
      default:
        return false;
    }
  }

  bool _isStepActive(int stepIndex) {
    switch (stepIndex) {
      case 0: // Connect to Device
        return connectionState == FactoryTestConnectionState.connecting;
      case 1: // Enter Factory Mode
        return connectionState ==
            FactoryTestConnectionState.enteringFactoryMode;
      case 2: // Device Restart
        return connectionState == FactoryTestConnectionState.deviceRestarting;
      case 3: // Reconnect
        return connectionState == FactoryTestConnectionState.reconnecting;
      default:
        return false;
    }
  }

  Widget _buildStepWidget(_ProgressStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: step.isCompleted
                  ? Colors.green
                  : step.isActive
                      ? Colors.orange
                      : Colors.grey.shade300,
            ),
            child: step.isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : step.isActive
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              step.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: step.isActive ? FontWeight.bold : FontWeight.normal,
                color: step.isCompleted
                    ? Colors.green
                    : step.isActive
                        ? Colors.orange
                        : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressStep {
  final String title;
  final bool isCompleted;
  final bool isActive;

  _ProgressStep({
    required this.title,
    required this.isCompleted,
    required this.isActive,
  });
}
