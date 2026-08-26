import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/auth/auth_session.dart';
import '../profile_wm.dart';

ProfileWidgetModel createProfileWidgetModel(BuildContext context) {
  return ProfileWidgetModel(auth: context.read<AuthSession>());
}
