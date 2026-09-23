import '../../../core/constants/daily_constants.dart';
import '../../../core/utils/json_parsers.dart';

class DailyReactions {
  const DailyReactions({
    this.dig = 0,
    this.shit = 0,
    this.askGuru = 0,
    this.askAi = 0,
  });

  final int dig;
  final int shit;
  final int askGuru;
  final int askAi;

  factory DailyReactions.fromJson(Map<String, dynamic> json) {
    return DailyReactions(
      dig: asInt(json['dig']),
      shit: asInt(json['shit']),
      askGuru: asInt(json['ask_guru']),
      askAi: asInt(json['ask_ai']),
    );
  }

  Map<String, dynamic> toJson() => {
        'dig': dig,
        'shit': shit,
        'ask_guru': askGuru,
        'ask_ai': askAi,
      };

  DailyReactions incremented(String type) {
    return DailyReactions(
      dig: dig + (type == DailyReactionType.dig ? 1 : 0),
      shit: shit + (type == DailyReactionType.shit ? 1 : 0),
      askGuru: askGuru + (type == DailyReactionType.askGuru ? 1 : 0),
      askAi: askAi + (type == DailyReactionType.askAi ? 1 : 0),
    );
  }
}

class DailyArticle {
  const DailyArticle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.categoryLabel,
    required this.summary,
    required this.babloVerdict,
    required this.sourceUrls,
    required this.author,
    required this.imageUrl,
    required this.imageCredit,
    required this.publishedAt,
    required this.status,
    required this.reactions,
    this.body,
  });

  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String categoryLabel;
  final String summary;
  final String? body;
  final String babloVerdict;
  final List<String> sourceUrls;
  final String author;
  final String imageUrl;
  final String imageCredit;
  final String publishedAt;
  final String status;
  final DailyReactions reactions;

  bool get hasBody => body != null && body!.trim().isNotEmpty;

  String get displayAuthor => DailyConstants.displayAuthor;

  factory DailyArticle.fromJson(Map<String, dynamic> json) {
    return DailyArticle(
      id: asString(json['id'], ''),
      title: asString(json['title'], ''),
      subtitle: asString(json['subtitle'], ''),
      category: asString(json['category'], ''),
      categoryLabel: asString(json['categoryLabel'], ''),
      summary: asString(json['summary'], ''),
      body: asNullableString(json['body']),
      babloVerdict: asString(json['babloVerdict'], ''),
      sourceUrls: asList(json['sourceUrls'])
          .map((e) => asString(e, ''))
          .where((e) => e.isNotEmpty)
          .toList(growable: false),
      author: asString(json['author'], DailyConstants.displayAuthor),
      imageUrl: asString(json['imageUrl'], ''),
      imageCredit: asString(json['imageCredit'], 'Unsplash'),
      publishedAt: asString(json['publishedAt'], ''),
      status: asString(json['status'], 'published'),
      reactions: DailyReactions.fromJson(asMap(json['reactions'])),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'category': category,
        'categoryLabel': categoryLabel,
        'summary': summary,
        'body': body,
        'babloVerdict': babloVerdict,
        'sourceUrls': sourceUrls,
        'author': author,
        'imageUrl': imageUrl,
        'imageCredit': imageCredit,
        'publishedAt': publishedAt,
        'status': status,
        'reactions': reactions.toJson(),
      };

  DailyArticle merge(DailyArticle other) {
    return DailyArticle(
      id: other.id,
      title: other.title,
      subtitle: other.subtitle,
      category: other.category,
      categoryLabel: other.categoryLabel,
      summary: other.summary,
      body: (other.body != null && other.body!.trim().isNotEmpty)
          ? other.body
          : body,
      babloVerdict: other.babloVerdict,
      sourceUrls: other.sourceUrls,
      author: other.author,
      imageUrl: other.imageUrl,
      imageCredit: other.imageCredit,
      publishedAt: other.publishedAt,
      status: other.status,
      reactions: other.reactions,
    );
  }

  DailyArticle copyWith({
    String? body,
    DailyReactions? reactions,
  }) {
    return DailyArticle(
      id: id,
      title: title,
      subtitle: subtitle,
      category: category,
      categoryLabel: categoryLabel,
      summary: summary,
      body: body ?? this.body,
      babloVerdict: babloVerdict,
      sourceUrls: sourceUrls,
      author: author,
      imageUrl: imageUrl,
      imageCredit: imageCredit,
      publishedAt: publishedAt,
      status: status,
      reactions: reactions ?? this.reactions,
    );
  }
}
