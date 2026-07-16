import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data_management/data_manager.dart';
import '../portfolio_wm.dart';

PortfolioWidgetModel createPortfolioWidgetModel(BuildContext context) {
  return PortfolioWidgetModel(context.read<DataManager>().tradingRepository);
}
