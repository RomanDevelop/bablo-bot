/// Bablo Community Help — corporate tone with brand sarcasm.
class HelpConstants {
  HelpConstants._();

  static const title = 'HELP';
  static const subtitle = 'Центр финансовой взаимопомощи';
  static const hook =
      'У вас проблемы? У нас тоже. Но вместе они выглядят солиднее.';

  static const welcome =
      'Добро пожаловать в службу поддержки Bablo Community. Здесь мы '
      'помогаем участникам разобраться с приложением, найти нужную '
      'информацию и, самое главное, понять, как помочь нам заработать '
      'ещё больше.';

  /// title, body, emoji/icon key, action id
  static const cards = <HelpCardData>[
    HelpCardData(
      id: 'earn',
      emoji: '💰',
      title: 'Помогите нам заработать',
      body:
          'Самый быстрый способ решить практически любую нашу проблему.',
    ),
    HelpCardData(
      id: 'temka',
      emoji: '🤝',
      title: 'Предложить темку-мутку',
      body:
          'Есть идея, сделка или гениальный план? Тащите сюда. '
          'Сначала посмеёмся, потом посчитаем.',
    ),
    HelpCardData(
      id: 'lost',
      emoji: '📉',
      title: 'Я потерял бабло',
      body:
          'Сочувствуем. Возможно, рынок был сегодня не в настроении.',
    ),
    HelpCardData(
      id: 'won',
      emoji: '📈',
      title: 'Я заработал бабло',
      body:
          'Прекрасно. Теперь главное — не начать считать себя '
          'Уорреном Баффетом.',
    ),
    HelpCardData(
      id: 'ai',
      emoji: '🧠',
      title: 'Спросить у AI',
      body:
          'Если никто не знает ответа, AI хотя бы сформулирует '
          'незнание профессионально.',
    ),
    HelpCardData(
      id: 'urgent',
      emoji: '🆘',
      title: 'Реально нужна помощь',
      body:
          'Для редких случаев, когда произошло что-то серьёзнее '
          'падения биткоина на 2%.',
    ),
  ];

  static const ctaTitle = 'SUPPORT BABLO COMMUNITY';
  static const ctaEmoji = '💸';
  static const ctaHint =
      'Помогите нам стать богаче. Мы постараемся не забыть, '
      'благодаря кому это произошло.';

  static const dept = 'Bablo Community Support Department';
  static const motto = 'We solve problems. Occasionally even yours.';
}

class HelpCardData {
  const HelpCardData({
    required this.id,
    required this.emoji,
    required this.title,
    required this.body,
  });

  final String id;
  final String emoji;
  final String title;
  final String body;
}
