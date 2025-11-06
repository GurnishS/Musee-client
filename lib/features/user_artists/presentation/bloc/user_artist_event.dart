part of 'user_artist_bloc.dart';

abstract class UserArtistEvent extends Equatable {
  const UserArtistEvent();
  @override
  List<Object?> get props => [];
}

class UserArtistLoadRequested extends UserArtistEvent {
  final String artistId;
  const UserArtistLoadRequested(this.artistId);

  @override
  List<Object?> get props => [artistId];
}
