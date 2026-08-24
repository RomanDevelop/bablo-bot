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
  static const daily = '/daily';

  static String dailyArticle(String id) => '$daily/$id';

  static String? dailyArticleId(String? name) {
    if (name == null || name.isEmpty) return null;
    final path = Uri.tryParse(name)?.path ?? name;
    const prefix = '$daily/';
    if (!path.startsWith(prefix)) return null;
    final id = path.substring(prefix.length).split('/').first;
    return id.isEmpty ? null : id;
  }
}
