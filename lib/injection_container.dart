import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'core/network/api_client.dart';
import 'core/services/cloudinary_service.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/companies/data/datasources/company_remote_datasource.dart';
import 'features/companies/data/repositories/company_repository_impl.dart';
import 'features/companies/domain/repositories/company_repository.dart';
import 'features/companies/domain/usecases/get_companies_usecase.dart';
import 'features/companies/domain/usecases/get_company_by_id_usecase.dart';
import 'features/companies/domain/usecases/get_company_jobs_usecase.dart';
import 'features/companies/domain/usecases/search_companies_usecase.dart';
import 'features/companies/presentation/providers/company_provider.dart';
import 'features/jobs/data/datasources/job_remote_datasource.dart';
import 'features/jobs/data/repositories/job_repository_impl.dart';
import 'features/jobs/domain/repositories/job_repository.dart';
import 'features/jobs/domain/usecases/get_jobs_usecase.dart';
import 'features/jobs/domain/usecases/get_my_applications_usecase.dart';
import 'features/jobs/domain/usecases/get_saved_jobs_usecase.dart';
import 'features/jobs/domain/usecases/save_job_usecase.dart';
import 'features/jobs/domain/usecases/submit_application_usecase.dart';
import 'features/jobs/domain/usecases/unsave_job_usecase.dart';
import 'features/jobs/domain/usecases/unsave_job_by_post_id_usecase.dart';
import 'features/jobs/presentation/providers/job_provider.dart';
import 'features/jobs/presentation/providers/my_jobs_provider.dart';
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/metadata/data/datasources/metadata_remote_datasource.dart';
import 'features/metadata/data/repositories/metadata_repository_impl.dart';
import 'features/metadata/domain/repositories/metadata_repository.dart';
import 'features/metadata/domain/usecases/get_provinces_usecase.dart';

final sl = GetIt.instance; // Service Locator

/// Khởi tạo tất cả dependencies
Future<void> init() async {
  // ========================
  // Features - Auth
  // ========================

  // Providers
  sl.registerFactory(
    () => AuthProvider(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
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

  sl.registerFactory(
    () => MyJobsProvider(
      getSavedJobsUseCase: sl(),
      saveJobUseCase: sl(),
      unsaveJobUseCase: sl(),
      unsaveJobByPostIdUseCase: sl(),
      getMyApplicationsUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetJobsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitApplicationUseCase(sl()));
  sl.registerLazySingleton(() => GetSavedJobsUseCase(sl()));
  sl.registerLazySingleton(() => SaveJobUseCase(sl()));
  sl.registerLazySingleton(() => UnsaveJobUseCase(sl()));
  sl.registerLazySingleton(() => UnsaveJobByPostIdUseCase(sl()));
  sl.registerLazySingleton(() => GetMyApplicationsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<JobRemoteDataSource>(
    () => JobRemoteDataSourceImpl(),
  );

  // ========================
  // Features - Companies
  // ========================

  // Providers
  sl.registerFactory(
    () => CompanyProvider(
      getCompaniesUseCase: sl(),
      getCompanyByIdUseCase: sl(),
      searchCompaniesUseCase: sl(),
      getCompanyJobsUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCompaniesUseCase(sl()));
  sl.registerLazySingleton(() => GetCompanyByIdUseCase(sl()));
  sl.registerLazySingleton(() => SearchCompaniesUseCase(sl()));
  sl.registerLazySingleton(() => GetCompanyJobsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CompanyRemoteDataSource>(
    () => CompanyRemoteDataSourceImpl(jobRemoteDataSource: sl()),
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
  // Features - Metadata
  // ========================

  // Use cases
  sl.registerLazySingleton(() => GetProvincesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<MetadataRepository>(
    () => MetadataRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<MetadataRemoteDataSource>(
    () => MetadataRemoteDataSourceImpl(apiClient: sl()),
  );

  // ========================
  // Core
  // ========================

  // ApiClient
  sl.registerLazySingleton(() => ApiClient(authLocalDataSource: sl()));

  // Flutter Secure Storage
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Cloudinary Service
  sl.registerLazySingleton(() => CloudinaryService());
}
