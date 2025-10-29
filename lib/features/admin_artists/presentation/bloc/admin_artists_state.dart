part of 'admin_artists_bloc.dart';

abstract class AdminArtistsState {
  const AdminArtistsState();
}

class AdminArtistsInitial extends AdminArtistsState {
  const AdminArtistsInitial();
}

class AdminArtistsLoading extends AdminArtistsState {
  const AdminArtistsLoading();
}

class AdminArtistsFailure extends AdminArtistsState {
  final String message;
  AdminArtistsFailure(this.message);
}

class AdminArtistsPageLoaded extends AdminArtistsState {
  final List<Artist> items;
  final int total;
  final int page;
  final int limit;
  final String? search;
  AdminArtistsPageLoaded({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    this.search,
  });
}
