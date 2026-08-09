/// Bablo Community Documents copy.
class DocumentsConstants {
  DocumentsConstants._();

  static const title = 'DOCUMENTS';
  static const tagline =
      'Bablo Community — Official Papers & Very Important Stuff';

  static const intro =
      'Здесь хранится всё, что превращает наши темки и мутки в солидную '
      'деловую деятельность.';

  static const body =
      'Договоры, соглашения, отчёты, внутренние регламенты, презентации, '
      'финансовые документы и прочие PDF-файлы, которые никто не читает '
      'до тех пор, пока что-нибудь не пошло не по плану.';

  static const sectionsLabel = 'Внутри раздела';

  static const categories = <(String, String, bool)>[
    (
      'Contracts & Deals',
      'NDA, term sheets и «мы точно договорились»',
      false,
    ),
    (
      'Financial Reports',
      'Цифры, графики и куда опять делось бабло',
      false,
    ),
    (
      'Company Policies',
      'Регламенты, которые пишут после первого хаоса',
      false,
    ),
    (
      'Legal Documents',
      'Юристы сказали «обязательно», мы сказали «ок»',
      false,
    ),
    (
      'Presentations',
      'Слайды для инвесторов и для собственного эго',
      false,
    ),
    (
      'Confidential Stuff',
      'То, чего нет. Особенно если спросить.',
      true,
    ),
  ];

  static const footer = 'Everything is documented. Almost everything.';

  static const emptyHint =
      'Архив наполняется. Пока — атмосфера и правильные папки.';
}
