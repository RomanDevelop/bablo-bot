import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/auth/auth_session.dart';
import '../../../../../data_management/data_manager.dart';
import '../navigation/sportsbook_navigator.dart';
import '../sportsbook_wm.dart';

SportsbookWidgetModel createSportsbookWidgetModel(BuildContext context) {
  return SportsbookWidgetModel(
    auth: context.read<AuthSession>(),
    repository: context.read<DataManager>().sportsbookRepository,
    navigator: SportsbookNavigator(context),
  );
}
