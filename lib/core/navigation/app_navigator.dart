import 'package:flutter/material.dart';

import 'app_routes.dart';

/// Thin navigation helper — keeps pushNamed usage consistent.
class AppNavigator {
  AppNavigator._();

  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String route, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(route, arguments: arguments);
  }

  static void goHomeTab(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static Future<void> openAi(BuildContext context) =>
      pushNamed(context, AppRoutes.aiAssistant);

  static Future<void> openSearch(BuildContext context) =>
      pushNamed(context, AppRoutes.search);

  static Future<void> openSignals(BuildContext context) =>
      pushNamed(context, AppRoutes.signals);

  static Future<T?> openDaily<T extends Object?>(
    BuildContext context,
    String id, {
    Object? arguments,
  }) {
    return pushNamed<T>(
      context,
      AppRoutes.dailyArticle(id),
      arguments: arguments,
    );
  }

  static Future<T?> openCourse<T extends Object?>(
    BuildContext context,
    String id, {
    Object? arguments,
  }) {
    return pushNamed<T>(
      context,
      AppRoutes.courseMentor(id),
      arguments: arguments,
    );
  }

  static Future<T?> openTemki<T extends Object?>(
    BuildContext context, {
    String? id,
    Object? arguments,
  }) {
    return pushNamed<T>(
      context,
      id == null ? AppRoutes.temki : AppRoutes.temkiItem(id),
      arguments: arguments,
    );
  }
}

extension AppNavContext on BuildContext {
  Future<T?> push<T extends Object?>(String location, {Object? extra}) {
    return Navigator.of(this).pushNamed<T>(location, arguments: extra);
  }
}
