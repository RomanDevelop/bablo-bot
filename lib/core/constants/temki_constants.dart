import '../navigation/app_routes.dart';

/// Temki-mutki marketplace — plots on planets & alien ship rentals, paid in RSV.
class TemkiConstants {
  TemkiConstants._();

  static const title = 'ТЕМКИ, МУТКИ';
  static const subtitle = 'Участки на планетах и аренда космолётов';
  static const intro =
      'Закрытый отдел Bablo Community. Продаём сотки на Марсе, Луне и Сатурне '
      'и сдаём космолёты инопланетян — если они всё-таки прилетят. '
      'Оплата только в Reserve (RSV). Наличные, доллары и обещания не принимаем.';

  static const telegramHandle = 'romanklia';
  static const rsvTicker = 'RSV';
  static const rsvName = 'Reserve';
  static const rsvUsd = 0.13;

  static const plotsLabel = 'УЧАСТКИ';
  static const shipsLabel = 'КОСМОЛЁТЫ';

  static const payNote =
      'Курс кабинета: 1 RSV = \$0.13. Сотокa = \$1,300 → 10,000 RSV. '
      'Световой день аренды = \$140 → 1,077 RSV.';

  static const exchangeNote =
      'RSV можно купить в нашем обменнике — Currency Exchange в меню. '
      'Или получить +5 RSV в Telegram за приведённого друга: '
      'админ Angela перечисляет автоматически.';

  static const disclaimer =
      'For educational and entertainment purposes. '
      'This is not a real estate offering, not an investment product, '
      'and NASA is not involved. RSV lots exist only inside Bablo Community.';

  static String heroTag(String id) => 'temki-hero-$id';

  static Uri dealUri(String title) {
    return Uri.https('t.me', telegramHandle, {
      'text': 'Привет! Хочу закрыть темку: $title. Оплата RSV.',
    });
  }

  static int rsvForUsd(int usd) => (usd / rsvUsd).round();
}

enum TemkiKind { plot, ship }

class TemkiListing {
  const TemkiListing({
    required this.id,
    required this.kind,
    required this.title,
    required this.shortLabel,
    required this.place,
    required this.imageUrl,
    required this.imageCredit,
    required this.priceUsd,
    required this.unit,
    required this.bio,
    required this.perks,
    required this.quote,
    required this.ctaLabel,
  });

  final String id;
  final TemkiKind kind;
  final String title;
  final String shortLabel;
  final String place;
  final String imageUrl;
  final String imageCredit;
  final int priceUsd;
  final String unit;
  final String bio;
  final List<(String, String)> perks;
  final String quote;
  final String ctaLabel;

  int get rsvAmount => TemkiConstants.rsvForUsd(priceUsd);

  String get route => AppRoutes.temkiItem(id);
}

class TemkiCatalog {
  TemkiCatalog._();

  static TemkiListing? byId(String id) {
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }

  static List<TemkiListing> get plots =>
      all.where((e) => e.kind == TemkiKind.plot).toList();

  static List<TemkiListing> get ships =>
      all.where((e) => e.kind == TemkiKind.ship).toList();

  static const all = <TemkiListing>[
    TemkiListing(
      id: 'mars-olympus',
      kind: TemkiKind.plot,
      title: 'Марс · Olympus Mons',
      shortLabel: 'Марс',
      place: 'Olympus Mons District',
      imageUrl:
          'https://images.unsplash.com/photo-1614728263952-84ea256f9679?w=1600&q=80&auto=format&fit=crop',
      imageCredit: 'Unsplash',
      priceUsd: 1300,
      unit: 'сотка',
      bio:
          'Видовая сотка у подножия Olympus Mons. Пыль входит в комплект, '
          'атмосфера — нет. Соседей мало, закаты длинные, связь с Землёй '
          'идёт через RSV и хорошее настроение.',
      perks: [
        ('📍', 'Локация: южный склон, вид на равнину Amazonis'),
        ('📐', '1 сотка. Межевание — «примерно вот тут, не спорь»'),
        ('🪙', '\$1,300 → 10,000 RSV. Без ипотеки и без кислорода'),
        ('📜', 'NFT-акт Bablo Community. NASA в копии не стоит'),
      ],
      quote:
          '«На Марсе ещё никто не делал ремонт. '
          'Ты можешь быть первым. Или последним.»',
      ctaLabel: 'КУПИТЬ СОТКУ · 10,000 RSV',
    ),
    TemkiListing(
      id: 'moon-tranquility',
      kind: TemkiKind.plot,
      title: 'Луна · Море Спокойствия',
      shortLabel: 'Луна',
      place: 'Mare Tranquillitatis',
      imageUrl:
          'https://images.unsplash.com/photo-1446776858070-70c3d5ed6758?w=1600&q=80&auto=format&fit=crop',
      imageCredit: 'Unsplash',
      priceUsd: 1300,
      unit: 'сотка',
      bio:
          'Сотка в Море Спокойствия. Тихо, серо, престижно. Ночью Земля '
          'висит как скриншот. Днём — тоже ночь. Идеально для тех, кто '
          'уже пережил крипту и хочет более предсказуемый грунт.',
      perks: [
        ('📍', 'Рядом с историческим пиаром 1969 года'),
        ('🌑', 'Низкая гравитация — заборы можно не ставить'),
        ('🪙', '\$1,300 за сотку, оплата RSV'),
        ('📡', 'Wi-Fi появится «когда дотянем кабель»'),
      ],
      quote:
          '«Спокойствие включено в название. '
          'Налоги, вода и соседи — нет.»',
      ctaLabel: 'КУПИТЬ СОТКУ · 10,000 RSV',
    ),
    TemkiListing(
      id: 'saturn-rings',
      kind: TemkiKind.plot,
      title: 'Сатурн · Кольцевой вид',
      shortLabel: 'Сатурн',
      place: 'A-ring viewpoint',
      imageUrl:
          'https://images.unsplash.com/photo-1636819488524-1f019c4e1c44?w=1600&q=80&auto=format&fit=crop',
      imageCredit: 'Unsplash',
      priceUsd: 1300,
      unit: 'сотка',
      bio:
          'Участок с видом на кольца. Формально это лёд и пыль, юридически — '
          'сотка. Фактически — лучший фон для сторис, который ты никогда '
          'не выложишь из-за пинга.',
      perks: [
        ('💍', 'Панорама колец 24/7, сезонность не обсуждается'),
        ('🧊', 'Климат: холодный. Очень. Ещё холоднее'),
        ('🪙', 'Цена как у всех: \$1,300 / 10,000 RSV за сотку'),
        ('🛰️', 'Доставка мебели — отдельная темка'),
      ],
      quote:
          '«Если участок нельзя потрогать — это не значит, '
          'что его нельзя продать. RSV уже в пути.»',
      ctaLabel: 'КУПИТЬ СОТКУ · 10,000 RSV',
    ),
    TemkiListing(
      id: 'titan-lakes',
      kind: TemkiKind.plot,
      title: 'Титан · Метановые берега',
      shortLabel: 'Титан',
      place: 'Kraken Mare shoreline',
      imageUrl:
          'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?w=1600&q=80&auto=format&fit=crop',
      imageCredit: 'Unsplash',
      priceUsd: 1300,
      unit: 'сотка',
      bio:
          'Берег метанового озера на Титане. Купаться не рекомендуем, '
          'но вид — как у тех, кто уже всё понял про рынок и решил '
          'инвестировать дальше от людей.',
      perks: [
        ('🌊', 'Своя береговая линия. Вещество — не вода. Это фича'),
        ('🟠', 'Атмосфера плотная, слухи — ещё плотнее'),
        ('🪙', '\$1,300 за сотку в RSV'),
        ('🧪', 'Экология: премиальная. Конкурентов нет'),
      ],
      quote:
          '«Недвижимость там, где ещё никто не построил забор. '
          'И скорее всего не построит.»',
      ctaLabel: 'КУПИТЬ СОТКУ · 10,000 RSV',
    ),
    TemkiListing(
      id: 'scout-saucer',
      kind: TemkiKind.ship,
      title: 'Разведдиск «Если прилетят»',
      shortLabel: 'Диск',
      place: 'Орбита ожидания',
      imageUrl:
          'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1600&q=80&auto=format&fit=crop',
      imageCredit: 'Unsplash',
      priceUsd: 140,
      unit: 'световой день',
      bio:
          'Аренда разведдиска. Выдаётся, если инопланетяне прилетят и '
          'будут в настроении. Один световой день — \$140 / 1,077 RSV. '
          'Пилот, карта звёзд и объяснение таможне — за доп. RSV.',
      perks: [
        ('🛸', 'Класс: scout. Влезает эго и один чемодан'),
        ('⏱', 'Тариф: световой день, не земные сутки. Читай договор'),
        ('🪙', '\$140 → 1,077 RSV. Депозит возвращаем, если они не прилетят'),
        ('📡', 'Страховка: «ну мы же предупреждали»'),
      ],
      quote:
          '«Космолёт без инопланетян — это просто очень дорогая антенна. '
          'С инопланетянами — темка.»',
      ctaLabel: 'АРЕНДОВАТЬ · 1,077 RSV',
    ),
    TemkiListing(
      id: 'light-hauler',
      kind: TemkiKind.ship,
      title: 'Грузовой светляк',
      shortLabel: 'Грузовой',
      place: 'Ангар Bablo Community',
      imageUrl:
          'https://images.unsplash.com/photo-1517976487492-5750f3195933?w=1600&q=80&auto=format&fit=crop',
      imageCredit: 'Unsplash',
      priceUsd: 140,
      unit: 'световой день',
      bio:
          'Для тех, кто купил сотку на Марсе и теперь не знает, как везти '
          'холодильник. Грузовой борт на световой день. Расход топлива '
          'считается в RSV и в оправданиях.',
      perks: [
        ('📦', 'Вместимость: одна сотка надежд и два ящика RSV'),
        ('🚀', 'Старт «по готовности Вселенной»'),
        ('🪙', '\$140 за световой день'),
        ('🛠️', 'Техосмотр: визуальный, с орбиты'),
      ],
      quote:
          '«Доставка на Марс — не логистика. Это характер.»',
      ctaLabel: 'АРЕНДОВАТЬ · 1,077 RSV',
    ),
    TemkiListing(
      id: 'weekend-ufo',
      kind: TemkiKind.ship,
      title: 'UFO на выходные',
      shortLabel: 'UFO',
      place: 'Низкая орбита, пятница',
      imageUrl:
          'https://images.unsplash.com/photo-1446776877081-d282a0f896e2?w=1600&q=80&auto=format&fit=crop',
      imageCredit: 'Unsplash',
      priceUsd: 140,
      unit: 'световой день',
      bio:
          'Короткий прокат для тех, кому надо «просто пролететь мимо Луны». '
          'Возврат до понедельника по земному календарю не гарантирован: '
          'считается световой день.',
      perks: [
        ('✨', 'Формат: weekend. Смысл: сомнительный'),
        ('📸', 'Фото с иллюминатора входят в цену. Фильтры — нет'),
        ('🪙', '\$140 / 1,077 RSV за световой день'),
        ('👽', 'Экипаж: если прилетят. Если нет — сами рулите'),
      ],
      quote:
          '«Аренда без пилота — это не баг. Это доверие к держателю RSV.»',
      ctaLabel: 'АРЕНДОВАТЬ · 1,077 RSV',
    ),
  ];
}
