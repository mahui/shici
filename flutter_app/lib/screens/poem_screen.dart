import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_theme.dart';
import '../models/poetry_data.dart';

class PoemScreen extends StatefulWidget {
  final Poem poem;

  const PoemScreen({super.key, required this.poem});

  @override
  State<PoemScreen> createState() => _PoemScreenState();
}

class _PoemScreenState extends State<PoemScreen> {
  double _fontSize = 18.0;

  @override
  Widget build(BuildContext context) {
    final poem = widget.poem;

    return Scaffold(
      appBar: AppBar(
        title: Text(poem.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: '复制',
            onPressed: () {
              final text = '${poem.title}\n'
                  '${poem.poetName.isNotEmpty ? "${poem.dynastyName} · ${poem.poetName}\n\n" : "\n"}'
                  '${poem.content}';
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已复制到剪贴板'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Title
                  Text(
                    poem.title,
                    style: TextStyle(
                      fontSize: _fontSize + 6,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Author & Dynasty
                  if (poem.poetName.isNotEmpty)
                    Text(
                      poem.dynastyName.isNotEmpty
                          ? '〔${poem.dynastyName}〕${poem.poetName}'
                          : poem.poetName,
                      style: TextStyle(
                        fontSize: _fontSize - 2,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  // Form tag
                  if (poem.form.isNotEmpty && poem.form != '未知') ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        poem.form,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Divider
                  Container(
                    width: 40,
                    height: 2,
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(height: 24),
                  // Content
                  Text(
                    poem.content,
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: AppTheme.textPrimary,
                      height: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Font size controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppTheme.dividerColor),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.text_decrease, size: 16, color: AppTheme.textSecondary),
                Slider(
                  value: _fontSize,
                  min: 14,
                  max: 28,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (v) => setState(() => _fontSize = v),
                ),
                Icon(Icons.text_increase, size: 20, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
