import 'package:flutter/material.dart';

class LiveChatDemoPage extends StatelessWidget {
  const LiveChatDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Live Chat Demo',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(width: 24),
              SizedBox(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Your Gemini API Key',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SizedBox.expand(
              child: Row(
                children: [Expanded(child: SizedBox.expand(child: Card()))],
              ),
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
