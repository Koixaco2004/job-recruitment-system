# Hướng dẫn tích hợp thanh toán (Credit & VIP)

Tài liệu này hướng dẫn cách gọi API để thực hiện nạp Credit và mua gói VIP qua cổng VNPay cho các nền tảng khác (Mobile, Web khác).

## 1. Quy trình chung
1. Client gọi API tạo đơn hàng (`create-order`).
2. Server trả về một đường dẫn `paymentUrl` của VNPay.
3. Client mở `paymentUrl` (Webview hoặc trình duyệt).
4. Sau khi thanh toán xong, VNPay sẽ redirect về server, server xử lý và redirect tiếp về `payment/result` của Frontend.

---

## 2. Nạp Credit (Credit Topup)

### Bước 1: Lấy danh sách gói nạp
Để biết các gói nạp đang có (slug, giá, số credit), gọi:

- **Endpoint**: `GET /api/credits/topup-packs`
- **Auth**: Không yêu cầu (hoặc JWT tùy cấu hình)
- **Response**: Mảng các object chứa `slug`, `displayName`, `priceVnd`, `creditBase`, `bonus`.

### Bước 2: Tạo đơn nạp Credit
- **Endpoint**: `POST /api/payments/credit/create-order`
- **Auth**: Yêu cầu JWT (Role: EMPLOYER)
- **Body**:
```json
{
  "packSlug": "starter" 
}
```
*Lưu ý: Sử dụng `slug` lấy từ Bước 1.*

- **Response**:
```json
{
  "success": true,
  "data": {
    "orderId": 123,
    "paymentUrl": "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?..."
  }
}
```

---

## 3. Đăng ký gói VIP (Subscription)

Hiện tại hệ thống hỗ trợ một gói VIP mặc định.

### Tạo đơn mua gói VIP
- **Endpoint**: `POST /api/payments/vip/create-order`
- **Auth**: Yêu cầu JWT (Role: EMPLOYER)
- **Body**: (Không cần body vì đang fix cứng gói 'vip')
```json
{}
```

- **Response**:
```json
{
  "success": true,
  "data": {
    "orderId": 456,
    "paymentUrl": "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?..."
  }
}
```

---

## 4. Xử lý sau thanh toán (Dành cho Mobile)

Sau khi người dùng hoàn tất thanh toán trên Webview:
1. Server sẽ nhận callback từ VNPay.
2. Server redirect người dùng về URL: `{FRONTEND_URL}/payment/result?success=true&orderId=...&message=...`
3. Mobile App nên lắng nghe sự thay đổi URL của Webview. Nếu thấy URL chứa `/payment/result`, hãy trích xuất các query params (`success`, `message`) để hiển thị thông báo cho người dùng và đóng Webview.

---

## 5. Lưu ý về môi trường
- **Sandbox**: Các giao dịch hiện tại đang chạy trên môi trường Test của VNPay.
- **Tiền tệ**: VNĐ.
- **Thời hạn**: Đơn hàng sẽ hết hạn sau 15 phút nếu không thanh toán.
