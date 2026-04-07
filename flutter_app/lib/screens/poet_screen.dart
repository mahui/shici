import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/poetry_data.dart';
import 'poem_screen.dart';

class PoetScreen extends StatelessWidget {
  final Poet poet;

  const PoetScreen({super.key, required this.poet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(poet.name),
      ),
      body: ListView(
        children: [
          // Poet info card
          if (poet.bio.isNotEmpty || poet.birth.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 20, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        poet.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      if (poet.dynastyName.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            poet.dynastyName,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (poet.bio.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      poet.bio,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          // Poems list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '作品 (${poet.poems.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...poet.poems.map((poem) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(
                    poem.title,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  subtitle: poem.form.isNotEmpty && poem.form != '未知'
                      ? Text(
                          poem.form,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        )
                      : null,
                  trailing: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PoemScreen(poem: poem),
                      ),
                    );
                  },
                ),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
