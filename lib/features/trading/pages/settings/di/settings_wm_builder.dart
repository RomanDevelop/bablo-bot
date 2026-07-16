import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data_management/data_manager.dart';
import '../settings_wm.dart';

SettingsWidgetModel createSettingsWidgetModel(BuildContext context) {
  return SettingsWidgetModel(context.read<DataManager>().tradingRepository);
}
