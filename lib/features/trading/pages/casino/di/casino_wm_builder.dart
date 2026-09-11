import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/auth/auth_session.dart';
import '../../../../../data_management/data_manager.dart';
import '../casino_wm.dart';
import '../navigation/casino_navigator.dart';

CasinoWidgetModel createCasinoWidgetModel(BuildContext context) {
  return CasinoWidgetModel(
    auth: context.read<AuthSession>(),
    repository: context.read<DataManager>().casinoRepository,
    navigator: CasinoNavigator(context),
  );
}
