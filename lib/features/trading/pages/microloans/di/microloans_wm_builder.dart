import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/auth/auth_session.dart';
import '../microloans_wm.dart';

MicroloansWidgetModel createMicroloansWidgetModel(BuildContext context) {
  return MicroloansWidgetModel(auth: context.read<AuthSession>());
}
