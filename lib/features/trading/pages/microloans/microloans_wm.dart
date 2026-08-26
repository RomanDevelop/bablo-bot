import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/auth/auth_session.dart';
import '../../../../core/constants/microloans_constants.dart';
import '../../../../core/mwwm/widget_model.dart';

class MicroloansState {
  const MicroloansState({
    this.selectedTierId = 'builder',
    this.termsAccepted = false,
    this.message,
    this.needsAuth = false,
  });

  final String selectedTierId;
  final bool termsAccepted;
  final String? message;
  final bool needsAuth;

  MicroloanTier get selectedTier =>
      MicroloansConstants.byId(selectedTierId) ??
      MicroloansConstants.tiers.first;

  MicroloansState copyWith({
    String? selectedTierId,
    bool? termsAccepted,
    String? message,
    bool? needsAuth,
    bool clearMessage = false,
  }) {
    return MicroloansState(
      selectedTierId: selectedTierId ?? this.selectedTierId,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      message: clearMessage ? null : (message ?? this.message),
      needsAuth: needsAuth ?? this.needsAuth,
    );
  }
}

class MicroloansWidgetModel extends WidgetModel {
  MicroloansWidgetModel({required this.auth})
      : super(const WidgetModelDependencies()) {
    final active = auth.activeLoanTierId;
    stateStream = BehaviorSubject.seeded(
      MicroloansState(
        selectedTierId: active ?? 'builder',
        termsAccepted: active != null,
      ),
    );
  }

  final AuthSession auth;

  late final BehaviorSubject<MicroloansState> stateStream;

  void selectTier(String id) {
    if (id == stateStream.value.selectedTierId) return;
    stateStream.add(stateStream.value.copyWith(selectedTierId: id));
  }

  void setTermsAccepted(bool value) {
    stateStream.add(stateStream.value.copyWith(termsAccepted: value));
  }

  Future<void> apply() async {
    final state = stateStream.value;
    if (!auth.isAuthenticated) {
      stateStream.add(
        state.copyWith(
          needsAuth: true,
          message: MicroloansConstants.needAuthMessage,
        ),
      );
      return;
    }
    if (!state.termsAccepted) {
      stateStream.add(
        state.copyWith(message: 'Accept the quasi-credit terms to continue.'),
      );
      return;
    }

    await auth.applyMicroloan(state.selectedTier.id);

    final uri = MicroloansConstants.applyTelegramUri(state.selectedTier);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    stateStream.add(
      state.copyWith(
        needsAuth: false,
        message: opened
            ? MicroloansConstants.applySoonHint
            : 'Open Telegram: @${MicroloansConstants.telegramHandle}',
      ),
    );
  }

  void clearMessage() {
    stateStream.add(
      stateStream.value.copyWith(clearMessage: true, needsAuth: false),
    );
  }

  @override
  void dispose() {
    stateStream.close();
    super.dispose();
  }
}
