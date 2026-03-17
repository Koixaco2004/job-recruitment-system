CREATE TABLE `company` (
  `id` int PRIMARY KEY AUTO_INCREMENT COMMENT 'ID tự tăng, khóa chính của công ty',
  `user_creator_id` int UNIQUE NOT NULL COMMENT 'ID người tạo công ty, liên kết 1-1 với bảng user',
  `category_id` int NOT NULL COMMENT 'Lĩnh vực hoạt động chính của công ty',
  `name` varchar(255) NOT NULL COMMENT 'Tên đầy đủ của công ty',
  `email_contact` varchar(100) COMMENT 'Email liên hệ chính thức',
  `phone_contact` varchar(20) COMMENT 'Số điện thoại hotline công ty',
  `address` text COMMENT 'Địa chỉ trụ sở',
  `province_id` int COMMENT 'Tỉnh/Thành phố đặt trụ sở',
  `logo_url` varchar(255) COMMENT 'Đường dẫn ảnh logo công ty',
  `banner_url` varchar(255) COMMENT 'Đường dẫn ảnh bìa trang cá nhân công ty',
  `description` text COMMENT 'Mô tả ngắn gọn về công ty',
  `content` longtext COMMENT 'Giới thiệu chi tiết về văn hóa, môi trường làm việc',
  `company_size` varchar(50) COMMENT 'Quy mô nhân sự (ví dụ: 50-100 nhân viên)',
  `business_license_url` varchar(255) COMMENT 'Đường dẫn file giấy phép kinh doanh để admin duyệt',
  `is_verified` boolean DEFAULT false COMMENT 'Trạng thái xác thực công ty bởi Admin',
  `verified_at` datetime COMMENT 'Thời điểm công ty được xác thực thành công',
  `created_at` timestamp DEFAULT (now()) COMMENT 'Thời điểm tạo record',
  `updated_at` timestamp DEFAULT (now()) COMMENT 'Thời điểm cập nhật record gần nhất'
);

CREATE TABLE `subscription_package` (
  `id` int PRIMARY KEY AUTO_INCREMENT COMMENT 'ID gói cước',
  `name` varchar(255) NOT NULL COMMENT 'Tên gói dịch vụ (Ví dụ: Free, Basic, VIP)',
  `price` decimal(15,2) NOT NULL COMMENT 'Giá tiền của gói (Triệu VNĐ)',
  `duration_days` int NOT NULL COMMENT 'Số ngày hiệu lực của gói kể từ khi kích hoạt',
  `job_post_quota` int COMMENT 'Tổng số tin tuyển dụng tối đa được đăng khi dùng gói này',
  `max_applications_per_job` int COMMENT 'Số lượng CV tối đa có thể nhận cho mỗi tin đăng',
  `urgent_badge_quota` int DEFAULT 0 COMMENT 'Số lượt được gắn nhãn Tuyển Gấp cho các bài đăng',
  `bump_post_quota` int DEFAULT 0 COMMENT 'Số lượt được nhấn nút Đẩy Tin lên đầu danh sách',
  `can_use_ai_strict_filter` boolean DEFAULT false COMMENT 'Quyền sử dụng AI để tự động loại ứng viên không đạt chuẩn',
  `can_export_report` boolean DEFAULT false COMMENT 'Quyền xuất dữ liệu báo cáo thống kê ra file (Excel/PDF)',
  `created_at` timestamp DEFAULT (now()),
  `updated_at` timestamp DEFAULT (now())
);

CREATE TABLE `company_subscription` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `company_id` int NOT NULL COMMENT 'Công ty đang sở hữu gói này',
  `package_id` int NOT NULL COMMENT 'Gói dịch vụ đã mua',
  `status` varchar(20) DEFAULT 'active' COMMENT 'Trạng thái gói: active (đang dùng), expired (hết hạn), cancelled (bị hủy)',
  `start_date` datetime NOT NULL COMMENT 'Ngày bắt đầu tính hạn dùng',
  `end_date` datetime NOT NULL COMMENT 'Ngày gói hết hiệu lực',
  `used_job_post_quota` int DEFAULT 0 COMMENT 'Số lượng tin tuyển dụng đã thực hiện đăng',
  `used_urgent_badge_quota` int DEFAULT 0 COMMENT 'Số lượng nhãn tuyển gấp đã thực hiện gắn',
  `used_bump_post_quota` int DEFAULT 0 COMMENT 'Số lần đã thực hiện đẩy tin',
  `created_at` timestamp DEFAULT (now()),
  `updated_at` timestamp DEFAULT (now())
);

CREATE TABLE `payment_transaction` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `company_id` int COMMENT 'Công ty thực hiện thanh toán',
  `package_id` int COMMENT 'Gói dịch vụ mà công ty muốn mua',
  `amount` decimal(15,2) NOT NULL COMMENT 'Số tiền thực trả (Triệu VNĐ)',
  `payment_method` varchar(50) COMMENT 'Phương thức thanh toán: banking, momo, vnpay...',
  `transaction_code` varchar(255) UNIQUE COMMENT 'Mã giao dịch duy nhất từ cổng thanh toán',
  `status` varchar(20) DEFAULT 'pending' COMMENT 'Trạng thái: pending (chờ), success (thành công), failed (lỗi), refunded (hoàn tiền)',
  `created_at` timestamp DEFAULT (now()) COMMENT 'Lúc bắt đầu tạo lệnh thanh toán',
  `completed_at` datetime COMMENT 'Lúc nhận được phản hồi thanh toán thành công'
);

CREATE TABLE `province` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT 'Tên tỉnh thành (Ví dụ: Hà Nội, TP.HCM)',
  `slug` varchar(255) UNIQUE COMMENT 'Tên không dấu phục vụ URL SEO (Ví dụ: ho-chi-minh)'
);

CREATE TABLE `user` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `email` varchar(255) UNIQUE NOT NULL COMMENT 'Địa chỉ email dùng để đăng nhập',
  `password` varchar(255) NOT NULL COMMENT 'Mật khẩu đã được mã hóa',
  `role` varchar(20) COMMENT 'Vai trò: admin (quản trị), employer (nhà tuyển dụng), candidate (ứng viên)',
  `status` varchar(20) DEFAULT 'active' COMMENT 'Trạng thái tài khoản: active, locked',
  `created_at` timestamp DEFAULT (now())
);

CREATE TABLE `candidate` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `user_id` int UNIQUE COMMENT 'Liên kết 1-1 với tài khoản đăng nhập',
  `full_name` varchar(255) COMMENT 'Họ và tên đầy đủ của ứng viên',
  `gender` varchar(10) COMMENT 'Giới tính',
  `phone` varchar(20) COMMENT 'Số điện thoại cá nhân',
  `avatar_url` varchar(255) COMMENT 'Đường dẫn ảnh đại diện',
  `cv_url` varchar(255) COMMENT 'Đường dẫn file CV gốc (PDF) của ứng viên',
  `bio` text COMMENT 'Mô tả ngắn gọn về bản thân',
  `province_id` int COMMENT 'Nơi ở hiện tại',
  `position` varchar(255) COMMENT 'Vị trí công việc hiện tại hoặc mong muốn',
  `salary_min` decimal(15,2) COMMENT 'Mức lương tối thiểu kỳ vọng (Triệu)',
  `salary_max` decimal(15,2) COMMENT 'Mức lương tối đa kỳ vọng (Triệu)',
  `job_type_id` int COMMENT 'Hình thức làm việc mong muốn (Toàn thời gian,...)',
  `year_working_experience` int COMMENT 'Số năm kinh nghiệm làm việc thực tế'
);

CREATE TABLE `employer` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `user_id` int UNIQUE COMMENT 'Liên kết 1-1 với tài khoản HR',
  `company_id` int COMMENT 'Công ty mà HR này đang làm việc',
  `full_name` varchar(255) NOT NULL COMMENT 'Họ tên nhà tuyển dụng',
  `phone_contact` varchar(20) COMMENT 'Số điện thoại liên hệ của HR',
  `is_admin_company` boolean DEFAULT false COMMENT 'Quyền quản lý cấp cao trong công ty (duyệt các HR khác)',
  `status` varchar(20) DEFAULT 'active' COMMENT 'Trạng thái nhân viên trong nội bộ cty',
  `created_at` timestamp DEFAULT (now()),
  `updated_at` timestamp DEFAULT (now())
);

CREATE TABLE `job_post` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `employer_id` int COMMENT 'Người trực tiếp tạo bài đăng này',
  `company_id` int COMMENT 'Công ty chủ quản bài đăng',
  `category_id` int COMMENT 'Lĩnh vực ngành nghề của công việc',
  `province_id` int COMMENT 'Địa điểm làm việc cụ thể',
  `job_type_id` int COMMENT 'Loại hình (Toàn thời gian, Freelance...)',
  `title` varchar(255) NOT NULL COMMENT 'Tiêu đề tin tuyển dụng',
  `slug` varchar(255) UNIQUE COMMENT 'Đường dẫn phục vụ SEO bài đăng',
  `description` longtext NOT NULL COMMENT 'Mô tả chi tiết công việc (JD)',
  `requirement` longtext NOT NULL COMMENT 'Các yêu cầu đối với ứng viên',
  `benefit` text COMMENT 'Quyền lợi ứng viên được hưởng',
  `salary_min` decimal(15,2) COMMENT 'Lương tối thiểu (Triệu)',
  `salary_max` decimal(15,2) COMMENT 'Lương tối đa (Triệu)',
  `is_salary_negotiable` boolean DEFAULT false COMMENT 'Đánh dấu nếu lương có thể thỏa thuận',
  `is_show_salary_allowed` boolean COMMENT 'Cho phép hiển thị số tiền lương ra công chúng hay không',
  `quantity` int DEFAULT 1 COMMENT 'Số lượng nhân sự cần tuyển',
  `gender_requirement` varchar(20) COMMENT 'Yêu cầu giới tính nếu có',
  `min_year_experience` int DEFAULT 0 COMMENT 'Số năm kinh nghiệm tối thiểu yêu cầu',
  `is_urgent` boolean DEFAULT false COMMENT 'Đánh dấu tin đăng có nhãn Tuyển Gấp',
  `bumped_at` datetime COMMENT 'Thời điểm nhấn nút Đẩy Tin, dùng để sắp xếp tin mới nhất',
  `max_applications` int COMMENT 'Số lượng ứng tuyển tối đa cho tin này (Snapshot từ gói VIP lúc tạo tin)',
  `is_ai_strict_filter` boolean DEFAULT false COMMENT 'Bật chế độ AI tự động loại CV không đạt yêu cầu',
  `ai_strict_criteria` text COMMENT 'Mô tả các tiêu chí cứng để AI làm căn cứ lọc',
  `status` varchar(20) DEFAULT 'pending' COMMENT 'pending, active, hidden (ẩn), expired (hết hạn)',
  `created_at` timestamp DEFAULT (now()),
  `updated_at` timestamp DEFAULT (now()),
  `expired_at` datetime COMMENT 'Ngày tin đăng tự động hết hạn và không hiển thị nữa'
);

CREATE TABLE `job_skill_tag` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `job_id` int COMMENT 'Thuộc về bài đăng tuyển dụng nào',
  `tag_name` varchar(100) COMMENT 'Tên kỹ năng (Ví dụ: ReactJS, SQL)'
);

CREATE TABLE `job_category` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT 'Tên ngành nghề (Ví dụ: Công nghệ thông tin)',
  `slug` varchar(255) UNIQUE COMMENT 'Slug phục vụ tìm kiếm ngành nghề',
  `created_at` timestamp DEFAULT (now())
);

CREATE TABLE `candidate_job_category` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `candidate_id` int COMMENT 'Ứng viên nào quan tâm',
  `category_id` int COMMENT 'Lĩnh vực ứng viên quan tâm (tối đa 3)'
);

CREATE TABLE `job_type` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT 'Tên loại hình (Toàn thời gian, Bán thời gian...)',
  `slug` varchar(100) UNIQUE
);

CREATE TABLE `work_experience` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `candidate_id` int COMMENT 'Thuộc về hồ sơ ứng viên nào',
  `company_name` varchar(255) NOT NULL COMMENT 'Tên công ty đã từng làm việc',
  `position` varchar(255) NOT NULL COMMENT 'Chức danh đã đảm nhiệm',
  `start_date` date COMMENT 'Ngày bắt đầu làm việc',
  `end_date` date COMMENT 'Ngày kết thúc làm việc',
  `is_working_here` boolean COMMENT 'Đánh dấu nếu hiện tại vẫn đang làm ở đây',
  `description` text COMMENT 'Chi tiết các công việc đã thực hiện'
);

CREATE TABLE `education` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `candidate_id` int COMMENT 'Hồ sơ học vấn của ứng viên',
  `school_name` varchar(255) NOT NULL COMMENT 'Tên trường học/đại học',
  `major` varchar(255) COMMENT 'Chuyên ngành học',
  `degree` varchar(100) COMMENT 'Bằng cấp (Cử nhân, Kỹ sư...)',
  `start_date` date,
  `end_date` date,
  `is_still_studiyng` boolean COMMENT 'Đánh dấu nếu vẫn đang theo học',
  `description` text COMMENT 'Thông tin thêm về quá trình học tập'
);

CREATE TABLE `certificate` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `candidate_id` int,
  `name` varchar(255) NOT NULL COMMENT 'Tên chứng chỉ',
  `cer_img_url` varchar(255) COMMENT 'Ảnh chụp chứng chỉ'
);

CREATE TABLE `project` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `candidate_id` int,
  `name` varchar(255) NOT NULL COMMENT 'Tên dự án thực tế',
  `start_date` date,
  `end_date` date,
  `decription` text COMMENT 'Mô tả vai trò và kết quả trong dự án'
);

CREATE TABLE `candidate_skill_tag` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `candidate_id` int,
  `tag_name` varchar(100) COMMENT 'Kỹ năng chuyên môn ứng viên sở hữu'
);

CREATE TABLE `application` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `job_post_id` int NOT NULL COMMENT 'Bài tuyển dụng được ứng tuyển',
  `candidate_id` int NOT NULL COMMENT 'Ứng viên nộp hồ sơ',
  `applied_cv_url` varchar(255) NOT NULL COMMENT 'Đường dẫn bản snapshot CV PDF tại thời điểm nộp',
  `cover_letter` text COMMENT 'Thư giới thiệu ứng viên viết thêm',
  `status` varchar(50) DEFAULT 'applied' COMMENT 'Quy trình: applied (đã nộp), reviewing (đang xem), interviewing (phỏng vấn), offered (mời làm), rejected (từ chối)',
  `ai_match_score` decimal(5,2) COMMENT 'Điểm số % phù hợp giữa CV và JD do AI tính toán',
  `reject_reason` text COMMENT 'Lý do loại',
  `created_at` timestamp DEFAULT (now()) COMMENT 'Thời điểm nộp đơn',
  `updated_at` timestamp DEFAULT (now())
);

CREATE TABLE `application_status_history` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `application_id` int NOT NULL COMMENT 'Đơn ứng tuyển được cập nhật trạng thái',
  `status` varchar(50) NOT NULL COMMENT 'Trạng thái mới được chuyển sang',
  `note` text COMMENT 'Lý do hoặc ghi chú của hệ thống/HR khi chuyển trạng thái',
  `changed_by_employer_id` int COMMENT 'Người thực hiện thao tác chuyển trạng thái này',
  `created_at` timestamp DEFAULT (now()) COMMENT 'Thời điểm trạng thái thay đổi'
);

CREATE TABLE `note_application` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `application_id` int NOT NULL COMMENT 'Ghi chú này gắn với đơn ứng tuyển nào',
  `employer_id` int NOT NULL COMMENT 'HR nào viết ghi chú này',
  `content` text NOT NULL COMMENT 'Nội dung nhận xét nội bộ về ứng viên',
  `created_at` timestamp DEFAULT (now()),
  `updated_at` timestamp DEFAULT (now())
);

CREATE TABLE `notification` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT 'Người nhận thông báo',
  `title` varchar(255) NOT NULL COMMENT 'Tiêu đề thông báo',
  `content` text NOT NULL COMMENT 'Nội dung thông báo',
  `type` varchar(50) COMMENT 'Loại: application_update, job_alert, payment_success...',
  `related_id` int COMMENT 'ID tham chiếu để click xem chi tiết (Job ID hoặc App ID)',
  `is_read` boolean DEFAULT false COMMENT 'Trạng thái đã đọc hay chưa',
  `created_at` timestamp DEFAULT (now())
);

CREATE TABLE `candidate_favorite_job` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `candidate_id` int NOT NULL COMMENT 'Ứng viên nhấn lưu',
  `job_id` int NOT NULL COMMENT 'Tin tuyển dụng được lưu',
  `created_at` timestamp DEFAULT (now()) COMMENT 'Thời điểm lưu tin'
);

CREATE TABLE `candidate_follow_company` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `candidate_id` int NOT NULL COMMENT 'Ứng viên nhấn follow',
  `company_id` int NOT NULL COMMENT 'Công ty được follow',
  `created_at` timestamp DEFAULT (now()) COMMENT 'Thời điểm follow'
);

ALTER TABLE `company` COMMENT = 'Bảng lưu trữ thông tin nhà tuyển dụng và trạng thái xác thực';

ALTER TABLE `subscription_package` COMMENT = 'Định nghĩa các gói cước và giới hạn tính năng trong hệ thống';

ALTER TABLE `company_subscription` COMMENT = 'Theo dõi tình trạng sử dụng hạn mức thực tế của từng công ty';

ALTER TABLE `candidate_favorite_job` COMMENT = 'Lưu danh sách công việc ứng viên đã thả tim/quan tâm';

ALTER TABLE `candidate_follow_company` COMMENT = 'Dùng để gửi thông báo cho ứng viên khi công ty có tin tuyển dụng mới';

ALTER TABLE `company` ADD FOREIGN KEY (`category_id`) REFERENCES `job_category` (`id`);

ALTER TABLE `company` ADD FOREIGN KEY (`province_id`) REFERENCES `province` (`id`);

ALTER TABLE `company_subscription` ADD FOREIGN KEY (`company_id`) REFERENCES `company` (`id`);

ALTER TABLE `company_subscription` ADD FOREIGN KEY (`package_id`) REFERENCES `subscription_package` (`id`);

ALTER TABLE `payment_transaction` ADD FOREIGN KEY (`company_id`) REFERENCES `company` (`id`);

ALTER TABLE `payment_transaction` ADD FOREIGN KEY (`package_id`) REFERENCES `subscription_package` (`id`);

ALTER TABLE `candidate` ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `candidate` ADD FOREIGN KEY (`province_id`) REFERENCES `province` (`id`);

ALTER TABLE `candidate` ADD FOREIGN KEY (`job_type_id`) REFERENCES `job_type` (`id`);

ALTER TABLE `employer` ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `employer` ADD FOREIGN KEY (`company_id`) REFERENCES `company` (`id`);

ALTER TABLE `job_post` ADD FOREIGN KEY (`employer_id`) REFERENCES `employer` (`id`);

ALTER TABLE `job_post` ADD FOREIGN KEY (`company_id`) REFERENCES `company` (`id`);

ALTER TABLE `job_post` ADD FOREIGN KEY (`category_id`) REFERENCES `job_category` (`id`);

ALTER TABLE `job_post` ADD FOREIGN KEY (`province_id`) REFERENCES `province` (`id`);

ALTER TABLE `job_post` ADD FOREIGN KEY (`job_type_id`) REFERENCES `job_type` (`id`);

ALTER TABLE `job_skill_tag` ADD FOREIGN KEY (`job_id`) REFERENCES `job_post` (`id`);

ALTER TABLE `candidate_job_category` ADD FOREIGN KEY (`candidate_id`) REFERENCES `candidate` (`id`);

ALTER TABLE `candidate_job_category` ADD FOREIGN KEY (`category_id`) REFERENCES `job_category` (`id`);

ALTER TABLE `work_experience` ADD FOREIGN KEY (`candidate_id`) REFERENCES `candidate` (`id`);

ALTER TABLE `education` ADD FOREIGN KEY (`candidate_id`) REFERENCES `candidate` (`id`);

ALTER TABLE `certificate` ADD FOREIGN KEY (`candidate_id`) REFERENCES `candidate` (`id`);

ALTER TABLE `project` ADD FOREIGN KEY (`candidate_id`) REFERENCES `candidate` (`id`);

ALTER TABLE `candidate_skill_tag` ADD FOREIGN KEY (`candidate_id`) REFERENCES `candidate` (`id`);

ALTER TABLE `application` ADD FOREIGN KEY (`job_post_id`) REFERENCES `job_post` (`id`);

ALTER TABLE `application` ADD FOREIGN KEY (`candidate_id`) REFERENCES `candidate` (`id`);

ALTER TABLE `application_status_history` ADD FOREIGN KEY (`application_id`) REFERENCES `application` (`id`);

ALTER TABLE `application_status_history` ADD FOREIGN KEY (`changed_by_employer_id`) REFERENCES `employer` (`id`);

ALTER TABLE `note_application` ADD FOREIGN KEY (`application_id`) REFERENCES `application` (`id`);

ALTER TABLE `note_application` ADD FOREIGN KEY (`employer_id`) REFERENCES `employer` (`id`);

ALTER TABLE `notification` ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `candidate_favorite_job` ADD FOREIGN KEY (`candidate_id`) REFERENCES `candidate` (`id`);

ALTER TABLE `candidate_favorite_job` ADD FOREIGN KEY (`job_id`) REFERENCES `job_post` (`id`);

ALTER TABLE `candidate_follow_company` ADD FOREIGN KEY (`candidate_id`) REFERENCES `candidate` (`id`);

ALTER TABLE `candidate_follow_company` ADD FOREIGN KEY (`company_id`) REFERENCES `company` (`id`);
