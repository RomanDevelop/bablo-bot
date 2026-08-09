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
}
