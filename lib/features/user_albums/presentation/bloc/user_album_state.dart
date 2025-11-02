part of 'user_album_bloc.dart';

class UserAlbumState extends Equatable {
  final bool isLoading;
  final UserAlbumDetail? album;
  final String? error;

  const UserAlbumState._({this.isLoading = false, this.album, this.error});

  // Treat the initial state as loading so the first frame shows a spinner
  // before the load event resolves, avoiding a transient null album crash.
  const UserAlbumState.initial() : this._(isLoading: true);
  const UserAlbumState.loading() : this._(isLoading: true);
  const UserAlbumState.loaded(UserAlbumDetail a) : this._(album: a);
  const UserAlbumState.error(String message) : this._(error: message);

  @override
  List<Object?> get props => [isLoading, album, error];
}
