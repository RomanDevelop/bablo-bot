import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data_management/data_manager.dart';
import '../lab_wm.dart';

LabWidgetModel createLabWidgetModel(BuildContext context) {
  return LabWidgetModel(context.read<DataManager>().backtestRepository);
}
