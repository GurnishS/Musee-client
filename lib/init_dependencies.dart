import 'package:musee/core/common/cubit/app_user_cubit.dart';
import 'package:musee/core/secrets/app_secrets.dart';
import 'package:dio/dio.dart';
import 'package:musee/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:musee/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:musee/features/auth/domain/repository/auth_repository.dart';
import 'package:musee/features/auth/domain/usecases/current_user.dart';
import 'package:musee/features/auth/domain/usecases/google_sign_in.dart';
import 'package:musee/features/auth/domain/usecases/resend_email_verification.dart';
import 'package:musee/features/auth/domain/usecases/send_password_reset_email.dart';
import 'package:musee/features/auth/domain/usecases/user_sign_in.dart';
import 'package:musee/features/auth/domain/usecases/user_sign_up.dart';
import 'package:musee/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:musee/features/auth/domain/usecases/logout_user_usecase.dart';

import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:musee/features/admin_users/data/datasources/admin_remote_data_source.dart';
import 'package:musee/features/admin_users/data/repositories/admin_repository_impl.dart';
import 'package:musee/features/admin_users/domain/repository/admin_repository.dart';
import 'package:musee/features/admin_users/domain/usecases/list_users.dart';
import 'package:musee/features/admin_users/domain/usecases/get_user.dart';
import 'package:musee/features/admin_users/domain/usecases/create_user.dart';
import 'package:musee/features/admin_users/domain/usecases/update_user.dart';
import 'package:musee/features/admin_users/domain/usecases/delete_user.dart';
import 'package:musee/features/admin_users/presentation/bloc/admin_users_bloc.dart';
import 'package:musee/features/admin_artists/data/datasources/admin_artists_remote_data_source.dart';
import 'package:musee/features/admin_artists/data/repositories/admin_artists_repository_impl.dart';
import 'package:musee/features/admin_artists/domain/repository/admin_artists_repository.dart';
import 'package:musee/features/admin_artists/domain/usecases/list_artists.dart';
import 'package:musee/features/admin_artists/domain/usecases/get_artist.dart';
import 'package:musee/features/admin_artists/domain/usecases/create_artist.dart';
import 'package:musee/features/admin_artists/domain/usecases/update_artist.dart';
import 'package:musee/features/admin_artists/domain/usecases/delete_artist.dart';
import 'package:musee/features/admin_artists/presentation/bloc/admin_artists_bloc.dart';
import 'package:musee/features/admin_albums/data/datasources/admin_albums_remote_data_source.dart';
import 'package:musee/features/admin_albums/data/repositories/admin_albums_repository_impl.dart';
import 'package:musee/features/admin_albums/domain/repository/admin_albums_repository.dart';
import 'package:musee/features/admin_albums/domain/usecases/list_albums.dart';
import 'package:musee/features/admin_albums/domain/usecases/get_album.dart';
import 'package:musee/features/admin_albums/domain/usecases/create_album.dart';
import 'package:musee/features/admin_albums/domain/usecases/update_album.dart';
import 'package:musee/features/admin_albums/domain/usecases/delete_album.dart';
import 'package:musee/features/admin_albums/presentation/bloc/admin_albums_bloc.dart';
import 'package:musee/features/admin_plans/data/datasources/admin_plans_remote_data_source.dart';
import 'package:musee/features/admin_plans/data/repositories/admin_plans_repository_impl.dart';
import 'package:musee/features/admin_plans/domain/repository/admin_plans_repository.dart';
import 'package:musee/features/admin_plans/domain/usecases/list_plans.dart';
import 'package:musee/features/admin_plans/domain/usecases/get_plan.dart';
import 'package:musee/features/admin_plans/domain/usecases/create_plan.dart';
import 'package:musee/features/admin_plans/domain/usecases/update_plan.dart';
import 'package:musee/features/admin_plans/domain/usecases/delete_plan.dart';
import 'package:musee/features/admin_plans/presentation/bloc/admin_plans_bloc.dart';
import 'package:musee/features/admin_tracks/data/datasources/admin_tracks_remote_data_source.dart';
import 'package:musee/features/admin_tracks/data/repositories/admin_tracks_repository_impl.dart';
import 'package:musee/features/admin_tracks/domain/repository/admin_tracks_repository.dart';
import 'package:musee/features/admin_tracks/domain/usecases/list_tracks.dart';
import 'package:musee/features/admin_tracks/domain/usecases/get_track.dart';
import 'package:musee/features/admin_tracks/domain/usecases/create_track.dart';
import 'package:musee/features/admin_tracks/domain/usecases/update_track.dart';
import 'package:musee/features/admin_tracks/domain/usecases/delete_track.dart';
import 'package:musee/features/admin_tracks/presentation/bloc/admin_tracks_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // Initialize external dependencies first
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );
  serviceLocator.registerLazySingleton(() => supabase.client);
  // Dio for REST backend
  serviceLocator.registerLazySingleton(() => Dio());

  //core
  serviceLocator.registerLazySingleton(() => AppUserCubit());

  //auth
  _initAuth();
  // admin users
  _initAdminUsers();
  // admin artists
  _initAdminArtists();
  // admin albums
  _initAdminAlbums();
  // admin plans
  _initAdminPlans();
  // admin tracks
  _initAdminTracks();
}

void _initAuth() {
  serviceLocator
    // Datasource
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(supabaseClient: serviceLocator()),
    )
    // Repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator()),
    )
    //Use cases
    ..registerFactory(() => UserSignUp(serviceLocator()))
    ..registerFactory(() => UserSignIn(serviceLocator()))
    ..registerFactory(() => GoogleSignIn(serviceLocator()))
    ..registerFactory(() => CurrentUser(serviceLocator()))
    ..registerFactory(() => ResendEmailVerification(serviceLocator()))
    ..registerFactory(() => LogoutUserUsecase(serviceLocator()))
    ..registerFactory(() => SendPasswordResetEmail(serviceLocator()))
    // Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userSignIn: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
        googleSignIn: serviceLocator(),
        resendEmailVerification: serviceLocator(),
        logoutUserUsecase: serviceLocator(),
        sendPasswordResetEmail: serviceLocator(),
      ),
    );
}

void _initAdminUsers() {
  serviceLocator
    // datasource
    ..registerLazySingleton<AdminRemoteDataSource>(
      () => AdminRemoteDataSourceImpl(serviceLocator<Dio>(), serviceLocator()),
    )
    // repository
    ..registerLazySingleton<AdminRepository>(
      () => AdminRepositoryImpl(serviceLocator()),
    )
    // use cases
    ..registerFactory(() => ListUsers(serviceLocator()))
    ..registerFactory(() => GetUser(serviceLocator()))
    ..registerFactory(() => CreateUser(serviceLocator()))
    ..registerFactory(() => UpdateUser(serviceLocator()))
    ..registerFactory(() => DeleteUser(serviceLocator()))
    // bloc
    ..registerFactory(
      () => AdminUsersBloc(
        listUsers: serviceLocator(),
        createUser: serviceLocator(),
        updateUser: serviceLocator(),
        deleteUser: serviceLocator(),
      ),
    );
}

void _initAdminArtists() {
  serviceLocator
    // datasource
    ..registerLazySingleton<AdminArtistsRemoteDataSource>(
      () => AdminArtistsRemoteDataSourceImpl(
        serviceLocator<Dio>(),
        serviceLocator(),
      ),
    )
    // repository
    ..registerLazySingleton<AdminArtistsRepository>(
      () => AdminArtistsRepositoryImpl(serviceLocator()),
    )
    // use cases
    ..registerFactory(() => ListArtists(serviceLocator()))
    ..registerFactory(() => GetArtist(serviceLocator()))
    ..registerFactory(() => CreateArtist(serviceLocator()))
    ..registerFactory(() => UpdateArtist(serviceLocator()))
    ..registerFactory(() => DeleteArtist(serviceLocator()))
    // bloc
    ..registerFactory(
      () => AdminArtistsBloc(
        list: serviceLocator(),
        create: serviceLocator(),
        update: serviceLocator(),
        delete: serviceLocator(),
      ),
    );
}

void _initAdminAlbums() {
  serviceLocator
    // datasource
    ..registerLazySingleton<AdminAlbumsRemoteDataSource>(
      () => AdminAlbumsRemoteDataSourceImpl(
        serviceLocator<Dio>(),
        serviceLocator(),
      ),
    )
    // repository
    ..registerLazySingleton<AdminAlbumsRepository>(
      () => AdminAlbumsRepositoryImpl(serviceLocator()),
    )
    // use cases
    ..registerFactory(() => ListAlbums(serviceLocator()))
    ..registerFactory(() => GetAlbum(serviceLocator()))
    ..registerFactory(() => CreateAlbum(serviceLocator()))
    ..registerFactory(() => UpdateAlbum(serviceLocator()))
    ..registerFactory(() => DeleteAlbum(serviceLocator()))
    // bloc
    ..registerFactory(
      () => AdminAlbumsBloc(
        list: serviceLocator(),
        create: serviceLocator(),
        update: serviceLocator(),
        delete: serviceLocator(),
      ),
    );
}

void _initAdminPlans() {
  serviceLocator
    // datasource
    ..registerLazySingleton<AdminPlansRemoteDataSource>(
      () => AdminPlansRemoteDataSourceImpl(
        serviceLocator<Dio>(),
        serviceLocator(),
      ),
    )
    // repository
    ..registerLazySingleton<AdminPlansRepository>(
      () => AdminPlansRepositoryImpl(serviceLocator()),
    )
    // use cases
    ..registerFactory(() => ListPlans(serviceLocator()))
    ..registerFactory(() => GetPlan(serviceLocator()))
    ..registerFactory(() => CreatePlan(serviceLocator()))
    ..registerFactory(() => UpdatePlan(serviceLocator()))
    ..registerFactory(() => DeletePlan(serviceLocator()))
    // bloc
    ..registerFactory(
      () => AdminPlansBloc(
        list: serviceLocator(),
        create: serviceLocator(),
        update: serviceLocator(),
        delete: serviceLocator(),
      ),
    );
}

void _initAdminTracks() {
  serviceLocator
    // datasource
    ..registerLazySingleton<AdminTracksRemoteDataSource>(
      () => AdminTracksRemoteDataSourceImpl(
        serviceLocator<Dio>(),
        serviceLocator(),
      ),
    )
    // repository
    ..registerLazySingleton<AdminTracksRepository>(
      () => AdminTracksRepositoryImpl(serviceLocator()),
    )
    // use cases
    ..registerFactory(() => ListTracks(serviceLocator()))
    ..registerFactory(() => GetTrack(serviceLocator()))
    ..registerFactory(() => CreateTrack(serviceLocator()))
    ..registerFactory(() => UpdateTrack(serviceLocator()))
    ..registerFactory(() => DeleteTrack(serviceLocator()))
    // bloc
    ..registerFactory(
      () => AdminTracksBloc(
        list: serviceLocator(),
        create: serviceLocator(),
        update: serviceLocator(),
        delete: serviceLocator(),
      ),
    );
}
