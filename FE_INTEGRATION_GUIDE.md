# FE Integration Guide: Real-time & Notifications System

Tài liệu này hướng dẫn team FE cách kết nối và xử lý dữ liệu từ hệ thống thông báo thời gian thực (Socket.io) và các API quản lý thông báo của dự án NestJS-ATS.

---

## 1. Kết nối Socket.io

Hệ thống yêu cầu xác thực JWT ngay khi kết nối.

- **URL**: `BASE_URL` của Backend (ví dụ: `http://localhost:3000`)
- **Transport**: `websocket` (Khuyến nghị)
- **Xác thực**: Gửi Token qua `auth` object hoặc Cookie.

### Mã mẫu kết nối (React/Next.js):
```javascript
import { io } from 'socket.io-client';

const socket = io(process.env.NEXT_PUBLIC_SOCKET_URL, {
  auth: {
    token: localStorage.getItem('access_token'), // Gửi JWT token
  },
  transports: ['websocket'],
});

socket.on('connect', () => {
  console.log('✅ Connected to Real-time Server as ID:', socket.id);
});

socket.on('connect_error', (err) => {
  console.error('❌ Connection failed:', err.message);
});
```

---

## 2. Quản lý Phòng (Room Subscription)

Một số dữ liệu chỉ được gửi cho những người đang xem trang cụ thể. FE cần "đăng ký" tham gia phòng khi truy cập trang và "rời phòng" khi chuyển trang.

### 2.1. Đăng ký nhận cập nhật Kanban (Trang Kanban Board)
Khi vào trang quản lý ứng viên của một tin tuyển dụng:
- **Emit**: `subscribe_job_kanban`
- **Data**: `{ jobId: number }`

```javascript
// Tham gia
socket.emit('subscribe_job_kanban', { jobId: 123 });

// Rời (khi Unmount component)
socket.emit('unsubscribe_job_kanban', { jobId: 123 });
```

### 2.2. Đăng ký nhận cập nhật chi tiết hồ sơ (Trang Detail Application)
Khi vào trang chi tiết một hồ sơ ứng viên:
- **Emit**: `subscribe_application_detail`
- **Data**: `{ applicationId: number }`

```javascript
socket.emit('subscribe_application_detail', { applicationId: 456 });
```

---

## 3. Danh sách các sự kiện lắng nghe (Event Listeners)

| Event Name | Phạm vi (Room) | Mô tả | Dữ liệu trả về (Payload) |
| :--- | :--- | :--- | :--- |
| **`notification`** | `user_{userId}` | Thông báo cá nhân (được lưu vào DB). Bao gồm tất cả các loại: Thay đổi trạng thái ứng tuyển, Thư mời mới, Duyệt tin, v.v. | `NotificationEntity` |
| **`kanban_update`**| `job_kanban_{jobId}` | Một ứng viên vừa được kéo sang trạng thái (cột) khác trên bảng Kanban. | `{ applicationId, oldStatus, newStatus, actor }` |
| **`kanban_note`**  | `job_kanban_{jobId}` | Cập nhật số lượng ghi chú (badge) trên thẻ ứng viên. | `{ applicationId, noteCount }` |
| **`new_note`**     | `application_detail_{id}` | Ghi chú mới vừa được thêm vào dòng thời gian (Timeline) hồ sơ. | `ApplicationNoteEntity` |

---

## 4. Chi tiết về Thông báo (`notification` event)

Khi nhận sự kiện `notification`, FE cần kiểm tra trường **`type`** để xử lý hiển thị hoặc điều hướng.

### 4.1. Các loại thông báo và Metadata đi kèm

| `type` (Enum) | Đối tượng nhận | Metadata Structure | Mô tả |
| :--- | :--- | :--- | :--- |
| `application_status` | Ứng viên | `{ jobId, applicationId, status }` | Trạng thái ứng tuyển thay đổi (Phỏng vấn, Từ chối...) |
| `headhunt_invitation`| Ứng viên | `{ jobId, invitationId }` | Nhận được lời mời ứng tuyển trực tiếp. |
| `headhunt_accept`    | Employer | `{ jobId, candidateId, invitationId }` | Ứng viên chấp nhận lời mời làm việc. |
| `headhunt_reject`    | Employer | `{ jobId, candidateId, invitationId }` | Ứng viên từ chối lời mời làm việc. |
| `job_approval`       | Employer | `{ jobId, status, reason? }` | Tin tuyển dụng được duyệt hoặc bị từ chối. |
| `system`             | Tất cả | `{ message? }` | Thông báo từ hệ thống (Bảo trì, cập nhật...). |

### 4.2. Ví dụ xử lý trên Frontend (Flutter/React):

```javascript
socket.on('notification', (data) => {
  const { type, title, metadata } = data;
  
  // 1. Hiển thị Toast
  showToast(title);
  
  // 2. Điều hướng hoặc cập nhật UI dựa trên type
  switch(type) {
    case 'application_status':
      navigate('/applications/' + metadata.applicationId);
      break;
    case 'headhunt_invitation':
      showInvitationModal(metadata.invitationId);
      break;
    // ... xử lý các loại khác
  }
});
```

---

## 5. REST API cho Quản lý thông báo (Persistent)

Sử dụng Token trong Header Authorization (`Bearer <token>`).

- **Lấy danh sách thông báo (Phân trang)**:
  `GET /notifications?page=1&limit=20`
- **Lấy số lượng thông báo chưa đọc**:
  `GET /notifications/unread-count` 
  - Trả về: `{ count: number }`
- **Đánh dấu đọc tất cả**:
  `PATCH /notifications/mark-all-read`
- **Đánh dấu đọc một thông báo cụ thể**:
  `PATCH /notifications/:id/read`

---

## 6. Lưu ý quan trọng cho FE

> [!IMPORTANT]
> **Cleanup Listeners**: Luôn luôn hãy gọi `socket.off(eventName)` khi unmount component (ví dụ: trong return của `useEffect`) để tránh việc nhận trùng tin nhắn hoặc rò rỉ bộ nhớ.

> [!TIP]
> **Re-syncing**: Khi người dùng quay lại tab sau một thời gian dài (Page visibility changed) hoặc khi Socket kết nối lại, FE nên chủ động gọi lại API `unread-count` để đảm bảo dữ liệu là mới nhất.

---
*Tài liệu được cập nhật lần cuối vào: 21/04/2026*
