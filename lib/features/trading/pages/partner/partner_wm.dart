import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/partner_constants.dart';
import '../../../../core/mwwm/widget_model.dart';

class PartnerState {
  const PartnerState({this.message});

  final String? message;

  PartnerState copyWith({String? message, bool clearMessage = false}) {
    return PartnerState(
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

class PartnerWidgetModel extends WidgetModel {
  PartnerWidgetModel() : super(const WidgetModelDependencies());

  final BehaviorSubject<PartnerState> stateStream =
      BehaviorSubject.seeded(const PartnerState());

  String get jarUrl => PartnerConstants.monobankJarUrl;

  List<CryptoWallet> get wallets => PartnerConstants.configuredWallets;

  bool get hasJarUrl => jarUrl.isNotEmpty;

  Future<void> openMonobankJar() async {
    if (!hasJarUrl) {
      stateStream.add(
        stateStream.value.copyWith(
          message: 'Ссылка банки не задана (MONOBANK_JAR_URL)',
        ),
      );
      return;
    }
    final uri = Uri.tryParse(jarUrl);
    if (uri == null) {
      stateStream.add(
        stateStream.value.copyWith(message: 'Некорректная ссылка банки'),
      );
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      stateStream.add(
        stateStream.value.copyWith(message: 'Не удалось открыть Monobank'),
      );
    }
  }

  Future<void> copyWalletAddress(CryptoWallet wallet) async {
    await Clipboard.setData(ClipboardData(text: wallet.address));
    stateStream.add(
      stateStream.value.copyWith(message: 'Адрес ${wallet.network} скопирован'),
    );
  }

  void clearMessage() {
    stateStream.add(stateStream.value.copyWith(clearMessage: true));
  }

  @override
  void dispose() {
    stateStream.close();
    super.dispose();
  }
}
