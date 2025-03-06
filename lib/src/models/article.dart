class Article {
  final String id;
  final String title;
  final String description;
  final String content;
  final String url;
  final String imageUrl;
  final String source;
  final DateTime publishedAt;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
  });

 factory Article.fromJson(Map<String, dynamic> json) {
  return Article(
    id: json['id'] ?? json['url'] ?? '',
    title: json['title'] ?? 'No title',
    description: json['description'] ?? 'No description',
    content: json['content'] ?? 'No content',
    url: json['url'] ?? '',
    imageUrl: json['imageUrl'] ?? json['urlToImage'] ?? '',
    source: json['source'] is Map<String, dynamic> 
        ? json['source']['name'] ?? 'Unknown'
        : json['source'] ?? 'Unknown',
    publishedAt: json['publishedAt'] != null
        ? DateTime.tryParse(json['publishedAt']) ?? DateTime.now()
        : DateTime.now(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'imageUrl': imageUrl,
      'source': source,
      'publishedAt': publishedAt.toIso8601String(),
    };
  }

  Article copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? url,
    String? imageUrl,
    String? source,
    DateTime? publishedAt,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}

