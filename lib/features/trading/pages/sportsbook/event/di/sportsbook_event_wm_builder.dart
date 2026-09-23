import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/auth/auth_session.dart';
import '../../../../../../data_management/data_manager.dart';
import '../../../../models/sportsbook_model.dart';
import '../../navigation/sportsbook_navigator.dart';
import '../sportsbook_event_wm.dart';

SportsbookEventWidgetModel createSportsbookEventWidgetModel(
  BuildContext context, {
  required String eventId,
  SportsbookEvent? preview,
}) {
  return SportsbookEventWidgetModel(
    eventId: eventId,
    preview: preview,
    auth: context.read<AuthSession>(),
    repository: context.read<DataManager>().sportsbookRepository,
    navigator: SportsbookNavigator(context),
  );
}
