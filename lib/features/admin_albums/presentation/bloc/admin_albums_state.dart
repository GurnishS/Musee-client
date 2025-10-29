part of 'admin_albums_bloc.dart';

abstract class AdminAlbumsState {
  const AdminAlbumsState();
}

class AdminAlbumsInitial extends AdminAlbumsState {
  const AdminAlbumsInitial();
}

class AdminAlbumsLoading extends AdminAlbumsState {
  const AdminAlbumsLoading();
}

class AdminAlbumsFailure extends AdminAlbumsState {
  final String message;
  const AdminAlbumsFailure(this.message);
}

class AdminAlbumsPageLoaded extends AdminAlbumsState {
  final List<Album> items;
  final int total;
  final int page;
  final int limit;
  final String? search;
  const AdminAlbumsPageLoaded({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    this.search,
  });
}
