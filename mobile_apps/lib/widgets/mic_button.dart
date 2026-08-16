import 'package:flutter/material.dart';

class MicButton extends StatelessWidget {
  final bool listening;
  final VoidCallback onTap;

  const MicButton({
    super.key,
    required this.listening,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 45,
        child: Icon(
          listening ? Icons.mic : Icons.mic_none,
          size: 42,
        ),
      ),
    );
  }
}
