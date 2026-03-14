# 🏗️ ARCHITECTURE — Job Recruitment System

> **Last Updated:** 2026-03-07

---

## 🛠️ Tech Stack

### Core
| Technology | Version | Vai trò |
|-----------|---------|---------|
| **Flutter** | SDK ^3.10.8 | UI Framework |
| **Dart** | (bundled) | Ngôn ngữ chính |

### Dependencies (pubspec.yaml)
| Package | Version | Vai trò |
|---------|---------|---------|
| `provider` | ^6.1.5+1 | State management (ChangeNotifier) |
| `get_it` | ^9.2.0 | Dependency Injection (Service Locator) |
| `dartz` | ^0.10.1 | Functional programming (Either pattern) |
| `equatable` | ^2.0.8 | Value equality cho Entities |
| `dio` | ^5.9.1 | HTTP client (chưa dùng, sẵn sàng cho API thật) |
| `shared_preferences` | ^2.5.4 | Local storage |
| `flutter_secure_storage` | ^10.0.0 | Lưu token bảo mật |
| `cached_network_image` | ^3.4.1 | Cache ảnh từ network |
| `intl` | ^0.20.2 | Định dạng số, ngày tháng (VN locale) |
| `file_picker` | ^10.3.10 | Chọn file CV (PDF) |
| `http_parser` | ^4.1.2 | Parse HTTP responses |
| `url_launcher` | ^6.3.1 | Mở URL ngoài app |
| `webview_flutter` | ^4.12.0 | Xem PDF trong app (mobile) |

---

## 🏛️ Kiến Trúc Hệ Thống

### Clean Architecture + Feature-First

```
┌─────────────────────────────────────────────────┐
│                PRESENTATION                      │
│  (Pages, Widgets, Providers/ChangeNotifier)      │
├─────────────────────────────────────────────────┤
│                   DOMAIN                         │
│  (Entities, UseCases, Repository Interfaces)     │
├─────────────────────────────────────────────────┤
│                    DATA                          │
│  (Models, DataSources, Repository Impls)         │
└─────────────────────────────────────────────────┘
```

### Data Flow
```
UI (Page) → Provider → UseCase → Repository(interface) → DataSource(mock/API)
     ↑                                                          ↓
     └────────── notifyListeners() ←── Either<Failure, Data> ──┘
```

### Dependency Injection Flow
```dart
// injection_container.dart — Đăng ký theo thứ tự:
1. Provider (registerFactory)           ← tạo mới mỗi lần dùng
2. UseCase (registerLazySingleton)      ← singleton
3. Repository (registerLazySingleton)   ← singleton
4. DataSource (registerLazySingleton)   ← singleton
5. Core services (registerLazySingleton)
```

---

## 📁 Cấu Trúc Thư Mục (76 files)

```
lib/
├── main.dart                          # Entry point, MaterialApp, MultiProvider setup
├── injection_container.dart           # GetIt DI container — đăng ký tất cả dependencies
│
├── core/                              # Shared code dùng chung
│   ├── constants/
│   │   └── api_constants.dart         # Base URL, API endpoints (chuẩn bị cho API thật)
│   ├── error/
│   │   ├── exceptions.dart            # Custom exceptions (ServerException, AuthenticationException)
│   │   └── failures.dart              # Failure classes cho Either pattern
│   ├── network/
│   │   └── (chuẩn bị cho Dio client)
│   ├── pages/
│   │   └── main_page.dart             # BottomNavigationBar + IndexedStack (4 tabs)
│   ├── services/
│   │   └── cloudinary_service.dart    # Upload file lên Cloudinary
│   ├── utils/
│   │   └── (utility functions)
│   └── widgets/
│       ├── custom_button.dart         # Reusable button widget
│       ├── custom_text_field.dart     # Reusable text field widget
│       └── pdf_viewer_page.dart       # In-app PDF viewer (WebView + Google Docs)
│
└── features/
    │
    ├── auth/                          # 🔐 Đăng nhập
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── auth_remote_datasource.dart   # Mock login (email/password)
    │   │   │   └── auth_local_datasource.dart     # Token storage (FlutterSecureStorage)
    │   │   ├── models/
    │   │   │   └── user_model.dart                # UserModel (fromJson/toJson + token)
    │   │   └── repositories/
    │   │       └── auth_repository_impl.dart      # Impl: login + saveToken
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── user_entity.dart               # UserEntity (11 fields)
    │   │   ├── repositories/
    │   │   │   └── auth_repository.dart            # Abstract interface
    │   │   └── usecases/
    │   │       └── login_usecase.dart              # LoginUseCase
    │   └── presentation/
    │       ├── pages/
    │       │   └── login_page.dart                 # Login UI → navigate to MainPage
    │       └── providers/
    │           └── auth_provider.dart              # AuthProvider (login state)
    │
    ├── jobs/                          # 💼 Việc làm (module lớn nhất)
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── job_remote_datasource.dart      # Mock: 9 methods, ~530 lines
    │   │   ├── models/
    │   │   │   ├── job_post_model.dart             # JobPostModel (24 fields)
    │   │   │   ├── saved_job_model.dart            # SavedJobModel (14 fields)
    │   │   │   └── application_model.dart          # ApplicationModel (11 fields)
    │   │   └── repositories/
    │   │       └── job_repository_impl.dart        # Impl cho tất cả job operations
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── job_post_entity.dart            # JobPostEntity (24 fields)
    │   │   │   ├── saved_job_entity.dart           # SavedJobEntity (14 fields)
    │   │   │   └── application_entity.dart         # ApplicationEntity (11 fields)
    │   │   ├── models/
    │   │   │   └── job_filter_model.dart           # Filter model: keyword, city, salary...
    │   │   ├── repositories/
    │   │   │   └── job_repository.dart             # Abstract interface (9 methods)
    │   │   └── usecases/
    │   │       ├── get_jobs_usecase.dart
    │   │       ├── submit_application_usecase.dart
    │   │       ├── get_saved_jobs_usecase.dart
    │   │       ├── save_job_usecase.dart
    │   │       ├── unsave_job_usecase.dart
    │   │       ├── unsave_job_by_post_id_usecase.dart
    │   │       └── get_my_applications_usecase.dart
    │   └── presentation/
    │       ├── pages/
    │       │   ├── home_page.dart                  # Tab 1: Danh sách jobs + search button
    │       │   ├── job_detail_page.dart            # Chi tiết job + nút Apply/Save
    │       │   ├── search_page.dart                # Tìm kiếm + lọc jobs
    │       │   └── my_jobs_page.dart               # Tab 3: Saved + Applied tabs
    │       ├── providers/
    │       │   ├── job_provider.dart               # Jobs list + apply logic
    │       │   └── my_jobs_provider.dart           # Saved jobs + applications
    │       └── widgets/
    │           ├── job_card.dart                   # Card hiển thị job (có nút save ❤️)
    │           ├── saved_job_card.dart             # Card saved job (có onTap → detail)
    │           ├── applied_job_card.dart           # Card applied job (status badge)
    │           └── apply_bottom_sheet.dart         # Bottom sheet ứng tuyển
    │
    ├── companies/                     # 🏢 Công ty
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── company_remote_datasource.dart  # Mock: 4 methods
    │   │   ├── models/
    │   │   │   └── company_model.dart              # CompanyModel (13 fields)
    │   │   └── repositories/
    │   │       └── company_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── company_entity.dart             # CompanyEntity (13 fields)
    │   │   ├── repositories/
    │   │   │   └── company_repository.dart
    │   │   └── usecases/
    │   │       ├── get_companies_usecase.dart
    │   │       ├── get_company_by_id_usecase.dart
    │   │       ├── search_companies_usecase.dart
    │   │       └── get_company_jobs_usecase.dart
    │   └── presentation/
    │       ├── pages/
    │       │   ├── companies_page.dart             # Tab 2: List/Grid + search
    │       │   └── company_detail_page.dart        # Chi tiết + tab info/jobs
    │       ├── providers/
    │       │   └── company_provider.dart
    │       └── widgets/
    │           ├── company_card.dart               # Grid card
    │           ├── company_list_tile.dart           # List tile
    │           ├── company_info_tab.dart            # Tab thông tin công ty
    │           └── company_jobs_tab.dart            # Tab việc làm của công ty
    │
    └── profile/                       # 👤 Hồ sơ ứng viên
        ├── data/
        │   ├── datasources/
        │   │   └── profile_remote_datasource.dart  # Mock profile data
        │   ├── models/
        │   │   ├── candidate_profile_model.dart    # Profile model (22+ fields)
        │   │   ├── work_experience_model.dart      # Sub-model
        │   │   ├── education_model.dart            # Sub-model
        │   │   ├── certificate_model.dart          # Sub-model
        │   │   └── language_model.dart             # Sub-model
        │   └── repositories/
        │       └── profile_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   ├── candidate_profile_entity.dart   # Main entity (USERS + CANDIDATES)
        │   │   ├── work_experience_entity.dart     # Kinh nghiệm làm việc
        │   │   ├── education_entity.dart           # Học vấn
        │   │   ├── certificate_entity.dart         # Chứng chỉ
        │   │   └── language_entity.dart            # Ngôn ngữ
        │   ├── repositories/
        │   │   └── profile_repository.dart         # Interface (getProfile, updateProfile, uploadCV)
        │   └── usecases/
        │       ├── get_profile_usecase.dart
        │       └── update_profile_usecase.dart
        └── presentation/
            ├── pages/
            │   ├── profile_page.dart               # Tab 4: Hiển thị đầy đủ profile
            │   └── edit_profile_page.dart           # Form chỉnh sửa profile (~1000 lines)
            └── providers/
                └── profile_provider.dart            # Profile state + CV upload
```

---

## 📊 Data Models (JSON Schema)

### 1. UserEntity / UserModel
> Bảng: `USERS`

| Field | Type | Required | JSON Key | Enum Values |
|-------|------|----------|----------|-------------|
| userId | `int` | ✅ | `user_id` | |
| email | `String` | ✅ | `email` | |
| phone | `String?` | ❌ | `phone` | |
| fullName | `String` | ✅ | `full_name` | |
| avatarUrl | `String?` | ❌ | `avatar_url` | |
| userType | `String` | ✅ | `user_type` | `candidate`, `employer`, `admin` |
| status | `String` | ✅ | `status` | `active`, `locked`, `pending` |
| emailVerified | `bool` | ✅ | `email_verified` | |
| createdAt | `DateTime` | ✅ | `created_at` | ISO 8601 |
| updatedAt | `DateTime` | ✅ | `updated_at` | ISO 8601 |
| lastLogin | `DateTime?` | ❌ | `last_login` | ISO 8601 |
| token | `String` | ✅ | `token` | JWT (chỉ trong Model, không có trong Entity) |

---

### 2. JobPostEntity / JobPostModel
> Bảng: `JOB_POSTS` (join với `EMPLOYERS`, `CITIES`, `INDUSTRIES`)

| Field | Type | Required | JSON Key | Enum Values |
|-------|------|----------|----------|-------------|
| jobPostId | `int` | ✅ | `job_post_id` | |
| employerId | `int` | ✅ | `employer_id` | |
| title | `String` | ✅ | `title` | |
| description | `String` | ✅ | `description` | |
| requirements | `String` | ✅ | `requirements` | |
| benefits | `String` | ✅ | `benefits` | |
| jobType | `String` | ✅ | `job_type` | `fulltime`, `parttime`, `remote`, `freelance` |
| jobLevel | `String` | ✅ | `job_level` | `intern`, `fresher`, `junior`, `middle`, `senior`, `leader`, `manager` |
| salaryMin | `int?` | ❌ | `salary_min` | |
| salaryMax | `int?` | ❌ | `salary_max` | |
| salaryType | `String` | ✅ | `salary_type` | `VND`, `USD`, `negotiable` |
| numberOfPositions | `int` | ✅ | `number_of_positions` | |
| experienceRequired | `int` | ✅ | `experience_required` | (năm) |
| educationRequired | `String?` | ❌ | `education_required` | |
| address | `String?` | ❌ | `address` | |
| deadline | `DateTime` | ✅ | `deadline` | ISO 8601 |
| status | `String` | ✅ | `status` | `pending`, `approved`, `rejected`, `closed`, `expired` |
| isPriority | `bool` | ✅ | `is_priority` | |
| viewCount | `int` | ✅ | `view_count` | |
| applicationCount | `int` | ✅ | `application_count` | |
| createdAt | `DateTime` | ✅ | `created_at` | ISO 8601 |
| updatedAt | `DateTime` | ✅ | `updated_at` | ISO 8601 |
| companyName | `String` | ✅ | `company_name` | (từ JOIN) |
| companyLogo | `String?` | ❌ | `company_logo` | (từ JOIN) |
| cityName | `String` | ✅ | `city_name` | (từ JOIN) |
| industryName | `String` | ✅ | `industry_name` | (từ JOIN) |

---

### 3. SavedJobEntity / SavedJobModel
> Bảng: `SAVED_JOBS` (join với `JOB_POSTS`)

| Field | Type | Required | JSON Key |
|-------|------|----------|----------|
| savedJobId | `int` | ✅ | `saved_job_id` |
| candidateId | `int` | ✅ | `candidate_id` |
| jobPostId | `int` | ✅ | `job_post_id` |
| createdAt | `DateTime` | ✅ | `created_at` |
| jobTitle | `String?` | ❌ | `job_title` |
| companyName | `String?` | ❌ | `company_name` |
| companyLogo | `String?` | ❌ | `company_logo` |
| cityName | `String?` | ❌ | `city_name` |
| salaryMin | `int?` | ❌ | `salary_min` |
| salaryMax | `int?` | ❌ | `salary_max` |
| salaryType | `String?` | ❌ | `salary_type` |
| jobType | `String?` | ❌ | `job_type` |
| jobLevel | `String?` | ❌ | `job_level` |
| deadline | `DateTime?` | ❌ | `deadline` |

---

### 4. ApplicationEntity / ApplicationModel
> Bảng: `APPLICATIONS` (join với `JOB_POSTS`)

| Field | Type | Required | JSON Key | Enum Values |
|-------|------|----------|----------|-------------|
| applicationId | `int?` | ❌ | `application_id` | |
| jobPostId | `int` | ✅ | `job_post_id` | |
| candidateId | `int` | ✅ | `candidate_id` | |
| cvFileUrl | `String?` | ❌ | `cv_file_url` | |
| coverLetter | `String?` | ❌ | `cover_letter` | |
| status | `String` | ✅ | `status` | `submitted`, `viewed`, `interview_scheduled`, `rejected`, `hired` |
| appliedAt | `DateTime` | ✅ | `applied_at` | ISO 8601 |
| viewedAt | `DateTime?` | ❌ | `viewed_at` | ISO 8601 |
| updatedAt | `DateTime?` | ❌ | `updated_at` | ISO 8601 |
| jobTitle | `String?` | ❌ | `job_title` | (từ JOIN) |
| companyName | `String?` | ❌ | `company_name` | (từ JOIN) |

---

### 5. CandidateProfileEntity / CandidateProfileModel
> Bảng: `USERS` + `CANDIDATES` + sub-entities

| Field | Type | Required | JSON Key |
|-------|------|----------|----------|
| userId | `int` | ✅ | `user_id` |
| email | `String` | ✅ | `email` |
| phone | `String?` | ❌ | `phone` |
| fullName | `String` | ✅ | `full_name` |
| avatarUrl | `String?` | ❌ | `avatar_url` |
| candidateId | `int` | ✅ | `candidate_id` |
| dateOfBirth | `DateTime?` | ❌ | `date_of_birth` |
| gender | `String?` | ❌ | `gender` |
| address | `String?` | ❌ | `address` |
| cityName | `String?` | ❌ | `city_name` |
| educationLevel | `String?` | ❌ | `education_level` |
| yearsOfExperience | `int` | ✅ | `years_of_experience` |
| currentJobTitle | `String?` | ❌ | `current_job_title` |
| desiredJobTitle | `String?` | ❌ | `desired_job_title` |
| desiredSalaryMin | `int?` | ❌ | `desired_salary_min` |
| desiredSalaryMax | `int?` | ❌ | `desired_salary_max` |
| desiredJobType | `String?` | ❌ | `desired_job_type` |
| skills | `List<String>` | ✅ | `skills` |
| cvFileUrl | `String?` | ❌ | `cv_file_url` |
| industry | `String?` | ❌ | `industry` |
| isSearchable | `bool` | ✅ | `is_searchable` |
| workExperiences | `List<WorkExperience>` | ✅ | `work_experiences` |
| educations | `List<Education>` | ✅ | `educations` |
| certificates | `List<Certificate>` | ✅ | `certificates` |
| languages | `List<Language>` | ✅ | `languages` |
| createdAt | `DateTime` | ✅ | `created_at` |
| updatedAt | `DateTime` | ✅ | `updated_at` |

**Sub-entities:** `WorkExperienceEntity` (id, companyName, position, startDate, endDate, description, isCurrentJob), `EducationEntity` (id, institution, degree, fieldOfStudy, startDate, endDate, description), `CertificateEntity` (id, name, issuingOrganization, issueDate, expirationDate, credentialUrl), `LanguageEntity` (id, name, proficiency)

---

### 6. CompanyEntity / CompanyModel
> Bảng: `EMPLOYERS`

| Field | Type | Required | JSON Key |
|-------|------|----------|----------|
| employerId | `int` | ✅ | `employer_id` |
| companyName | `String` | ✅ | `company_name` |
| logoUrl | `String?` | ❌ | `logo_url` |
| coverImageUrl | `String?` | ❌ | `cover_image_url` |
| industryName | `String?` | ❌ | `industry_name` |
| companySize | `String?` | ❌ | `company_size` |
| website | `String?` | ❌ | `website` |
| description | `String?` | ❌ | `description` |
| address | `String?` | ❌ | `address` |
| cityName | `String?` | ❌ | `city_name` |
| benefits | `String?` | ❌ | `benefits` |
| foundedYear | `int?` | ❌ | `founded_year` |
| jobCount | `int` | ✅ | `job_count` |
