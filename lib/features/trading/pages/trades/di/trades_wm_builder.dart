import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data_management/data_manager.dart';
import '../trades_wm.dart';

TradesWidgetModel createTradesWidgetModel(BuildContext context) {
  return TradesWidgetModel(context.read<DataManager>().tradingRepository);
}
