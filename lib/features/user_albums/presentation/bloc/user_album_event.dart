part of 'user_album_bloc.dart';

abstract class UserAlbumEvent extends Equatable {
  const UserAlbumEvent();
  @override
  List<Object?> get props => [];
}

class UserAlbumLoadRequested extends UserAlbumEvent {
  final String albumId;
  const UserAlbumLoadRequested(this.albumId);

  @override
  List<Object?> get props => [albumId];
}
