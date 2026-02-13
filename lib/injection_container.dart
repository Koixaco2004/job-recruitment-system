import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'core/services/cloudinary_service.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/jobs/data/datasources/job_remote_datasource.dart';
import 'features/jobs/data/repositories/job_repository_impl.dart';
import 'features/jobs/domain/repositories/job_repository.dart';
import 'features/jobs/domain/usecases/get_jobs_usecase.dart';
import 'features/jobs/domain/usecases/submit_application_usecase.dart';
import 'features/jobs/presentation/providers/job_provider.dart';
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/presentation/providers/profile_provider.dart';

final sl = GetIt.instance; // Service Locator

/// Khởi tạo tất cả dependencies
Future<void> init() async {
  // ========================
  // Features - Auth
  // ========================

  // Providers
  sl.registerFactory(() => AuthProvider(loginUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );

  // ========================
  // Features - Jobs
  // ========================

  // Providers
  sl.registerFactory(
    () => JobProvider(getJobsUseCase: sl(), submitApplicationUseCase: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetJobsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitApplicationUseCase(sl()));

  // Repository
  sl.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<JobRemoteDataSource>(
    () => JobRemoteDataSourceImpl(),
  );

  // ========================
  // Features - Profile
  // ========================

  // Providers
  sl.registerFactory(
    () => ProfileProvider(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      profileRepository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () =>
        ProfileRepositoryImpl(remoteDataSource: sl(), cloudinaryService: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(),
  );

  // ========================
  // Core
  // ========================

  // Flutter Secure Storage
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Cloudinary Service
  sl.registerLazySingleton(() => CloudinaryService());
}
