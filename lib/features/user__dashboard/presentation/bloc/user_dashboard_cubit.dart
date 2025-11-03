import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musee/features/user__dashboard/domain/entities/dashboard_album.dart';
import 'package:musee/features/user__dashboard/domain/usecases/list_made_for_you.dart';
import 'package:musee/features/user__dashboard/domain/usecases/list_trending.dart';

class UserDashboardState extends Equatable {
  final bool loadingMadeForYou;
  final bool loadingTrending;
  final List<DashboardAlbum> madeForYou;
  final List<DashboardAlbum> trending;
  final String? errorMadeForYou;
  final String? errorTrending;

  const UserDashboardState({
    this.loadingMadeForYou = false,
    this.loadingTrending = false,
    this.madeForYou = const [],
    this.trending = const [],
    this.errorMadeForYou,
    this.errorTrending,
  });

  UserDashboardState copyWith({
    bool? loadingMadeForYou,
    bool? loadingTrending,
    List<DashboardAlbum>? madeForYou,
    List<DashboardAlbum>? trending,
    String? errorMadeForYou,
    String? errorTrending,
  }) {
    return UserDashboardState(
      loadingMadeForYou: loadingMadeForYou ?? this.loadingMadeForYou,
      loadingTrending: loadingTrending ?? this.loadingTrending,
      madeForYou: madeForYou ?? this.madeForYou,
      trending: trending ?? this.trending,
      errorMadeForYou: errorMadeForYou,
      errorTrending: errorTrending,
    );
  }

  @override
  List<Object?> get props => [
    loadingMadeForYou,
    loadingTrending,
    madeForYou,
    trending,
    errorMadeForYou,
    errorTrending,
  ];
}

class UserDashboardCubit extends Cubit<UserDashboardState> {
  final ListMadeForYou _listMadeForYou;
  final ListTrending _listTrending;

  UserDashboardCubit(this._listMadeForYou, this._listTrending)
    : super(const UserDashboardState());

  Future<void> load({int page = 0, int limit = 20}) async {
    emit(
      state.copyWith(
        loadingMadeForYou: true,
        loadingTrending: true,
        errorMadeForYou: null,
        errorTrending: null,
      ),
    );

    try {
      final results = await Future.wait([
        _listMadeForYou(page: page, limit: limit),
        _listTrending(page: page, limit: limit),
      ]);
      emit(
        state.copyWith(
          loadingMadeForYou: false,
          loadingTrending: false,
          madeForYou: results[0].items,
          trending: results[1].items,
          errorMadeForYou: null,
          errorTrending: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadingMadeForYou: false,
          loadingTrending: false,
          errorMadeForYou: e.toString(),
          errorTrending: e.toString(),
        ),
      );
    }
  }
}
