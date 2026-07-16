import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data_management/data_manager.dart';
import '../dashboard_wm.dart';

DashboardWidgetModel createDashboardWidgetModel(BuildContext context) {
  final dataManager = context.read<DataManager>();
  return DashboardWidgetModel(dataManager.tradingRepository);
}
