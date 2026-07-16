import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data_management/data_manager.dart';
import '../stats_wm.dart';

StatsWidgetModel createStatsWidgetModel(BuildContext context) {
  return StatsWidgetModel(context.read<DataManager>().tradingRepository);
}
