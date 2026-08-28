import 'package:rxdart/rxdart.dart';

import '../../../../core/auth/auth_session.dart';
import '../../../../core/constants/microloans_constants.dart';
import '../../../../core/errors/data_error.dart';
import '../../../../core/mwwm/widget_model.dart';

class ProfileState {
  const ProfileState({
    this.message,
    this.isBusy = false,
  });

  final String? message;
  final bool isBusy;

  ProfileState copyWith({
    String? message,
    bool? isBusy,
    bool clearMessage = false,
  }) {
    return ProfileState(
      message: clearMessage ? null : (message ?? this.message),
      isBusy: isBusy ?? this.isBusy,
    );
  }
}

class ProfileWidgetModel extends WidgetModel {
  ProfileWidgetModel({required this.auth})
      : super(const WidgetModelDependencies());

  final AuthSession auth;

  final BehaviorSubject<ProfileState> stateStream =
      BehaviorSubject.seeded(const ProfileState());

  bool get isAuthenticated => auth.isAuthenticated;

  String get displayName => auth.displayName;

  String get handle => auth.handle;

  num get rsvBalance => auth.rsvBalance;

  num get earnedRsv => auth.earnedRsv;

  MicroloanTier? get activeLoan => auth.activeLoanTier;

  Future<void> signIn() async {
    stateStream.add(stateStream.value.copyWith(isBusy: true, clearMessage: true));
    await auth.login();
    stateStream.add(
      stateStream.value.copyWith(
        isBusy: false,
        message: auth.isAuthenticated
            ? 'Signed in as ${auth.displayName}'
            : auth.errorMessage ?? 'Open Bablo in Telegram to sign in',
      ),
    );
  }

  Future<void> signOut() async {
    stateStream.add(stateStream.value.copyWith(isBusy: true, clearMessage: true));
    await auth.logout();
    stateStream.add(
      stateStream.value.copyWith(
        isBusy: false,
        message: 'Signed out.',
      ),
    );
  }

  Future<void> refreshProfile() async {
    stateStream.add(stateStream.value.copyWith(isBusy: true, clearMessage: true));
    try {
      await auth.refreshBootstrap();
      stateStream.add(
        stateStream.value.copyWith(
          isBusy: false,
          message: 'Profile updated',
        ),
      );
    } on DataError catch (e) {
      stateStream.add(
        stateStream.value.copyWith(isBusy: false, message: e.displayMessage),
      );
    } catch (e) {
      stateStream.add(
        stateStream.value.copyWith(isBusy: false, message: e.toString()),
      );
    }
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
