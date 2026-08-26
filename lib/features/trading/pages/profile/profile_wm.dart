import 'package:rxdart/rxdart.dart';

import '../../../../core/auth/auth_session.dart';
import '../../../../core/constants/microloans_constants.dart';
import '../../../../core/mwwm/widget_model.dart';

class ProfileState {
  const ProfileState({this.message});

  final String? message;

  ProfileState copyWith({String? message, bool clearMessage = false}) {
    return ProfileState(
      message: clearMessage ? null : (message ?? this.message),
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

  int get rsvBalance => auth.demoRsvBalance;

  MicroloanTier? get activeLoan => auth.activeLoanTier;

  /// Local stub until Bablo backend auth.
  Future<void> signIn() async {
    await auth.signInStub();
    stateStream.add(
      stateStream.value.copyWith(
        message:
            'Signed in (local stub). Backend auth & wallet — coming soon.',
      ),
    );
  }

  Future<void> signOut() async {
    await auth.signOut();
    stateStream.add(
      stateStream.value.copyWith(message: 'Signed out.'),
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
