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
import 'features/auth/domain/usecases/get_status_usecase.dart';
import 'features/auth/domain/usecases/register_employer_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/verify_email_usecase.dart';
import 'features/auth/domain/usecases/resend_verification_usecase.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/reset_password_usecase.dart';
import 'features/auth/domain/usecases/change_password_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/companies/data/datasources/company_remote_datasource.dart';
import 'features/companies/data/repositories/company_repository_impl.dart';
import 'features/companies/domain/repositories/company_repository.dart';
import 'features/companies/domain/usecases/get_companies_usecase.dart';
import 'features/companies/domain/usecases/get_company_by_id_usecase.dart';
import 'features/companies/domain/usecases/get_company_jobs_usecase.dart';
import 'features/companies/domain/usecases/search_companies_usecase.dart';
import 'features/companies/domain/usecases/update_company_usecase.dart';
import 'features/companies/domain/usecases/upload_company_banner_usecase.dart';
import 'features/companies/domain/usecases/upload_company_logo_usecase.dart';
import 'features/companies/domain/usecases/upload_company_gallery_image_usecase.dart';
import 'features/companies/domain/usecases/upload_company_business_license_usecase.dart';
import 'features/companies/presentation/providers/company_provider.dart';
import 'features/jobs/data/datasources/job_remote_datasource.dart';
import 'features/jobs/data/repositories/job_repository_impl.dart';
import 'features/jobs/domain/repositories/job_repository.dart';
import 'features/jobs/domain/usecases/get_jobs_usecase.dart';
import 'features/jobs/domain/usecases/get_my_applications_usecase.dart' as job_usecase;
import 'features/jobs/domain/usecases/get_saved_jobs_usecase.dart';
import 'features/jobs/domain/usecases/save_job_usecase.dart';
import 'features/jobs/domain/usecases/submit_application_usecase.dart';
import 'features/jobs/domain/usecases/unsave_job_usecase.dart';
import 'features/jobs/domain/usecases/unsave_job_by_post_id_usecase.dart';
import 'features/jobs/domain/usecases/create_job_usecase.dart';
import 'features/jobs/domain/usecases/update_job_usecase.dart';
import 'features/jobs/domain/usecases/get_employer_jobs_usecase.dart';
import 'features/jobs/domain/usecases/get_job_detail_usecase.dart';
import 'features/jobs/domain/usecases/get_job_history_usecase.dart';
import 'features/jobs/presentation/providers/job_provider.dart';
import 'features/jobs/presentation/providers/my_jobs_provider.dart';
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/domain/usecases/parse_cv_usecase.dart';
import 'features/profile/domain/usecases/update_visibility_usecase.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/metadata/data/datasources/metadata_remote_datasource.dart';
import 'features/metadata/data/repositories/metadata_repository_impl.dart';
import 'features/metadata/domain/repositories/metadata_repository.dart';
import 'features/metadata/domain/usecases/get_provinces_usecase.dart';
import 'features/metadata/domain/usecases/get_job_categories_usecase.dart';
import 'features/employer/data/datasources/employer_remote_datasource.dart';
import 'features/employer/data/repositories/employer_repository_impl.dart';
import 'features/employer/domain/repositories/employer_repository.dart';
import 'features/employer/domain/usecases/employer_usecases.dart';
import 'features/employer/presentation/providers/employer_provider.dart';
import 'features/applications/data/datasources/application_remote_datasource.dart';
import 'features/applications/data/datasources/employer_application_remote_datasource.dart';
import 'features/applications/data/repositories/application_repository_impl.dart';
import 'features/applications/domain/repositories/application_repository.dart';
import 'features/applications/domain/usecases/apply_job_usecase.dart';
import 'features/applications/domain/usecases/get_my_applications_usecase.dart';
import 'features/applications/domain/usecases/get_application_detail_usecase.dart';
import 'features/applications/domain/usecases/withdraw_application_usecase.dart';
import 'features/applications/domain/usecases/get_job_applications_usecase.dart';
import 'features/applications/domain/usecases/get_kanban_board_usecase.dart';
import 'features/applications/domain/usecases/get_employer_application_detail_usecase.dart';
import 'features/applications/domain/usecases/get_application_status_history_usecase.dart';
import 'features/applications/domain/usecases/update_application_status_usecase.dart';
import 'features/applications/domain/usecases/add_application_note_usecase.dart';
import 'features/applications/domain/usecases/update_application_note_usecase.dart';
import 'features/applications/presentation/providers/application_provider.dart';
import 'features/applications/presentation/providers/employer_application_provider.dart';
import 'features/headhunting/data/datasources/headhunting_remote_datasource.dart';
import 'features/headhunting/data/repositories/headhunting_repository_impl.dart';
import 'features/headhunting/domain/repositories/headhunting_repository.dart';
import 'features/headhunting/domain/usecases/get_suggested_candidates_usecase.dart';
import 'features/headhunting/domain/usecases/search_candidates_usecase.dart';
import 'features/headhunting/domain/usecases/get_candidate_detail_usecase.dart';
import 'features/headhunting/domain/usecases/get_candidate_invitations_usecase.dart';
import 'features/headhunting/domain/usecases/accept_invitation_usecase.dart';
import 'features/headhunting/domain/usecases/decline_invitation_usecase.dart';
import 'features/headhunting/domain/usecases/send_invitation_usecase.dart';
import 'features/headhunting/domain/usecases/get_employer_invitations_usecase.dart';
import 'features/headhunting/domain/usecases/save_candidate_usecase.dart';
import 'features/headhunting/domain/usecases/unsave_candidate_usecase.dart';
import 'features/headhunting/domain/usecases/get_saved_candidates_usecase.dart';
import 'features/headhunting/presentation/providers/headhunting_provider.dart';
import 'features/headhunting/presentation/providers/candidate_search_provider.dart';
import 'features/notifications/data/datasources/notification_remote_datasource.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/notifications/domain/usecases/notification_usecases.dart';
import 'features/notifications/presentation/providers/notification_provider.dart';

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
      registerEmployerUseCase: sl(),
      logoutUseCase: sl(),
      verifyEmailUseCase: sl(),
      resendVerificationUseCase: sl(),
      getStatusUseCase: sl(),
      forgotPasswordUseCase: sl(),
      resetPasswordUseCase: sl(),
      changePasswordUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => RegisterEmployerUseCase(repository: sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailUseCase(sl()));
  sl.registerLazySingleton(() => ResendVerificationUseCase(sl()));
  sl.registerLazySingleton(() => GetStatusUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));

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
    () => JobProvider(
      getJobsUseCase: sl(),
      submitApplicationUseCase: sl(),
      createJobUseCase: sl(),
      updateJobUseCase: sl(),
      getEmployerJobsUseCase: sl(),
      getJobDetailUseCase: sl(),
      getJobHistoryUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => MyJobsProvider(
      getSavedJobsUseCase: sl(),
      saveJobUseCase: sl(),
      unsaveJobUseCase: sl(),
      unsaveJobByPostIdUseCase: sl(),
      getMyApplicationsUseCase: sl<job_usecase.GetMyApplicationsUseCase>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetJobsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitApplicationUseCase(sl()));
  sl.registerLazySingleton(() => GetSavedJobsUseCase(sl()));
  sl.registerLazySingleton(() => SaveJobUseCase(sl()));
  sl.registerLazySingleton(() => UnsaveJobUseCase(sl()));
  sl.registerLazySingleton(() => UnsaveJobByPostIdUseCase(sl()));
  sl.registerLazySingleton(() => job_usecase.GetMyApplicationsUseCase(sl()));

  sl.registerLazySingleton(() => CreateJobUseCase(sl()));
  sl.registerLazySingleton(() => UpdateJobUseCase(sl()));
  sl.registerLazySingleton(() => GetEmployerJobsUseCase(sl()));
  sl.registerLazySingleton(() => GetJobDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetJobHistoryUseCase(sl()));

  // Repository
  sl.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<JobRemoteDataSource>(
    () => JobRemoteDataSourceImpl(apiClient: sl()),
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
  sl.registerLazySingleton(() => UpdateCompanyUseCase(sl()));
  sl.registerLazySingleton(() => UploadCompanyLogoUseCase(sl()));
  sl.registerLazySingleton(() => UploadCompanyBannerUseCase(sl()));
  sl.registerLazySingleton(() => UploadCompanyGalleryImageUseCase(sl()));
  sl.registerLazySingleton(() => UploadCompanyBusinessLicenseUseCase(sl()));

  // Repository
  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CompanyRemoteDataSource>(
    () => CompanyRemoteDataSourceImpl(apiClient: sl()),
  );

  // ========================
  // Features - Profile
  // ========================

  // Providers
  sl.registerFactory(
    () => ProfileProvider(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      updateVisibilityUseCase: sl(),
      profileRepository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => ParseCvUseCase(sl()));
  sl.registerLazySingleton(() => UpdateVisibilityUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () =>
        ProfileRepositoryImpl(remoteDataSource: sl(), cloudinaryService: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: sl()),
  );

  // ========================
  // Features - Metadata
  // ========================

  // Use cases
  sl.registerLazySingleton(() => GetProvincesUseCase(sl()));
  sl.registerLazySingleton(() => GetJobCategoriesUseCase(sl()));

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

  // ========================
  // Features - Employer
  // ========================

  // Providers
  sl.registerFactory(
    () => EmployerProvider(
      getEmployerProfileUseCase: sl(),
      setupCompanyUseCase: sl(),
      updateEmployerProfileUseCase: sl(),
      uploadEmployerAvatarUseCase: sl(),
      updateCompanyUseCase: sl(),
      uploadCompanyLogoUseCase: sl(),
      uploadCompanyBannerUseCase: sl(),
      uploadCompanyGalleryImageUseCase: sl(),
      uploadCompanyBusinessLicenseUseCase: sl(),
      getMembersUseCase: sl(),
      addMemberUseCase: sl(),
      removeMemberUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetEmployerProfileUseCase(sl()));
  sl.registerLazySingleton(() => SetupCompanyUseCase(sl()));
  sl.registerLazySingleton(() => UpdateEmployerProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadEmployerAvatarUseCase(sl()));
  sl.registerLazySingleton(() => GetMembersUseCase(sl()));
  sl.registerLazySingleton(() => AddMemberUseCase(sl()));
  sl.registerLazySingleton(() => RemoveMemberUseCase(sl()));

  // Repository
  sl.registerLazySingleton<EmployerRepository>(
    () => EmployerRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<EmployerRemoteDataSource>(
    () => EmployerRemoteDataSourceImpl(apiClient: sl()),
  );

  // ========================
  // Features - Applications
  // ========================

  // Providers
  sl.registerFactory(
    () => ApplicationProvider(
      applyJobUseCase: sl(),
      getMyApplicationsUseCase: sl(),
      getApplicationDetailUseCase: sl(),
      withdrawApplicationUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => EmployerApplicationProvider(
      getJobApplicationsUseCase: sl(),
      getKanbanBoardUseCase: sl(),
      getEmployerApplicationDetailUseCase: sl(),
      getApplicationStatusHistoryUseCase: sl(),
      updateApplicationStatusUseCase: sl(),
      addApplicationNoteUseCase: sl(),
      updateApplicationNoteUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => ApplyJobUseCase(sl()));
  sl.registerLazySingleton(() => GetMyApplicationsUseCase(sl()));
  sl.registerLazySingleton(() => GetApplicationDetailUseCase(sl()));
  sl.registerLazySingleton(() => WithdrawApplicationUseCase(sl()));
  sl.registerLazySingleton(() => GetJobApplicationsUseCase(sl()));
  sl.registerLazySingleton(() => GetKanbanBoardUseCase(sl()));
  sl.registerLazySingleton(() => GetEmployerApplicationDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetApplicationStatusHistoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateApplicationStatusUseCase(sl()));
  sl.registerLazySingleton(() => AddApplicationNoteUseCase(sl()));
  sl.registerLazySingleton(() => UpdateApplicationNoteUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ApplicationRepository>(
    () => ApplicationRepositoryImpl(
      remoteDataSource: sl(),
      employerRemoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ApplicationRemoteDataSource>(
    () => ApplicationRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<EmployerApplicationRemoteDataSource>(
    () => EmployerApplicationRemoteDataSourceImpl(sl()),
  );

  // ========================
  // Features - Headhunting
  // ========================

  // Providers
  sl.registerLazySingleton(
    () => HeadhuntingProvider(
      getSuggestedCandidatesUseCase: sl(),
      getCandidateDetailUseCase: sl(),
      sendInvitationUseCase: sl(),
      getCandidateInvitationsUseCase: sl(),
      acceptInvitationUseCase: sl(),
      declineInvitationUseCase: sl(),
      getJobApplicationsUseCase: sl(),
      getEmployerInvitationsUseCase: sl(),
      saveCandidateUseCase: sl(),
      unsaveCandidateUseCase: sl(),
      getSavedCandidatesUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => CandidateSearchProvider(
      searchCandidatesUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSuggestedCandidatesUseCase(sl()));
  sl.registerLazySingleton(() => SearchCandidatesUseCase(sl()));
  sl.registerLazySingleton(() => GetCandidateDetailUseCase(sl()));
  sl.registerLazySingleton(() => SendInvitationUseCase(sl()));
  sl.registerLazySingleton(() => GetCandidateInvitationsUseCase(sl()));
  sl.registerLazySingleton(() => AcceptInvitationUseCase(sl()));
  sl.registerLazySingleton(() => DeclineInvitationUseCase(sl()));
  sl.registerLazySingleton(() => GetEmployerInvitationsUseCase(sl()));
  sl.registerLazySingleton(() => SaveCandidateUseCase(repository: sl()));
  sl.registerLazySingleton(() => UnsaveCandidateUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetSavedCandidatesUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<HeadhuntingRepository>(
    () => HeadhuntingRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<HeadhuntingRemoteDataSource>(
    () => HeadhuntingRemoteDataSourceImpl(apiClient: sl()),
  );

  // ========================
  // Features - Notifications
  // ========================

  // Providers
  sl.registerLazySingleton(
    () => NotificationProvider(
      getNotificationsUseCase: sl(),
      getUnreadCountUseCase: sl(),
      markAsReadUseCase: sl(),
      markAllReadUseCase: sl(),
      authLocalDataSource: sl(),
      apiClient: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => GetUnreadCountUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllReadUseCase(sl()));

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );
}
