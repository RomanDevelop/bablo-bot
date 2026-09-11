import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/auth/auth_session.dart';
import '../../../../../../data_management/data_manager.dart';
import '../../navigation/casino_navigator.dart';
import '../casino_game_wm.dart';

CasinoGameWidgetModel createCasinoGameWidgetModel(
  BuildContext context, {
  required String gameId,
}) {
  return CasinoGameWidgetModel(
    gameId: gameId,
    auth: context.read<AuthSession>(),
    repository: context.read<DataManager>().casinoRepository,
    navigator: CasinoNavigator(context),
  );
}
