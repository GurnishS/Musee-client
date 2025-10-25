import 'package:musee/core/common/entities/user.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

part 'app_user_state.dart';

class AppUserCubit extends HydratedCubit<AppUserState> {
  AppUserCubit() : super(AppUserInitial());

  void updateUser(User? user) {
    if (user == null) {
      emit(AppUserInitial());
    } else {
      emit(AppUserLoggedIn(user));
    }
  }

  @override
  AppUserState? fromJson(Map<String, dynamic> json) {
    try {
      final String stateType = json['type'] as String;

      switch (stateType) {
        case 'AppUserInitial':
          return AppUserInitial();
        case 'AppUserLoading':
          return AppUserLoading();
        case 'AppUserLoggedIn':
          final userData = json['user'] as Map<String, dynamic>;
          final user = User.fromJson(userData);
          return AppUserLoggedIn(user);
        default:
          return null;
      }
    } catch (e) {
      // Return null if deserialization fails, will use initial state
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(AppUserState state) {
    switch (state.runtimeType) {
      case const (AppUserInitial):
        return {'type': 'AppUserInitial'};
      case const (AppUserLoading):
        return {'type': 'AppUserLoading'};
      case const (AppUserLoggedIn):
        final loggedInState = state as AppUserLoggedIn;
        return {'type': 'AppUserLoggedIn', 'user': loggedInState.user.toJson()};
      default:
        return null;
    }
  }
}
