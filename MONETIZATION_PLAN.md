# 💎 Kế hoạch Triển khai Chi tiết: VIP, Credit & Monetization System

Bản kế hoạch này tổng hợp từ các tài liệu hướng dẫn tích hợp, mapping tính năng và luồng xử lý thực tế. Mọi giao dịch tiền tệ đều thực hiện qua **VNPay Sandbox**.

---

## 🚀 Giai đoạn 1: Mua sắm & Thanh toán (Shopping & Payment Flow)
*Mục tiêu: Xây dựng cửa hàng và luồng nạp tiền giả lập để chuẩn bị cho việc sử dụng tính năng.*

### 1.1. Bảng giá VIP & Gói nạp Credit
- **Trang Nâng cấp VIP**:
    - **API**: `GET /subscriptions/packages` (Public)
    - **Dữ liệu cần hiển thị**:
        - `maxActiveJobs`: Số tin đăng tối đa.
        - `monthlyFreeProceeds`: Lượt duyệt ứng viên miễn phí/tháng.
        - `hasVipBadge`: Có badge VIP hay không.
        - `price`: Giá gói (Price = 0 là gói Free).
- **Trang Mua Credit**:
    - **API**: `GET /credits/topup-packs`
    - **Dữ liệu cần hiển thị**: `creditAmount` (số tín dụng nhận được) và `price`.

### 1.2. Luồng Thanh toán VNPay Sandbox
- **Bước 1 (Tạo đơn)**:
    - **Mua VIP**: `POST /payments/vip/create-order` (Payload: Rỗng `{}`).
    - **Nạp Credit**: `POST /payments/credit/create-order` (Payload: `{ "packId": "starter" }`).
    - **Kết quả**: Nhận `paymentUrl`.
- **Bước 2 (Chuyển hướng)**: FE mở `paymentUrl` để user thao tác trên VNPay.
- **Bước 3 (Xác nhận)**:
    - **Return URL**: `GET /api/payments/vnpay/return?vnp_Amount=...`
    - **Xử lý**: FE lấy bộ query string gửi lên API này. BE xác thực chữ ký HMAC và trả về kết quả thành công/thất bại.

---

## 📊 Giai đoạn 2: Quản lý Trạng thái & Ví (Wallet & Status)
*Mục tiêu: Employer theo dõi được quyền lợi và số dư hiện có.*

### 2.1. Trạng thái Gói cước hiện tại
- **API**: `GET /subscriptions/my` (hoặc `/subscriptions/status`)
- **Trường dữ liệu quan trọng**:
    - `tier`: "free" hoặc "vip".
    - `expiresAt`: Ngày hết hạn VIP.
    - `dailyProcessedCount`: Số ứng viên đã duyệt trong ngày (để vẽ thanh tiến độ giới hạn 20/ngày của gói Free).

### 2.2. Số dư Ví & Giao dịch
- **API Số dư**: `GET /credits/balance` -> Trả về `{ "balance": 150 }`.
- **API Lịch sử**: `GET /credits/transactions?page=1&limit=20`.
    - `type`: "topup" (nạp tiền), "purchase" (mua tính năng lẻ), "pipeline_fee" (phí duyệt ứng viên).
    - `amount`: Số tiền (âm là trừ, dương là cộng).

---

## 🛠️ Giai đoạn 3: Quản lý Tin đăng & Chợ tính năng lẻ (Job Management)
*Mục tiêu: Áp dụng các tính năng VIP trong tạo tin và cho phép dùng Credit mua lẻ.*

### 3.1. Cập nhật Form Đăng tin & Ràng buộc gói Free
- **Các trường VIP mới**: 
    - `hideSalary` (boolean): Ẩn mức lương.
    - `requireCv` (boolean): Bắt buộc file CV.
- **Quy tắc chặn gói Free (Enforcement)**:
    - **Hạn mức**: `max_active_jobs = 1` (Chỉ 1 tin ở trạng thái `published`).
    - **Cooldown (7 ngày)**: Tin đăng gói Free chỉ có hiệu lực 7 ngày (`jobDurationDays = 7`). Sau khi tin hết hạn hoặc đóng, Employer phải đợi hết chu kỳ mới được đăng tin tiếp theo (tổng 4 tin/tháng).
    - **Lỗi 403**: Backend trả về lỗi kèm thời gian mở khóa nếu vi phạm cooldown hoặc hạn mức.

### 3.2. Chợ tính năng lẻ (Credits Purchase)
- **Danh sách sản phẩm**: `GET /api/credits/products`.
- **Thực hiện mua**: `POST /api/credits/purchase`.
    - **Slug**: `bump_post` (đẩy tin), `extend_job` (gia hạn), `extra_job_slot` (mua thêm slot đăng tin).
    - **Side-effects**:
        - `bump_post`: Set `isBumped=true`, tin sẽ luôn hiện trên đầu danh sách public.
        - `extend_job`: Gia hạn `deadline` tin tuyển dụng.
        - `extra_job_slot`: Tăng vĩnh viễn giới hạn `maxActiveJobs`.

---

## 👥 Giai đoạn 4: Xử lý Ứng viên & AI Scoring
*Mục tiêu: Kiểm soát hạn mức xem hồ sơ và thu phí tiến trình.*

### 4.1. Giới hạn Xem hồ sơ (Profile View)
- **API**: `GET /api/employer/applications/:id`.
- **Trường bổ sung**: `profileViewsRemaining` (số lượt còn lại, VIP = -1).
- **Lưu ý**: Xem lại cùng một ứng viên trong một Job không tốn thêm lượt.

### 4.2. Phí Tiến trình (Pipeline Fee)
- **API**: `PUT /api/employer/applications/:id/status`.
- **Cơ chế**: Kéo ứng viên từ `applied` sang các vòng sau sẽ thu **10 Credit**.
    - Nếu VIP: Trừ vào `monthly_free_proceeds` (hạn mức miễn phí hàng tháng).
    - Nếu hết hạn mức hoặc Free: Trừ trực tiếp vào Ví Credit.
    - Thiếu tiền: Backend trả về **402 Payment Required**.

### 4.3. AI Scoring
- **VIP**: Tự động kích hoạt khi có ứng viên nộp đơn.
- **Free**: Trả về `null`. Employer phải bấm nút thủ công gọi API `ai-analyze`.

---

## 🎯 Giai đoạn 5: Headhunting & Branding
*Mục tiêu: Tính năng tìm kiếm tài năng cao cấp.*

### 5.1. Mở khóa thông tin liên hệ (Unlock Contact)
- **API**: `GET /api/employers/headhunting/candidates/:id`.
- **Trường bổ sung**:
    - `contactUnlocked` (bool): Đã mở khóa SĐT/Email chưa.
    - `creditSpent` (number): Số tiền đã tốn để mở khóa (0 nếu miễn phí/VIP quota).
- **Cơ chế**: Thu **5 Credit** cho lần mở khóa đầu tiên với một ứng viên.

### 5.2. Chặn tính năng Headhunting với Free User
- **API**: Lưu ứng viên (`POST .../saved-candidates`) và Gửi thư mời (`POST .../invitations`).
- **Lưu ý**: Chỉ VIP mới được sử dụng. Free gọi sẽ bị trả về `403`.

### 5.3. Nhận diện VIP Branding
- **API**: `GET /api/companies/slug/:slug`.
- **Trường bổ sung**: `isVip` (bool).
- **UI**: Hiển thị ✨ Badge VIP cạnh tên công ty.

---

## 🔒 Giai đoạn 6: Câu hỏi sàng lọc (Screening Questions)
*Mục tiêu: Sàng lọc ứng viên tự động cho Employer VIP.*

### 6.1. Quản lý câu hỏi (Employer)
- **API**: `GET/POST /api/jobs/:jobId/screening`.
- **Cấu hình**: `questionType` (yes_no, single_choice...), `preferredAnswer` (đáp án mong muốn để auto-grade).

### 6.2. Trả lời câu hỏi (Candidate)
- **API**: `POST /api/jobs/applications/:applicationId/screening/answers`.
- **Kết quả**: `screeningPassed` (true/false) tự động xuất hiện trong chi tiết đơn ứng tuyển.

---

### ⚠️ Lưu ý chung cho Frontend:
1. **Error Handling**: Luôn bắt mã lỗi **402 (Thiếu tiền)** và **403 (Giới hạn gói)** để hiển thị Dialog hướng dẫn nạp tiền/nâng cấp VIP.
2. **Real-time Update**: Sau khi thanh toán thành công hoặc mua tính năng, cần gọi lại API `balance` và `subscription status` để cập nhật UI ngay lập tức.
