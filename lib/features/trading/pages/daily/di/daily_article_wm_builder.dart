import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data_management/data_manager.dart';
import '../../../models/daily_article.dart';
import '../daily_article_wm.dart';

DailyArticleWidgetModel createDailyArticleWidgetModel(
  BuildContext context, {
  required String articleId,
  DailyArticle? preview,
}) {
  return DailyArticleWidgetModel(
    repository: context.read<DataManager>().dailyRepository,
    articleId: articleId,
    preview: preview,
  );
}
