import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';

import '../../../../core/constants/market_constants.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/app_colors.dart';
import 'di/us_stocks_wm_builder.dart';
import 'us_stocks_wm.dart';

bool _webViewPlatformRegistered = false;

void ensureWebViewPlatform() {
  if (_webViewPlatformRegistered) return;
  if (kIsWeb) {
    WebViewPlatform.instance = WebWebViewPlatform();
  }
  _webViewPlatformRegistered = true;
}

class UsStocksPage extends CoreMwwmWidget<UsStocksWidgetModel> {
  UsStocksPage({super.key})
      : super(widgetModelBuilder: createUsStocksWidgetModel);

  static Route<void> route() => MaterialPageRoute<void>(
        settings: const RouteSettings(name: AppRoutes.usStocks),
        builder: (_) => UsStocksPage(),
      );

  @override
  State<UsStocksPage> createState() => _UsStocksPageState();
}

class _UsStocksPageState
    extends MwwmWidgetState<UsStocksPage, UsStocksWidgetModel> {
  late final WebViewController _controller;

  @override
  void initState() {
    ensureWebViewPlatform();
    super.initState();
    _controller = WebViewController();
    if (!kIsWeb) {
      _controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) => wm.onPageStarted(),
            onPageFinished: (_) => wm.onPageFinished(),
            onWebResourceError: (_) => wm.onWebResourceError(),
          ),
        );
    }
    _controller.loadRequest(wm.exchangeUri);

    // webview_flutter_web does not fire NavigationDelegate events.
    if (kIsWeb) {
      Future<void>.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        wm.onPageFinished();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UsStocksState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const UsStocksState();

        if (state.message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final msg = wm.stateStream.value.message;
            if (msg == null) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );
            wm.clearMessage();
          });
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            leading: IconButton(
              tooltip: 'Назад',
              onPressed: () => navigateBackOrHome(context),
              icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            ),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MarketConstants.usStocksTitle,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                Text(
                  MarketConstants.usStocksSubtitle,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Обновить',
                onPressed: () {
                  wm.onPageStarted();
                  if (kIsWeb) {
                    _controller.loadRequest(wm.exchangeUri);
                    Future<void>.delayed(const Duration(milliseconds: 900), () {
                      if (!mounted) return;
                      wm.onPageFinished();
                    });
                  } else {
                    _controller.reload();
                  }
                },
                icon: const Icon(Icons.refresh_rounded),
              ),
              IconButton(
                tooltip: 'Открыть в браузере',
                onPressed: wm.openExternal,
                icon: const Icon(Icons.open_in_new_rounded),
              ),
            ],
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(
                  color: AppColors.surface,
                  child: WebViewWidget(controller: _controller),
                ),
              ),
              if (state.isLoading)
                Positioned.fill(
                  child: ColoredBox(
                    color: AppColors.background,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              if (state.hasError)
                Positioned.fill(
                  child: ColoredBox(
                    color: AppColors.background,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              color: AppColors.textMuted,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Биржа не загрузилась в WebView',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Открой UTEX во внешнем окне — иногда биржа '
                              'блокирует встраивание.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton(
                              onPressed: wm.openExternal,
                              child: const Text('Открыть UTEX'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
