import 'package:flutter/material.dart';
import 'package:zenith_time/app/theme/app_theme.dart';

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 80, title: _buildActionToolbar()),
      body: Center(
        child: Text(
          'Lista e relatorios aqui',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildActionToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'What are you doing?',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 16),

          const Text(
            '00:00:00',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),

          IconButton(
            icon: const Icon(Icons.play_circle, size: 36),
            onPressed: () {},
            color: AppTheme.adwaitaBlue,
          ),
        ],
      ),
    );
  }
}
