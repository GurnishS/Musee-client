import 'package:bloc/bloc.dart';
import '../../domain/entities/track.dart';
import '../../domain/usecases/create_track.dart';
import '../../domain/usecases/delete_track.dart';
import '../../domain/usecases/list_tracks.dart';
import '../../domain/usecases/update_track.dart';

part 'admin_tracks_event.dart';
part 'admin_tracks_state.dart';

class AdminTracksBloc extends Bloc<AdminTracksEvent, AdminTracksState> {
  final ListTracks list;
  final CreateTrack create;
  final UpdateTrack update;
  final DeleteTrack delete;

  AdminTracksBloc({
    required this.list,
    required this.create,
    required this.update,
    required this.delete,
  }) : super(const AdminTracksInitial()) {
    on<LoadTracks>(_onLoad);
    on<CreateTrackEvent>(_onCreate);
    on<UpdateTrackEvent>(_onUpdate);
    on<DeleteTrackEvent>(_onDelete);
  }

  Future<void> _onLoad(LoadTracks event, Emitter<AdminTracksState> emit) async {
    emit(const AdminTracksLoading());
    final res = await list(
      ListTracksParams(page: event.page, limit: event.limit, q: event.search),
    );
    res.fold(
      (f) => emit(AdminTracksFailure(f.message)),
      (t) => emit(
        AdminTracksPageLoaded(
          items: t.$1,
          total: t.$2,
          page: t.$3,
          limit: t.$4,
          search: event.search,
        ),
      ),
    );
  }

  Future<void> _onCreate(
    CreateTrackEvent event,
    Emitter<AdminTracksState> emit,
  ) async {
    emit(const AdminTracksLoading());
    final res = await create(
      CreateTrackParams(
        title: event.title,
        albumId: event.albumId,
        duration: event.duration,
        lyricsUrl: event.lyricsUrl,
        isExplicit: event.isExplicit,
        isPublished: event.isPublished,
        audioBytes: event.audioBytes,
        audioFilename: event.audioFilename,
        coverBytes: event.coverBytes,
        coverFilename: event.coverFilename,
        videoBytes: event.videoBytes,
        videoFilename: event.videoFilename,
      ),
    );
    await res.fold((f) async => emit(AdminTracksFailure(f.message)), (_) async {
      final st = state;
      var page = 0, limit = 20;
      String? search;
      if (st is AdminTracksPageLoaded) {
        page = st.page;
        limit = st.limit;
        search = st.search;
      }
      final reload = await list(
        ListTracksParams(page: page, limit: limit, q: search),
      );
      reload.fold(
        (f) => emit(AdminTracksFailure(f.message)),
        (t) => emit(
          AdminTracksPageLoaded(
            items: t.$1,
            total: t.$2,
            page: t.$3,
            limit: t.$4,
            search: search,
          ),
        ),
      );
    });
  }

  Future<void> _onUpdate(
    UpdateTrackEvent event,
    Emitter<AdminTracksState> emit,
  ) async {
    emit(const AdminTracksLoading());
    final res = await update(
      UpdateTrackParams(
        id: event.id,
        title: event.title,
        albumId: event.albumId,
        duration: event.duration,
        lyricsUrl: event.lyricsUrl,
        isExplicit: event.isExplicit,
        isPublished: event.isPublished,
        audioBytes: event.audioBytes,
        audioFilename: event.audioFilename,
        coverBytes: event.coverBytes,
        coverFilename: event.coverFilename,
        videoBytes: event.videoBytes,
        videoFilename: event.videoFilename,
      ),
    );
    await res.fold((f) async => emit(AdminTracksFailure(f.message)), (_) async {
      final st = state;
      var page = 0, limit = 20;
      String? search;
      if (st is AdminTracksPageLoaded) {
        page = st.page;
        limit = st.limit;
        search = st.search;
      }
      final reload = await list(
        ListTracksParams(page: page, limit: limit, q: search),
      );
      reload.fold(
        (f) => emit(AdminTracksFailure(f.message)),
        (t) => emit(
          AdminTracksPageLoaded(
            items: t.$1,
            total: t.$2,
            page: t.$3,
            limit: t.$4,
            search: search,
          ),
        ),
      );
    });
  }

  Future<void> _onDelete(
    DeleteTrackEvent event,
    Emitter<AdminTracksState> emit,
  ) async {
    emit(const AdminTracksLoading());
    final res = await delete(DeleteTrackParams(event.id));
    await res.fold((f) async => emit(AdminTracksFailure(f.message)), (_) async {
      final st = state;
      var page = 0, limit = 20;
      String? search;
      if (st is AdminTracksPageLoaded) {
        page = st.page;
        limit = st.limit;
        search = st.search;
      }
      final reload = await list(
        ListTracksParams(page: page, limit: limit, q: search),
      );
      reload.fold(
        (f) => emit(AdminTracksFailure(f.message)),
        (t) => emit(
          AdminTracksPageLoaded(
            items: t.$1,
            total: t.$2,
            page: t.$3,
            limit: t.$4,
            search: search,
          ),
        ),
      );
    });
  }
}
