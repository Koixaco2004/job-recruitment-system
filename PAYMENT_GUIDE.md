# Hướng dẫn Tích hợp và Vận hành Thanh toán VNPay (v2.1.0)

Tài liệu này cung cấp cái nhìn tổng quan về luồng thanh toán, cách thức hoạt động của Backend và hướng dẫn tích hợp cho Team Frontend (Web/Mobile).

## 1. Luồng xử lý (Lifecycle)

Hệ thống sử dụng quy trình **Hybrid (IPN + Return URL)** để đảm bảo giao dịch luôn được cập nhật chính xác ngay cả trong môi trường local.

1.  **Khởi tạo**: Frontend gọi API tạo đơn -> Backend lưu đơn hàng `PENDING` -> Trả về `paymentUrl`.
2.  **Thanh toán**: Người dùng thực hiện thanh toán trên giao diện VNPay.
3.  **Xác thực (Dual-Mode)**:
    *   **IPN (Chạy ngầm)**: VNPay gọi trực tiếp tới Server để xác nhận kết quả (An toàn nhất).
    *   **Return URL (Chạy trên trình duyệt)**: VNPay điều hướng người dùng quay lại Server. Backend kiểm tra ngay lập tức và cộng tiền (Idempotent) nếu luồng IPN chưa kịp xử lý.
4.  **Kết quả**: Backend redirect người dùng về Frontend kèm theo các tham số trạng thái.

## 2. Cấu hình Môi trường (.env)

Đảm bảo các biến sau được thiết lập chính xác:

```env
# URL của Frontend để Redirect về sau khi xong
FRONTEND_URL=http://localhost:5173

# URL của Backend để VNPay gọi Callback (Return/IPN)
BACKEND_URL=http://localhost:3000

# Cấu hình VNPay Sandbox
VNPAY_TMN_CODE=Q8X4GQAV
VNPAY_HASH_SECRET=LTRAWY0MNRA...
VNPAY_PAYMENT_URL=https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
```

## 3. Hướng dẫn dành cho Frontend (Web)

Khi người dùng quay lại từ VNPay, họ sẽ được chuyển hướng tới:  
`{FRONTEND_URL}/payment/result?success=true&orderId=CR-xxx&message=...`

**Các tham số:**
*   `success`: `true` (Thành công) | `false` (Thất bại/Hủy).
*   `orderId`: Mã đơn hàng để hiển thị tra cứu.
*   `message`: Nội dung thông báo tiếng Việt.

**Action gợi ý:** Nếu `success=true`, FE nên trigger một lệnh gọi API lấy Profile hoặc Ví tiền để cập nhật số dư mới mà không cần F5.

## 4. Hướng dẫn dành cho Mobile (Flutter)

Sử dụng package `webview_flutter` để bắt (intercept) URL chuyển hướng.

### Code mẫu Interception:

```dart
NavigationDelegate(
  onNavigationRequest: (NavigationRequest request) {
    // Kiểm tra xem có phải URL kết quả không
    if (request.url.contains('/payment/result')) {
      Uri uri = Uri.parse(request.url);
      bool isSuccess = uri.queryParameters['success'] == 'true';
      String message = uri.queryParameters['message'] ?? "";
      
      // Đóng WebView và báo kết quả cho App Native
      Navigator.pop(context, {'success': isSuccess, 'message': message});
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  },
)
```

## 5. Lưu ý về Tính đồng nhất Dữ liệu (Idempotency)

Backend đã xử lý chống trùng lặp dữ liệu:
*   Nếu IPN và Return URL cùng nhẩy vào một lúc, chỉ có yêu cầu đầu tiên được thực hiện cộng tiền.
*   Trình duyệt có bị tắt đột ngột, tiền vẫn sẽ vào ví nhờ luồng IPN chạy ngầm.

---
*Tài liệu được biên soạn cho hệ thống NestJs-ATS - 2026.*
