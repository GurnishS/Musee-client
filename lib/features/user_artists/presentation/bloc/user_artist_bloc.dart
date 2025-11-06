import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musee/features/user_artists/domain/entities/user_artist.dart';
import 'package:musee/features/user_artists/domain/usecases/get_user_artist.dart';

part 'user_artist_event.dart';
part 'user_artist_state.dart';

class UserArtistBloc extends Bloc<UserArtistEvent, UserArtistState> {
  final GetUserArtist _getArtist;
  UserArtistBloc(this._getArtist) : super(const UserArtistState.initial()) {
    on<UserArtistLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    UserArtistLoadRequested event,
    Emitter<UserArtistState> emit,
  ) async {
    emit(const UserArtistState.loading());
    try {
      final artist = await _getArtist(event.artistId);
      emit(UserArtistState.loaded(artist));
    } catch (e) {
      emit(UserArtistState.error(e.toString()));
    }
  }
}
