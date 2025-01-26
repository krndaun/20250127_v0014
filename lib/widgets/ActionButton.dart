import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String currentButtonState;
  final bool isStartEnabled;
  final String disabledReason;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onComplete;

  const ActionButton({
    required this.currentButtonState,
    required this.isStartEnabled,
    required this.disabledReason,
    required this.onStart,
    required this.onPause,
    required this.onComplete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (currentButtonState == 'start') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: isStartEnabled ? onStart : null,
            child: Text('시작'),
          ),
          if (!isStartEnabled)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '비활성화 이유:\n$disabledReason',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      );
    } else if (currentButtonState == 'inProgress') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: onPause,
            child: Text('중단'),
          ),
          ElevatedButton(
            onPressed: onComplete,
            child: Text('완료'),
          ),
        ],
      );
    }
    return SizedBox.shrink();
  }
}