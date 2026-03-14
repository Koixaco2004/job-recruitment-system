# 📋 PROJECT MEMORY — Job Recruitment System

> **Last Updated:** 2026-03-07  
> **Project Path:** `d:\testFultter\test1`  
> **Repository:** `Koixaco2004/job-recruitment-system`

---

## 🎯 Tổng Quan Dự Án (Project Overview)

### Mục tiêu cốt lõi
Ứng dụng **tuyển dụng việc làm** dành cho **ứng viên (candidate)**, cho phép:
- Đăng nhập và quản lý hồ sơ cá nhân
- Tìm kiếm, lọc và xem chi tiết việc làm
- Lưu việc làm yêu thích và ứng tuyển trực tuyến
- Upload CV (PDF) lên Cloudinary
- Xem danh sách và chi tiết công ty
- Quản lý lịch sử ứng tuyển và việc đã lưu

### Trạng thái hiện tại
- **Frontend:** Flutter (Dart) — hoàn thiện giao diện và logic cho 4 tab chính
- **Backend:** Chưa có. App đang dùng **mock data** trong DataSource layer
- **Data:** Tất cả dữ liệu đều là mock, nằm trong các file `*_remote_datasource.dart`

### Tài khoản test (Mock)
| Email | Password | Role |
|-------|----------|------|
| `candidate@test.com` | (bất kỳ) | Ứng viên |
| `employer@test.com` | (bất kỳ) | Nhà tuyển dụng |

---

## 📐 Quy Tắc Code (Coding Conventions)

### 1. Kiến trúc: Clean Architecture + Feature-First
```
feature/
├── data/          ← Implementation (models, datasources, repositories)
├── domain/        ← Business logic (entities, usecases, repository interfaces)
└── presentation/  ← UI (pages, providers, widgets)
```

### 2. State Management: Provider + ChangeNotifier
- Mỗi feature có 1-2 `ChangeNotifier` providers
- Provider được inject qua `GetIt` (service locator) tại `injection_container.dart`
- Provider gọi `UseCase` → `Repository` → `DataSource`

### 3. Error Handling: Either Pattern (dartz)
```dart
// Repository trả về Either<Failure, SuccessType>
Future<Either<Failure, List<JobPostEntity>>> getJobs();

// Provider xử lý:
result.fold(
  (failure) => _errorMessage = failure.message,
  (data) => _jobs = data,
);
```

### 4. Naming Conventions
| Loại | Convention | Ví dụ |
|------|-----------|-------|
| Entity | `*Entity` | `JobPostEntity`, `UserEntity` |
| Model | `*Model` extends Entity | `JobPostModel`, `UserModel` |
| UseCase | Verb + Noun + `UseCase` | `GetJobsUseCase`, `SaveJobUseCase` |
| Provider | Feature + `Provider` | `JobProvider`, `MyJobsProvider` |
| Repository | Feature + `Repository` | `JobRepository`, `AuthRepository` |
| DataSource | Feature + `RemoteDataSource` | `JobRemoteDataSource` |
| JSON keys | `snake_case` | `job_post_id`, `company_name` |
| Dart fields | `camelCase` | `jobPostId`, `companyName` |

### 5. API Response JSON Convention (đã thống nhất)
- Tất cả JSON key dùng `snake_case`
- DateTime luôn là ISO 8601 string: `"2024-01-15T00:00:00Z"`
- ID fields luôn là `int`
- Optional fields có thể `null` trong JSON
- List fields trả về `[]` thay vì `null` khi rỗng

### 6. Quy tắc Navigation
- **Các page trong Bottom Nav:** Dùng `IndexedStack`, KHÔNG dùng `Navigator.push/pop`
- **Các page chi tiết (detail/edit):** Dùng `Navigator.push` → có back button tự động
- **KHÔNG BAO GIỜ** dùng `Navigator.popUntil` trong bottom nav context
- Chuyển tab trong bottom nav: dùng `MainPage.switchTab(context, index)`
- Các trang trong bottom nav phải có `automaticallyImplyLeading: false` trong AppBar

### 7. Mock Data Pattern
```dart
// Abstract interface (contract)
abstract class FeatureRemoteDataSource {
  Future<List<Model>> getData();
}

// Mock implementation (sẽ thay bằng API thật sau)
class FeatureRemoteDataSourceImpl implements FeatureRemoteDataSource {
  @override
  Future<List<Model>> getData() async {
    await Future.delayed(const Duration(seconds: 1)); // Giả lập network delay
    return [/* mock data */];
  }
}
```
Khi có API thật, chỉ cần thay đổi phần `Impl`, không ảnh hưởng domain/presentation.

### 8. Thứ tự tích hợp API (đã thống nhất)
```
1. POST /api/auth/login              ← làm trước
2. GET  /api/profile                 ← làm tiếp (cần candidateId thật)
3. GET  /api/jobs                    ← làm sau
4. GET  /api/companies               ← làm sau
5. Các API còn lại (save, apply...)  ← cuối cùng
```
Khi chỉ có API login thật, các mock khác vẫn hoạt động bình thường (kiến trúc tách biệt).

---

## 📌 Các Điểm Quan Trọng Cần Nhớ

1. **`candidateId` fallback:** Code sử dụng `profileProvider.profile?.candidateId ?? 1` — luôn fallback về 1 khi chưa có profile thật
2. **Auto-refresh MyJobs:** `MainPage._onTabTapped(2)` tự động gọi `fetchSavedJobs` + `fetchApplications` khi chuyển sang tab "Việc của tôi"
3. **Mock enrichment:** `saveJob()` và `submitApplication()` đã được sửa để trả về đầy đủ job details (không chỉ IDs)
4. **PDF Viewer:** Trên mobile dùng `PdfViewerPage` (WebView + Google Docs Viewer), trên web dùng `url_launcher`
5. **CV Upload:** Dùng `file_picker` + `CloudinaryService` — hỗ trợ cả web và mobile
6. **DI Container:** `injection_container.dart` quản lý tất cả dependencies — khi thêm feature mới phải đăng ký ở đây
