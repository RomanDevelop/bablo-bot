import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data_management/data_manager.dart';
import '../chart_wm.dart';

ChartWidgetModel createChartWidgetModel(BuildContext context) {
  final dm = context.read<DataManager>();
  return ChartWidgetModel(dm.chartRepository);
}
