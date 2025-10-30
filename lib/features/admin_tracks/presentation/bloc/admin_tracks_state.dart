part of 'admin_tracks_bloc.dart';

// Uses Track from the parent library import in admin_tracks_bloc.dart

abstract class AdminTracksState {
  const AdminTracksState();
}

class AdminTracksInitial extends AdminTracksState {
  const AdminTracksInitial();
}

class AdminTracksLoading extends AdminTracksState {
  const AdminTracksLoading();
}

class AdminTracksFailure extends AdminTracksState {
  final String message;
  AdminTracksFailure(this.message);
}

class AdminTracksPageLoaded extends AdminTracksState {
  final List<Track> items;
  final int total;
  final int page;
  final int limit;
  final String? search;

  AdminTracksPageLoaded({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    this.search,
  });
}
