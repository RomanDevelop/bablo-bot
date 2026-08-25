import '../navigation/app_routes.dart';

/// Bablo Community courses & mentors.
class CoursesConstants {
  CoursesConstants._();

  static const title = 'COURSES';
  static const subtitle = 'Обучение от людей, которые уже что-то видели';
  static const intro =
      'Менторинг Bablo Community — не про «гарантированный доход». '
      'Про навыки, практику и меньше глупых ошибок на старте.';

  static const telegramHandle = 'romanklia';
  static const enrollButtonLabel = 'ЗАПИСАТЬСЯ НА КУРС';

  static Uri enrollUri(String courseName) {
    return Uri.https('t.me', telegramHandle, {
      'text': 'Привет! Хочу записаться на курс $courseName',
    });
  }

  static String heroTag(String id) => 'course-hero-$id';

  static const mentors = <CourseMentor>[
    CourseMentor(
      id: 'alexander-l',
      name: 'Alexander L.',
      shortRole: 'Chief Crypto Guru',
      route: AppRoutes.courseAlexanderL,
      photoAsset: 'assets/branding/alexander_l_hero.png',
      priceUsd: 1250,
    ),
    CourseMentor(
      id: 'anton-the-fed',
      name: 'Anton "THE FED"',
      shortRole: 'Crypto Launch & Tokenomics',
      route: AppRoutes.courseAntonTheFed,
      photoAsset: 'assets/branding/anton_the_fed_hero.png',
      priceUsd: 1500,
    ),
    CourseMentor(
      id: 'iren-the-oracle',
      name: 'Iren "THE ORACLE"',
      shortRole: 'Financial Tarot Guru',
      route: AppRoutes.courseIrenTheOracle,
      photoAsset: 'assets/branding/iren_the_oracle_hero.png',
      priceUsd: 1300,
    ),
  ];
}

class MentorCourseContent {
  const MentorCourseContent({
    required this.id,
    required this.name,
    required this.role,
    required this.photoAsset,
    required this.priceUsd,
    required this.bio,
    required this.program,
    required this.format,
    required this.quote,
    required this.signature,
    this.priceSubtitle = 'полный курс · менторинг · разборы',
    this.enrollButtonLabel,
    this.disclaimer,
  });

  final String id;
  final String name;
  final String role;
  final String photoAsset;
  final int priceUsd;
  final String bio;
  final List<(String, String)> program;
  final String format;
  final String quote;
  final String signature;
  final String priceSubtitle;
  final String? enrollButtonLabel;
  final String? disclaimer;

  String get ctaLabel =>
      enrollButtonLabel ?? CoursesConstants.enrollButtonLabel;
}

class MentorCourses {
  MentorCourses._();

  static MentorCourseContent? byId(String id) {
    return switch (id) {
      'alexander-l' => alexanderL,
      'anton-the-fed' => antonTheFed,
      'iren-the-oracle' => irenTheOracle,
      _ => null,
    };
  }

  static const alexanderL = MentorCourseContent(
    id: 'alexander-l',
    name: 'Alexander L.',
    role: 'Chief Crypto Guru & Head of Mentoring 😈',
    photoAsset: 'assets/branding/alexander_l_hero.png',
    priceUsd: 1250,
    bio:
        'Главный гуру Bablo Community по обучению, менторингу и превращению '
        'обычных людей в подозрительно подкованных темщиков.',
    program: [
      ('💰', 'Crypto & Trading — от базы до собственных стратегий'),
      ('📊', 'Разбор рынка, сделок и торгового бота'),
      ('🪙', 'Web3, DeFi, Polygon и Reserve (RSV)'),
      ('🤖', 'AI, автоматизация и инструменты темщика'),
      ('💻', 'Основы программирования и создание своих проектов'),
      ('🛡️', 'Cybersecurity — как понимать риски и защищать свои системы'),
      ('🧠', 'Разбор идей, ошибок и реальных кейсов'),
    ],
    format:
        'Формат: обучение → практика → эксперимент → разбор → повторить, '
        'пока не начало работать.',
    quote:
        '«Я не обещаю научить тебя делать миллионы.\n'
        'Сначала научись хотя бы не проёбывать свои.» 😎',
    signature: 'Alexander L. — GURU. MENTOR. TEMSHCHIK.',
  );

  static const antonTheFed = MentorCourseContent(
    id: 'anton-the-fed',
    name: 'Anton "THE FED"',
    role: 'Crypto Launch Architect & Token Engineer 😈',
    photoAsset: 'assets/branding/anton_the_fed_hero.png',
    priceUsd: 1500,
    bio:
        'Курс для тех, кто хочет пройти путь от идеи до работающего '
        'crypto-продукта: выбрать сеть, собрать токен, запустить проект '
        'и понять, как устроена капитализация в Web3.',
    program: [
      (
        '🏢',
        'Product & Go-to-Market — упаковка идеи, ценность токена, '
        'roadmap и что показывать инвестору',
      ),
      (
        '⛓️',
        'Blockchain & инфраструктура — Polygon, Ethereum, L2: '
        'критерии выбора сети под задачу',
      ),
      (
        '🪙',
        'Token design — тип токена, supply, utility, allocation, '
        'vesting и базовая токеномика',
      ),
      (
        '📜',
        'Smart contracts & deploy — mint, treasury, контракты, '
        'тестнет и вывод в mainnet',
      ),
      (
        '🚀',
        'Crypto launch — ликвидность, листинг, таймлайн запуска, '
        'комьюнити и первые 72 часа',
      ),
      (
        '📈',
        'Капитализация & fundraising — раунды, механики привлечения, '
        'FDV, ликвидность и метрики роста',
      ),
      (
        '🛡️',
        'Risk & post-launch — legal basics, типовые ошибки, '
        'безопасность и поддержка после старта',
      ),
    ],
    format:
        'Формат: концепт → chain → token → deploy → launch → '
        'капитализация → разбор кейсов и ошибок на каждом этапе.',
    quote:
        '«Токен без модели — это просто красивая кнопка Mint.\n'
        'Сначала архитектура, потом печать.» 😈',
    signature: 'ANTON "THE FED" — LAUNCH. TOKEN. ENGINEERING.',
    priceSubtitle: 'launch · tokenomics · капитализация',
  );

  static const irenTheOracle = MentorCourseContent(
    id: 'iren-the-oracle',
    name: 'Iren "THE ORACLE"',
    role: 'Chief Financial Tarot Guru 🔮',
    photoAsset: 'assets/branding/iren_the_oracle_hero.png',
    priceUsd: 1300,
    bio:
        'FINANCIAL TAROT & MONEY PSYCHOLOGY.\n'
        'Не курс о том, как карты сделают тебя миллионером. '
        'Это было бы слишком просто даже для Bablo Community.',
    program: [
      (
        '🔮',
        'Tarot for Money — карты в контексте денег, бизнеса и карьеры',
      ),
      (
        '🧠',
        'Money Psychology — страх, жадность, FOMO и финансовые установки',
      ),
      (
        '🪙',
        'Crypto Tarot — рынок и крипта через символический анализ',
      ),
      (
        '💼',
        'Business & Career — работа, проекты и принятие решений',
      ),
      (
        '🧱',
        'Money Blocks — отношения с деньгами и риском',
      ),
      (
        '🃏',
        'Практические расклады и реальные кейсы',
      ),
      (
        '✨',
        'Авторские методики The Oracle',
      ),
      (
        '💬',
        'Практика и консультационные сессии',
      ),
    ],
    format:
        'Формат: расклад → разбор психологии → решение → практика. '
        'Карты не торгуют за тебя. Они делают разговор с собой честнее.',
    quote:
        '«Cards don\'t make financial decisions. You do.\n'
        'Iren just makes the conversation with yourself much more interesting.»',
    signature: 'IREN "THE ORACLE" — CARDS. MONEY. PSYCHOLOGY.',
    priceSubtitle: 'full course · tarot · money psychology',
    enrollButtonLabel: 'ENTER THE ORACLE — \$1,300',
    disclaimer:
        'For educational and entertainment purposes. '
        'Tarot readings are not financial or investment advice.',
  );
}

class CourseMentor {
  const CourseMentor({
    required this.id,
    required this.name,
    required this.shortRole,
    required this.route,
    required this.photoAsset,
    required this.priceUsd,
  });

  final String id;
  final String name;
  final String shortRole;
  final String route;
  final String photoAsset;
  final int priceUsd;

  static CourseMentor? byId(String id) {
    for (final m in CoursesConstants.mentors) {
      if (m.id == id) return m;
    }
    return null;
  }
}
