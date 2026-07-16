import 'package:flutter/widgets.dart';

import 'widget_model.dart';

typedef WidgetModelBuilder<T extends WidgetModel> = T Function(
  BuildContext context,
);

abstract class CoreMwwmWidget<T extends WidgetModel> extends StatefulWidget {
  const CoreMwwmWidget({
    super.key,
    required this.widgetModelBuilder,
  });

  final WidgetModelBuilder<T> widgetModelBuilder;
}

abstract class MwwmWidgetState<W extends CoreMwwmWidget<T>, T extends WidgetModel>
    extends State<W> {
  late final T wm;

  @override
  void initState() {
    super.initState();
    wm = widget.widgetModelBuilder(context);
    wm.onLoad();
    wm.onBind();
  }

  @override
  void dispose() {
    wm.dispose();
    super.dispose();
  }
}
