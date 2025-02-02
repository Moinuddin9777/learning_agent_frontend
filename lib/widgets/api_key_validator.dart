import 'package:flutter/material.dart';
import 'package:learning_agent/main.dart';
import 'package:learning_agent/theme.dart';

class ApiKeyWidget extends StatelessWidget {
  ApiKeyWidget({required this.onSubmitted, super.key});

  final ValueChanged<String> onSubmitted;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'To generate learning paths, you\'ll need a Gemini API key.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: textFieldDecoration(context, 'Enter your API key'),
                    controller: _textController,
                    onSubmitted: onSubmitted,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => onSubmitted(_textController.text),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}