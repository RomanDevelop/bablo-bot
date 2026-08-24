class DailyConstants {
  DailyConstants._();

  static const displayAuthor = 'Anton THE FED';
  static const webOrigin = 'https://bablo-bot.web.app';
  static const listLimit = 10;
  static const reactorIdKey = 'daily_reactor_id';

  static String shareUrl(String id) => '$webOrigin/daily/$id';

  static const categories = <({String id, String label})>[
    (id: '', label: 'Все'),
    (id: 'market', label: 'Markets'),
    (id: 'trading', label: 'Trading'),
    (id: 'web3', label: 'Web3'),
    (id: 'ai', label: 'AI'),
    (id: 'cyber', label: 'Cyber'),
    (id: 'scams', label: 'Scams'),
    (id: 'guru', label: 'Guru'),
    (id: 'fed', label: 'Fed'),
  ];
}

class DailyReactionType {
  DailyReactionType._();

  static const dig = 'dig';
  static const shit = 'shit';
  static const askGuru = 'ask_guru';
  static const askAi = 'ask_ai';
}
