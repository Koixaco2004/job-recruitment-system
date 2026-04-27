# Hướng Dẫn Tích Hợp Frontend: VIP, Credit & Thanh Toán

Tài liệu này dành cho đội ngũ Frontend (FE) để tích hợp hệ thống Monetization mới của nền tảng ATS. Hệ thống bao gồm 3 trụ cột chính: **Gói cước (Subscriptions)**, **Ví tín dụng (Credits)** và **Thanh toán qua VNPay (Payments)**.

---

## 💎 1. Subscriptions — Quản Lý Gói Cước

### 1.1. Lấy danh sách các gói cước đang bán
Hiển thị trên trang Bảng Giá / Nâng cấp VIP.
- **Endpoint:** `GET /subscriptions/packages`
- **Auth:** Không yêu cầu (Public)
- **Response:** Array các `SubscriptionPackageEntity`. Chú ý hiển thị các quyền lợi như `maxActiveJobs`, `jobDurationDays`, `monthlyFreeProceeds`, `price`. Gói có `price = 0` là gói Free.

### 1.2. Lấy thông tin gói hiện tại của công ty
Hiển thị ở Header, Dashboard hoặc màn hình Account Settings.
- **Endpoint:** `GET /subscriptions/my`
- **Auth:** Bearer Token (Role: Employer)
- **Response:** Object chứa thông tin `CompanySubscriptionEntity` (thời hạn, các counter usage hiện tại) và `package` (chi tiết gói đó).
- **FE cần làm:** 
  - Đọc `tier` (gói Free hoặc VIP) để ẩn/hiện UI tương ứng (ví dụ: Logo VIP, Checkbox khóa CV).
  - Dùng `dailyProcessedCount` để vẽ thanh tiến độ giới hạn 20 ứng viên/ngày đối với gói Free.

### 1.3. Bắt lỗi Quota / Lỗi Giới hạn
Trong quá trình sử dụng, nếu Employer vi phạm giới hạn của gói Free (ví dụ: đăng 2 tin cùng lúc, đăng tin khi đang bị khóa 7 ngày), backend sẽ trả về mã lỗi **403 Forbidden**.
- **FE cần làm:** Bắt HTTP 403, đọc `error.response.message` và popup thông báo kèm Nút CTA: **"Nâng cấp VIP ngay"**.

---

## 🪙 2. Credits — Ví Tín Dụng & Giao Dịch

Khái niệm: Credit (Tín dụng) là đồng tiền ảo trong app dùng để trả phí xử lý hồ sơ (Pipeline fee) hoặc mua các tính năng lẻ (tương lai).

### 2.1. Lấy số dư ví hiện tại
Hiển thị góc phải Header (ví dụ: 🪙 150 Credits).
- **Endpoint:** `GET /credits/balance`
- **Auth:** Bearer Token (Role: Employer)
- **Response:** `{ "balance": 150 }`

### 2.2. Lấy lịch sử giao dịch
Hiển thị ở màn hình Lịch sử nạp/rút.
- **Endpoint:** `GET /credits/transactions?page=1&limit=20`
- **Auth:** Bearer Token (Role: Employer)
- **Response:** Phân trang transactions với các loại `type` (topup, pipeline_fee). Số `amount` dương là tiền vào, âm là tiền ra.

### 2.3. Lấy danh sách gói nạp (Topup Packs)
Hiển thị ở màn hình "Mua thêm Credit".
- **Endpoint:** `GET /credits/topup-packs`
- **Auth:** Bearer Token (Role: Employer)
- **Response:** Trả về 4 gói cố định: `starter`, `plus`, `pro`, `enterprise` với giá tiền và số Credit tương ứng nhận được. FE render UI dạng các thẻ (cards) cho user chọn.

---

## 💳 3. Thanh Toán VNPay — Payment Flow

Luồng thanh toán hiện tại chỉ hỗ trợ VNPay. FE không cần quan tâm đến webhook (IPN), chỉ lo thao tác Push user sang VNPay và đón user về.

### Bước 1: Tạo đơn hàng và chuyển hướng
Khi user nhấn nút **"Thanh toán"**:

**Mua gói VIP:**
- **Endpoint:** `POST /payments/vip/create-order`
- **Payload:** Rỗng `{}` (Hệ thống tự nhận diện user config).
- **Response:** `{ "orderId": X, "paymentUrl": "https://sandbox.vnpayment.vn/..." }`

**Nạp Credit:**
- **Endpoint:** `POST /payments/credit/create-order`
- **Payload:** `{ "packId": "starter" }` (packId lấy từ bảng giá topup).
- **Response:** Chứa `paymentUrl`.

**FE cần làm:** Bắt lấy `paymentUrl` và gọi lệnh `window.location.href = response.paymentUrl` để đẩy user sang trang VNPay.

### Bước 2: Đón user từ VNPay trở về (Return URL)
Sau khi user thanh toán xong, VNPay sẽ đẩy user về lại Frontend (dựa vào cấu hình app, hoặc BE sẽ redirect). Do cấu hình hiện hành, VNPay sẽ ping thẳng vào BE Endpoint `GET /payments/vnpay/return`.
  
*Lưu ý cho FE:* Hãy check xem BE đang render HTML thông báo hay trả về JSON. Hiện tại hệ thống đang trả về JSON: `{ "success": true/false, "message": "...", "orderId": ... }`.
**Best Practice đối với FE:**
1. Lắng nghe route ở FE (ví dụ: `/payment-result`)
2. Extract query string URL do VNPay đẩy về (`?vnp_Amount=...&vnp_ResponseCode=...`)
3. Passthrough bộ query string đó gọi lên BE: `GET /api/payments/vnpay/return?vnp_Amount...` 
4. BE sẽ xác thực chữ ký (HMAC) và báo thành công/thất bại. Dựa vào đó FE vẽ màn hình "Thanh toán thành công" hoặc "Lỗi". 

> **Quan trọng:** Kết quả thực tế (cộng tiền ví / kích hoạt VIP) được xử lý dưới nền thông qua **IPN webhook**. Màn hình Return chỉ mang tính hiển thị. FE nên Fetch lại `/subscriptions/my` hoặc `/credits/balance` sau khi user quay lại dashboard.

---

## 🛣️ 4. Nghiệp Vụ Chặn/Cắt Phí (Gating Logic)

### 4.1. Phí Pipeline (Khi Employer duyệt hồ sơ)
Khi Employer kéo thả ứng viên vào các cột (Shortlisted, Interview, Offer) thông qua API update status:
- Gói **Free** sẽ bị trừ Credit tương ứng.
- Gói **VIP** sẽ không bị trừ (nếu còn hạn mức tháng).
- **FE cần làm:** Nếu số dư KHÔNG đủ, API update status sẽ văng lỗi **402 Payment Required** (hoặc 400 ghi chú Không đủ Credit). FE bắt lỗi này và hiện popup "Bạn cần nạp thêm Credit để thực hiện thao tác này. Số dư: X".

### 4.2. Khóa CV Bắt buộc (Require CV)
- Nếu Employer (VIP) tạo job và chọn `requireCv: true`.
- Khách (Candidate) vào ứng tuyển, UI FE **cần kiểm tra `require_cv` field của job**. Nếu là true, frontend hãy **disable nút Nộp Đơn** nếu ứng viên chưa chọn file CV. Đừng để gọi API mới báo lỗi.

### 4.3. AI Scoring (Tính năng chấm điểm)
- Đối với tin VIP: Khi ứng viên nộp đơn, hệ thống tự động chạy ngầm. Vài giây sau, FE truy vấn danh sách ứng viên sẽ thấy `matchScore` xuất hiện.
- Đối với tin Free: Sẽ trả về `null`. FE hiển thị "Nâng cấp VIP để xem độ phù hợp bằng AI".

---

## 🧪 5. Môi trường Test (Sandbox)
- Hệ thống đang trỏ vào **VNPay Sandbox**. 
- Thẻ Test VNPay thường dùng (Bạn có thể lên trang devs VNPay lấy thông tin thẻ ATM nội địa hoặc thẻ quốc tế để tự điền test).
- **Link Sandbox Dashboard:** https://sandbox.vnpayment.vn/devreg/ Mọi thanh toán đều không trừ tiền thật.
