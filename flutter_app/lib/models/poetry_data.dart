/// Data models for the poetry app.

class PoetryData {
  final List<Dynasty> dynasties;

  PoetryData({required this.dynasties});

  factory PoetryData.fromJson(Map<String, dynamic> json) {
    return PoetryData(
      dynasties: (json['dynasties'] as List)
          .map((d) => Dynasty.fromJson(d))
          .toList(),
    );
  }
}

class Dynasty {
  final String name;
  final List<Poet> poets;

  Dynasty({required this.name, required this.poets});

  int get poemCount => poets.fold(0, (sum, p) => sum + p.poems.length);

  factory Dynasty.fromJson(Map<String, dynamic> json) {
    return Dynasty(
      name: json['name'] as String,
      poets: (json['poets'] as List).map((p) => Poet.fromJson(p)).toList(),
    );
  }
}

class Poet {
  final String name;
  final String birth;
  final String death;
  final String bio;
  final List<Poem> poems;
  // Set at load time for search convenience
  String dynastyName = '';

  Poet({
    required this.name,
    required this.birth,
    required this.death,
    required this.bio,
    required this.poems,
  });

  factory Poet.fromJson(Map<String, dynamic> json) {
    return Poet(
      name: json['name'] as String,
      birth: (json['birth'] ?? '') as String,
      death: (json['death'] ?? '') as String,
      bio: (json['bio'] ?? '') as String,
      poems: (json['poems'] as List).map((p) => Poem.fromJson(p)).toList(),
    );
  }
}

class Poem {
  final String title;
  final String form;
  final String tags;
  final String content;
  // Set at load time
  String poetName = '';
  String dynastyName = '';

  Poem({
    required this.title,
    required this.form,
    required this.tags,
    required this.content,
  });

  factory Poem.fromJson(Map<String, dynamic> json) {
    return Poem(
      title: json['title'] as String,
      form: (json['form'] ?? '') as String,
      tags: (json['tags'] ?? '') as String,
      content: json['content'] as String,
    );
  }
}
