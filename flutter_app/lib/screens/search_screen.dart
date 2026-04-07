import 'dart:async';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/poetry_service.dart';
import '../models/poetry_data.dart';
import 'poet_screen.dart';
import 'poem_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _service = PoetryService.instance;
  List<SearchResult> _results = [];
  bool _searching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final results = _service.search(query);
      if (mounted) {
        setState(() {
          _results = results;
          _searching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: '搜索诗词、诗人...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            border: InputBorder.none,
          ),
          onChanged: _onQueryChanged,
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                _onQueryChanged('');
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              '输入关键词搜索诗词或诗人',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_searching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              '未找到相关结果',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => Divider(height: 1),
      itemBuilder: (context, index) {
        final result = _results[index];
        if (result.type == SearchResultType.poet) {
          return _buildPoetResult(result);
        } else {
          return _buildPoemResult(result);
        }
      },
    );
  }

  Widget _buildPoetResult(SearchResult result) {
    final poet = result.poet!;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        child: Icon(Icons.person, color: AppTheme.primaryColor),
      ),
      title: Text(
        poet.name,
        style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
      ),
      subtitle: Text(
        '${poet.dynastyName} · ${poet.poems.length} 首',
        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
      ),
      trailing: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PoetScreen(poet: poet)),
        );
      },
    );
  }

  Widget _buildPoemResult(SearchResult result) {
    final poem = result.poem!;
    // Show a preview of the content
    final preview = poem.content.replaceAll('\n', '  ');
    final displayPreview = preview.length > 50 ? '${preview.substring(0, 50)}...' : preview;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.accentColor.withOpacity(0.2),
        child: Icon(Icons.article, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        poem.title,
        style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${poem.dynastyName} · ${poem.poetName}',
            style: TextStyle(fontSize: 12, color: AppTheme.primaryColor),
          ),
          Text(
            displayPreview,
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PoemScreen(poem: poem)),
        );
      },
    );
  }
}
