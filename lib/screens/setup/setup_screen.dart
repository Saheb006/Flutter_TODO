import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Required'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.settings,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              'Supabase Configuration Required',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'To use this app, you need to configure your Supabase credentials in the .env file.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _buildStepCard(
              context,
              '1',
              'Create a Supabase Project',
              'Go to https://supabase.com and create a new project',
            ),
            const SizedBox(height: 16),
            _buildStepCard(
              context,
              '2',
              'Get Your Credentials',
              'From your project dashboard, copy the URL and anon key from Settings > API',
            ),
            const SizedBox(height: 16),
            _buildStepCard(
              context,
              '3',
              'Update .env File',
              'Replace the placeholder values in the .env file with your actual credentials',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Example .env configuration:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () => _copyToClipboard(context),
                        tooltip: 'Copy to clipboard',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'SUPABASE_URL=https://your-project-ref.supabase.co\nSUPABASE_ANON_KEY=your-anon-key-here',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _restartApp(context),
                child: const Text('Restart App After Configuration'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, String step, String title, String description) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  step,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    const text = 'SUPABASE_URL=https://your-project-ref.supabase.co\nSUPABASE_ANON_KEY=your-anon-key-here';
    Clipboard.setData(const ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard!')),
    );
  }

  void _restartApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart Required'),
        content: const Text(
          'After updating your .env file with the correct Supabase credentials, please restart the app to apply the changes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}