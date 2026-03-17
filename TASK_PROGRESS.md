# 📊 TASK PROGRESS — Job Recruitment System

> **Last Updated:** 2026-03-17

---

## ✅ Tính Năng Đã Hoàn Thành

### 🔐 1. Authentication (Đăng nhập / Đăng ký)
- [x] Login page UI (email + password form)
- [x] Mock login với 2 tài khoản test (`candidate@test.com`, `employer@test.com`)
- [x] JWT token lưu vào `FlutterSecureStorage`
- [x] Login → navigate to `MainPage`
- [x] Error handling (email sai, loading state)
- [x] **RegisterPage UI cho ứng viên** kèm form validation đầy đủ (Họ tên, Email, Passwords)
- [x] Mock register flow (trả về user mới, lưu token, tự động login và vào `MainPage`)
- [x] Refactor Auth Layer theo Clean Architecture (`RegisterUseCase`, `AuthRepository`)
- **Files:** `login_page.dart`, `register_page.dart`, `auth_provider.dart`, `auth_remote_datasource.dart`

### 💼 2. Job Listing (Danh sách việc làm)
- [x] Homepage hiển thị danh sách jobs (RefreshIndicator)
- [x] Loading, error, empty states
- [x] JobCard widget với nút save ❤️ (toggle save/unsave)
- [x] Pull-to-refresh
- **Files:** `home_page.dart`, `job_card.dart`, `job_provider.dart`

### 🔍 3. Search & Filter
- [x] SearchPage riêng biệt
- [x] Lọc theo: keyword, salary range, job type, job level, city
- [x] `JobFilterModel` cho filter parameters
- **Files:** `search_page.dart`, `job_filter_model.dart`

### 📋 4. Job Detail & Apply
- [x] JobDetailPage: hiển thị đầy đủ thông tin job
- [x] Nút "Ứng tuyển" → `ApplyBottomSheet`
- [x] Upload CV (PDF) qua Cloudinary
- [x] Cover letter text field
- [x] Success/error states khi submit application
- **Files:** `job_detail_page.dart`, `apply_bottom_sheet.dart`

### 💾 5. Save Job
- [x] Save/unsave job từ JobCard (nút ❤️)
- [x] `MyJobsProvider.saveJob()` + `unsaveJob()` + `unsaveJobByJobPostId()`
- [x] `isJobSaved()` check real-time
- [x] Mock `saveJob()` enriches data (trả về đầy đủ job details, không chỉ IDs)
- **Files:** `my_jobs_provider.dart`, `job_card.dart`, `job_remote_datasource.dart`

### 📑 6. My Jobs Page (Việc của tôi)
- [x] 2 tabs: "Đã lưu" + "Đã ứng tuyển"
- [x] `SavedJobCard` với nút unsave + onTap → `JobDetailPage`
- [x] `AppliedJobCard` với status badge (Đã nộp, Đang xem xét, Phỏng vấn, Từ chối, Đã tuyển)
- [x] Empty state: nút "Khám phá việc làm ngay" → chuyển tab 0
- [x] Auto-refresh khi chuyển tab từ `MainPage`
- [x] Mock `submitApplication()` enriches `jobTitle` + `companyName`
- **Files:** `my_jobs_page.dart`, `saved_job_card.dart`, `applied_job_card.dart`

### 🏢 7. Companies (Công ty)
- [x] Companies list (Grid/List toggle view)
- [x] Search companies theo tên
- [x] CompanyDetailPage với 2 tabs: Thông tin + Việc làm
- [x] CompanyJobsTab: hiển thị jobs của công ty cụ thể
- [x] AppBar: `automaticallyImplyLeading: false`
- **Files:** `companies_page.dart`, `company_detail_page.dart`, `company_card.dart`, `company_list_tile.dart`

### 👤 8. Profile (Hồ sơ ứng viên)
- [x] ProfilePage: hiển thị đầy đủ thông tin cá nhân
- [x] Sections: Thông tin cá nhân, Kỹ năng, Kinh nghiệm, Học vấn, Chứng chỉ, Ngôn ngữ, CV
- [x] EditProfilePage: form chỉnh sửa profile (~1100 lines)
- [x] Upload CV (PDF) từ profile page
- [x] Xem CV: mobile → WebView (Google Docs Viewer), web → url_launcher
- [x] Toggle `isSearchable` (công khai/riêng tư)
- [x] Industry field
- [x] **Upload ảnh đại diện (avatar)** — CircleAvatar + camera icon overlay, upload lên Cloudinary
- [x] **Upload ảnh chứng chỉ** — Pick ảnh từ file browser, upload lên Cloudinary, lưu vào `credentialUrl`
- [x] **Hiển thị ảnh chứng chỉ** — `CachedNetworkImage` trên ProfilePage (160px preview)
- **Files:** `profile_page.dart`, `edit_profile_page.dart`, `profile_provider.dart`, `pdf_viewer_page.dart`

### 🧭 9. Navigation (Bottom Nav)
- [x] `MainPage` với 4 tabs: Khám phá, Công ty, Việc của tôi, Hồ sơ
- [x] `IndexedStack` giữ state mỗi tab
- [x] Auto-refresh MyJobs data khi chuyển tab
- [x] `MainPage.switchTab()` static method cho child widgets
- [x] Tất cả AppBars: `automaticallyImplyLeading: false`
- **Files:** `main_page.dart`

---

## 🔄 Công Việc Tiếp Theo (Next Steps / Roadmap)

### Ưu tiên cao (API Integration)
1. **Tích hợp API Login thật** — Thay `AuthRemoteDataSourceImpl` mock bằng HTTP call thật (dùng Dio)
2. **Tích hợp API Profile** — Cần `candidateId` thật từ backend
3. **Tích hợp API Jobs** — Thay mock jobs list bằng API call
4. **Tích hợp API Companies** — Thay mock companies list
5. **Tích hợp các API còn lại** — Save, Apply, Unsave, Applications

### Ưu tiên trung bình (Features)
6. **Đăng ký cho NTD** — Cần luồng riêng (chọn loại TK hoặc trang riêng) kèm thông tin định danh Cty
7. **Quên mật khẩu** — Chưa có
8. **Logout** — Có thể cần xóa token + navigate về login
9. **Notification** — Thông báo khi ứng tuyển thành công / có phản hồi

### Ưu tiên thấp (Polish)
10. **Pagination** — Hiện tại load toàn bộ jobs/companies
11. **Caching** — Cache data offline
12. **Dark mode** — Chưa implement
13. **Unit tests** — Chưa có tests

---

## 🐛 Các Lỗi Đã Giải Quyết (Resolved Issues)

### Bug 1: Saved Jobs hiển thị dữ liệu trống
- **Triệu chứng:** Tab "Đã lưu" hiển thị card nhưng không có title, company, salary
- **Nguyên nhân:** Mock `saveJob()` chỉ tạo `SavedJobModel` với IDs, không include job details
- **Fix:** Sửa `saveJob()` trong `job_remote_datasource.dart` để lookup job details và enrich model
- **File:** `job_remote_datasource.dart` (line ~405-430)

### Bug 2: Applied Jobs không hiển thị
- **Triệu chứng:** Tab "Đã ứng tuyển" không có dữ liệu sau khi apply
- **Nguyên nhân:** Mock `submitApplication()` không enrich `jobTitle` và `companyName`
- **Fix:** Sửa `submitApplication()` để lookup và include job details trong `ApplicationModel`
- **File:** `job_remote_datasource.dart` (line ~332-357)

### Bug 3: MyJobs data không refresh khi chuyển tab
- **Triệu chứng:** Save job hoặc apply xong, chuyển sang tab MyJobs nhưng data cũ
- **Nguyên nhân:** `initState` trong `IndexedStack` chỉ chạy 1 lần
- **Fix:** Thêm `_onTabTapped(2)` trong `MainPage` để gọi `fetchSavedJobs` + `fetchApplications`
- **File:** `main_page.dart` (line ~28-41)

### Bug 4: Back button xuất hiện trên các tab pages
- **Triệu chứng:** Các trang trong bottom nav có back button (<-) ở AppBar
- **Nguyên nhân:** Flutter tự thêm back button khi page nằm trong navigation stack
- **Fix:** Thêm `automaticallyImplyLeading: false` vào AppBar của MyJobsPage, CompaniesPage, ProfilePage
- **Files:** `my_jobs_page.dart`, `companies_page.dart`, `profile_page.dart`

### Bug 5: Nút "Khám phá việc làm ngay" không hoạt động
- **Triệu chứng:** Nhấn nút trong empty state của MyJobs không làm gì
- **Nguyên nhân:** Ban đầu dùng `Navigator.popUntil` → không tương thích với bottom nav; sau đó comment out logic
- **Fix:** Tạo `MainPage.switchTab(context, 0)` static method và gọi từ button
- **Files:** `main_page.dart`, `my_jobs_page.dart`

### Bug 6: CV không mở được trên Android emulator
- **Triệu chứng:** Nhấn xem CV trên mobile → "Không thể mở file PDF"
- **Nguyên nhân:** `url_launcher` với `LaunchMode.externalApplication` cần app PDF reader, emulator không có
- **Fix:** Tạo `PdfViewerPage` dùng `webview_flutter` + Google Docs Viewer cho mobile; giữ `url_launcher` cho web
- **Files:** `pdf_viewer_page.dart`, `profile_page.dart`

### Bug 7: CV upload lỗi trên web
- **Triệu chứng:** Chọn file PDF trên web → crash
- **Nguyên nhân:** `file_picker` trên web trả về `bytes` thay vì `path`. Code cũ dùng `File(path).readAsBytes()`
- **Fix:** Sửa `pickAndUploadCV()` để dùng `result.files.single.bytes` trực tiếp, hỗ trợ cả web + mobile
- **File:** `profile_provider.dart`

### Bug 8: Chọn ảnh trên emulator không thấy file nào
- **Triệu chứng:** Nhấn upload ảnh đại diện/chứng chỉ → Photo Picker mở ra nhưng trống
- **Nguyên nhân:** `FileType.image` mở Android Photo Gallery picker, emulator mới không có ảnh trong gallery
- **Fix:** Đổi sang `FileType.custom` với `allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp']` → mở File Browser thay vì Gallery
- **File:** `profile_provider.dart` → `pickAndUploadImage()`

### Bug 9: Crash khi mở dialog chứng chỉ có ảnh
- **Triệu chứng:** `'width.isFinite': is not true` → app crash, dialog hiển thị trắng
- **Nguyên nhân:** `width: double.infinity` bên trong `AlertDialog` content — dialog không có bounded width constraint
- **Fix:** Bỏ tất cả `width: double.infinity` khỏi Container, `CachedNetworkImage`, SizedBox trong certificate dialog
- **File:** `edit_profile_page.dart` → `_showCertificateDialog()`

### Bug 10: Ảnh chứng chỉ upload thành công nhưng không hiển thị trên trang Hồ sơ
- **Triệu chứng:** Upload ảnh chứng chỉ OK nhưng profile page chỉ hiện text
- **Nguyên nhân:** `_buildCertificateSection()` trong `profile_page.dart` không render `credentialUrl` thành ảnh
- **Fix:** Thêm `CachedNetworkImage` vào certificate section khi `credentialUrl` có giá trị
- **File:** `profile_page.dart` → `_buildCertificateSection()`

---

## 📝 Ghi Chú Quan Trọng Cho Phiên Tiếp Theo

1. **Khi tích hợp API login thật:** Chỉ cần sửa `AuthRemoteDataSourceImpl` — không ảnh hưởng các mock khác
2. **`candidateId ?? 1`** — Fallback logic hiện tại, cần sync với API response khi có backend
3. **Tham khảo API spec:** Đã tạo file `api_specification.md` trong artifact directory với đầy đủ 16 endpoints
4. **76 files Dart** — Dự án đã khá lớn, mọi thay đổi nên chạy `flutter analyze` sau khi sửa
5. **Mock data nằm tại:** `job_remote_datasource.dart` (~530 lines), `profile_remote_datasource.dart`, `company_remote_datasource.dart`, `auth_remote_datasource.dart`
6. **Upload ảnh dùng chung:** `ProfileProvider.pickAndUploadImage()` — FileType.custom + Cloudinary, trả về URL. Có thể tái sử dụng cho bất kỳ feature nào cần upload ảnh
7. **`credentialUrl` trong `CertificateEntity`** giờ lưu URL ảnh chứng chỉ (Cloudinary) thay vì URL xác minh text
