import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/poetry_data.dart';

class PoetryService {
  static PoetryService? _instance;
  PoetryData? _data;
  List<Poem>? _allPoems;
  List<Poet>? _allPoets;

  PoetryService._();

  static PoetryService get instance {
    _instance ??= PoetryService._();
    return _instance!;
  }

  Future<PoetryData> loadData() async {
    if (_data != null) return _data!;

    final jsonStr = await rootBundle.loadString('assets/data/poems.json');
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _data = PoetryData.fromJson(json);

    // Set back-references for search
    for (final dynasty in _data!.dynasties) {
      for (final poet in dynasty.poets) {
        poet.dynastyName = dynasty.name;
        for (final poem in poet.poems) {
          poem.poetName = poet.name;
          poem.dynastyName = dynasty.name;
        }
      }
    }

    return _data!;
  }

  List<Dynasty> get dynasties => _data?.dynasties ?? [];

  List<Poet> get allPoets {
    if (_allPoets != null) return _allPoets!;
    _allPoets = [];
    for (final d in dynasties) {
      _allPoets!.addAll(d.poets);
    }
    return _allPoets!;
  }

  List<Poem> get allPoems {
    if (_allPoems != null) return _allPoems!;
    _allPoems = [];
    for (final poet in allPoets) {
      _allPoems!.addAll(poet.poems);
    }
    return _allPoems!;
  }

  /// Search poems by title, content, poet name, or dynasty.
  /// Returns up to [limit] results.
  List<SearchResult> search(String query, {int limit = 50}) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    final results = <SearchResult>[];

    // Search poets first
    for (final poet in allPoets) {
      if (poet.name.toLowerCase().contains(q)) {
        results.add(SearchResult(
          type: SearchResultType.poet,
          poet: poet,
          matchField: '诗人',
        ));
        if (results.length >= limit) return results;
      }
    }

    // Search poems by title
    for (final poem in allPoems) {
      if (poem.title.toLowerCase().contains(q)) {
        results.add(SearchResult(
          type: SearchResultType.poem,
          poem: poem,
          matchField: '标题',
        ));
        if (results.length >= limit) return results;
      }
    }

    // Search poems by content
    for (final poem in allPoems) {
      if (poem.content.toLowerCase().contains(q)) {
        // Avoid duplicates from title match
        if (!results.any((r) =>
            r.type == SearchResultType.poem &&
            r.poem?.title == poem.title &&
            r.poem?.poetName == poem.poetName)) {
          results.add(SearchResult(
            type: SearchResultType.poem,
            poem: poem,
            matchField: '内容',
          ));
          if (results.length >= limit) return results;
        }
      }
    }

    return results;
  }
}

enum SearchResultType { poet, poem }

class SearchResult {
  final SearchResultType type;
  final Poet? poet;
  final Poem? poem;
  final String matchField;

  SearchResult({
    required this.type,
    this.poet,
    this.poem,
    required this.matchField,
  });
}
