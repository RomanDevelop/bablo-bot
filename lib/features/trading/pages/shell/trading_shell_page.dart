import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../components/navigation/floating_action_buttons.dart';
import '../../../../components/navigation/floating_bottom_navigation.dart';
import '../../../../components/navigation/right_side_menu.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../dashboard/dashboard_page.dart';
import '../history/history_page.dart';
import '../market/market_page.dart';

class TradingShellPage extends StatefulWidget {
  const TradingShellPage({super.key});

  @override
  State<TradingShellPage> createState() => _TradingShellPageState();
}

class _TradingShellPageState extends State<TradingShellPage>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  bool _menuOpen = false;

  late final AnimationController _menuCtrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  late final List<Widget> _pages = [
    DashboardPage(
      onOpenMenu: _openMenu,
    ),
    MarketPage(onOpenMenu: _openMenu),
    HistoryPage(onOpenMenu: _openMenu),
  ];

  @override
  void initState() {
    super.initState();
    _menuCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slide = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _menuCtrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _menuCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _menuCtrl.dispose();
    super.dispose();
  }

  void _openMenu() {
    setState(() => _menuOpen = true);
    _menuCtrl.forward(from: 0);
  }

  Future<void> _closeMenu() async {
    await _menuCtrl.reverse();
    if (mounted) setState(() => _menuOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild chrome + overlays when theme toggles.
    context.watch<ThemeController>();
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _index,
              children: _pages,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 12 + bottomPad,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GlobalSearchButton(
                  onPressed: () => AppNavigator.openSearch(context),
                ),
                const Spacer(),
                FloatingBottomNavigation(
                  index: _index,
                  onChanged: (i) => setState(() => _index = i),
                ),
                const Spacer(),
                AiChatFloatingButton(
                  onPressed: () => AppNavigator.openAi(context),
                ),
              ],
            ),
          ),
          if (_menuOpen) ...[
            Positioned.fill(
              child: FadeTransition(
                opacity: _fade,
                child: GestureDetector(
                  onTap: _closeMenu,
                  child: ColoredBox(color: AppColors.scrim),
                ),
              ),
            ),
            Positioned.fill(
              child: SlideTransition(
                position: _slide,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: RightSideMenu(
                    onClose: _closeMenu,
                    onOpenTab: (i) {
                      setState(() => _index = i);
                    },
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
