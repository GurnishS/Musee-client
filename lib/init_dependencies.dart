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
