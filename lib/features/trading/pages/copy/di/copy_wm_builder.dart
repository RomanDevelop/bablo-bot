import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/auth/auth_session.dart';
import '../../../../../data_management/data_manager.dart';
import '../copy_wm.dart';
import '../navigation/copy_navigator.dart';

CopyWidgetModel createCopyWidgetModel(BuildContext context) {
  return CopyWidgetModel(
    auth: context.read<AuthSession>(),
    repository: context.read<DataManager>().copyRepository,
    navigator: CopyNavigator(context),
  );
}
