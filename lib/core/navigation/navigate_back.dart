import 'package:flutter/material.dart';

import 'app_routes.dart';

/// Pop if possible, otherwise go to shell home (fixes deep-link `/chart` etc.).
void navigateBackOrHome(BuildContext context) {
  final nav = Navigator.of(context);
  if (nav.canPop()) {
    nav.pop();
    return;
  }
  nav.pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
}
