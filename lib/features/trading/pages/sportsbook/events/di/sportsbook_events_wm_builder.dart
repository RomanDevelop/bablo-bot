import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/auth/auth_session.dart';
import '../../../../../../data_management/data_manager.dart';
import '../../navigation/sportsbook_navigator.dart';
import '../sportsbook_events_wm.dart';

SportsbookEventsWidgetModel createSportsbookEventsWidgetModel(
  BuildContext context,
) {
  return SportsbookEventsWidgetModel(
    auth: context.read<AuthSession>(),
    repository: context.read<DataManager>().sportsbookRepository,
    navigator: SportsbookNavigator(context),
  );
}
