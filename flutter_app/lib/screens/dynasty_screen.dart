import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/poetry_data.dart';
import 'poet_screen.dart';

class DynastyScreen extends StatefulWidget {
  final Dynasty dynasty;

  const DynastyScreen({super.key, required this.dynasty});

  @override
  State<DynastyScreen> createState() => _DynastyScreenState();
}

class _DynastyScreenState extends State<DynastyScreen> {
  String _sortBy = 'name'; // 'name' or 'poems'

  @override
  Widget build(BuildContext context) {
    final poets = List<Poet>.from(widget.dynasty.poets);
    if (_sortBy == 'poems') {
      poets.sort((a, b) => b.poems.length.compareTo(a.poems.length));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dynasty.name),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'name', child: Text('按姓名排序')),
              PopupMenuItem(value: 'poems', child: Text('按作品数排序')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withOpacity(0.05),
            child: Text(
              '共 ${poets.length} 位诗人，${widget.dynasty.poemCount} 首诗词',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: poets.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (context, index) {
                final poet = poets[index];
                return ListTile(
                  title: Text(
                    poet.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${poet.poems.length} 首',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PoetScreen(poet: poet),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
