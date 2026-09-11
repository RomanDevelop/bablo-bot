import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../components/feedback.dart';
import '../../../../components/trading_card.dart';
import '../../../../core/auth/auth_session.dart';
import '../../../../core/constants/copy_constants.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/theme_controller.dart';
import 'components/copy_active_card.dart';
import 'components/copy_enable_card.dart';
import 'components/copy_gate_card.dart';
import 'components/copy_history_list.dart';
import 'copy_wm.dart';
import 'di/copy_wm_builder.dart';

class CopyPage extends CoreMwwmWidget<CopyWidgetModel> {
  CopyPage({super.key}) : super(widgetModelBuilder: createCopyWidgetModel);

  static Route<void> route() => MaterialPageRoute<void>(
        settings: const RouteSettings(name: AppRoutes.copy),
        builder: (_) => CopyPage(),
      );

  @override
  State<CopyPage> createState() => _CopyPageState();
}

class _CopyPageState extends MwwmWidgetState<CopyPage, CopyWidgetModel> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final auth = context.watch<AuthSession>();

    return StreamBuilder<CopyState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const CopyState();

        if (state.message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final msg = wm.stateStream.value.message;
            if (msg == null) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                behavior: SnackBarBehavior.floating,
              ),
            );
            wm.clearMessage();
          });
        }

        return Scaffold(
          backgroundColor: p.background,
          appBar: AppBar(
            backgroundColor: p.background,
            foregroundColor: p.textPrimary,
            leading: IconButton(
              tooltip: 'Назад',
              onPressed: () => navigateBackOrHome(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: const Text(CopyConstants.subtitle),
            actions: [
              IconButton(
                tooltip: 'Profile',
                onPressed: wm.openProfile,
                icon: Icon(
                  auth.isAuthenticated
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            color: p.primary,
            backgroundColor: p.surface,
            onRefresh: () => wm.load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              children: [
                Text(
                  CopyConstants.title,
                  style: TextStyle(
                    color: p.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  CopyConstants.subtitle,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  CopyConstants.intro,
                  style: TextStyle(
                    color: p.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                ..._body(state),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _body(CopyState state) {
    if (state.isLoading && state.status == null) {
      return const [
        SizedBox(height: 80),
        PageLoading(),
      ];
    }

    if (state.error != null) {
      return [
        ErrorBanner(message: state.error!, onRetry: () => wm.load()),
        const SizedBox(height: 12),
        if (state.planRequired || state.needsAuth)
          ..._gateOrAuth(state)
        else if (state.status != null)
          ..._content(state),
      ];
    }

    if (state.needsAuth) {
      return _gateOrAuth(state);
    }

    if (state.planRequired && !state.isActive) {
      return [
        CopyGateCard(onOpenPremium: wm.openSubscriptions),
      ];
    }

    if (state.status == null) {
      return [
        CopyGateCard(onOpenPremium: wm.openSubscriptions),
      ];
    }

    return _content(state);
  }

  List<Widget> _gateOrAuth(CopyState state) {
    if (state.needsAuth) {
      return [
        TradingCard(
          onTap: wm.openProfile,
          child: const Text(CopyConstants.needAuth),
        ),
      ];
    }
    return [CopyGateCard(onOpenPremium: wm.openSubscriptions)];
  }

  List<Widget> _content(CopyState state) {
    final status = state.status!;
    if (state.isActive) {
      return [
        CopyActiveCard(
          status: status,
          countdownSeconds: state.countdownSeconds,
          isMutating: state.isMutating,
          onTopup: wm.topup,
          onExit: wm.exit,
          onComplete: wm.complete,
        ),
        const SizedBox(height: 20),
        CopyHistoryList(items: state.history),
      ];
    }
    return [
      CopyEnableCard(
        status: status,
        amountRsv: state.amountRsv,
        disclaimerAccepted: state.disclaimerAccepted,
        isMutating: state.isMutating,
        onAmountChanged: wm.setAmount,
        onDisclaimerChanged: wm.setDisclaimerAccepted,
        onEnable: wm.enable,
      ),
    ];
  }
}
