part of 'user_artist_bloc.dart';

class UserArtistState extends Equatable {
  final bool isLoading;
  final UserArtistDetail? artist;
  final String? error;

  const UserArtistState._({this.isLoading = false, this.artist, this.error});

  const UserArtistState.initial() : this._(isLoading: true);
  const UserArtistState.loading() : this._(isLoading: true);
  const UserArtistState.loaded(UserArtistDetail a) : this._(artist: a);
  const UserArtistState.error(String message) : this._(error: message);

  @override
  List<Object?> get props => [isLoading, artist, error];
}
