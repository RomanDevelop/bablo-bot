class AppRoutes {
  AppRoutes._();

  static const home = '/';
  static const partner = '/partner';
  static const stats = '/stats';
  static const subscriptions = '/subscriptions';
  static const usStocks = '/us-stocks';
  static const chart = '/chart';
  static const portfolio = '/portfolio';
  static const trades = '/trades';
  static const settings = '/settings';
  static const aiAssistant = '/ai';
  static const search = '/search';
  static const about = '/about';
  static const documents = '/documents';
  static const help = '/help';
  static const courses = '/courses';
  static const courseAlexanderL = '/courses/alexander-l';
  static const courseAntonTheFed = '/courses/anton-the-fed';
  static const courseIrenTheOracle = '/courses/iren-the-oracle';
  static const daily = '/daily';
  static const temki = '/temki';
  static const exchange = '/exchange';

  static String dailyArticle(String id) => '$daily/$id';

  static String courseMentor(String id) => '$courses/$id';

  static String temkiItem(String id) => '$temki/$id';

  /// Path only: strips scheme/host/query/`/` tail so web deep links match.
  static String pathOf(String? name) {
    if (name == null || name.isEmpty) return home;
    final raw = name.split('#').first.split('?').first.trim();
    if (raw.isEmpty) return home;
    final uri = Uri.tryParse(raw);
    var path = raw.startsWith('/')
        ? raw
        : (uri != null && uri.path.isNotEmpty ? uri.path : '/$raw');
    if (uri != null && uri.hasScheme && uri.path.isNotEmpty) {
      path = uri.path;
    }
    if (!path.startsWith('/')) path = '/$path';
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    return path;
  }

  static String? dailyArticleId(String? name) {
    final path = pathOf(name);
    const prefix = '$daily/';
    if (!path.startsWith(prefix)) return null;
    final id = path.substring(prefix.length).split('/').first;
    return id.isEmpty ? null : id;
  }

  static String? mentorCourseId(String? name) {
    final path = pathOf(name);
    const prefix = '$courses/';
    if (!path.startsWith(prefix)) return null;
    final id = path.substring(prefix.length).split('/').first;
    return id.isEmpty ? null : id;
  }

  static String? temkiItemId(String? name) {
    final path = pathOf(name);
    const prefix = '$temki/';
    if (!path.startsWith(prefix)) return null;
    final id = path.substring(prefix.length).split('/').first;
    return id.isEmpty ? null : id;
  }
}
