import '../../../../core/error/exceptions.dart';
import '../models/application_model.dart';
import '../models/job_post_model.dart';

/// Abstract interface cho Remote Data Source
abstract class JobRemoteDataSource {
  /// Lấy danh sách jobs từ API
  Future<List<JobPostModel>> getJobs();

  /// Lấy job theo ID
  Future<JobPostModel> getJobById(int jobId);

  /// Gửi đơn ứng tuyển
  Future<ApplicationModel> submitApplication({
    required int jobPostId,
    required int candidateId,
    String? cvFileUrl,
    String? coverLetter,
  });
}

/// Implementation với Mock Data
class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  @override
  Future<List<JobPostModel>> getJobs() async {
    // Giả lập delay 1 giây như gọi API thật
    await Future.delayed(const Duration(seconds: 1));

    // Mock data - danh sách 8 jobs
    final mockJobs = [
      {
        'job_post_id': 1,
        'employer_id': 1,
        'title': 'Senior Flutter Developer',
        'description':
            'Chúng tôi đang tìm kiếm Senior Flutter Developer có kinh nghiệm để tham gia vào các dự án mobile app lớn.',
        'requirements':
            '- 3+ năm kinh nghiệm Flutter\n- Thành thạo Dart, Clean Architecture\n- Kinh nghiệm với State Management (Provider, Bloc, Riverpod)',
        'benefits':
            '- Lương: 25-35 triệu\n- Thưởng theo dự án\n- Bảo hiểm đầy đủ\n- Du lịch hàng năm',
        'job_type': 'fulltime',
        'job_level': 'senior',
        'salary_min': 25000000,
        'salary_max': 35000000,
        'salary_type': 'VND',
        'number_of_positions': 2,
        'experience_required': 3,
        'education_required': 'Đại học',
        'address': '123 Nguyễn Huệ, Quận 1',
        'deadline': DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String(),
        'status': 'approved',
        'is_priority': true,
        'view_count': 1250,
        'application_count': 45,
        'created_at': '2024-01-15T00:00:00Z',
        'updated_at': '2024-01-15T00:00:00Z',
        'company_name': 'VNG Corporation',
        'company_logo': 'https://i.pravatar.cc/150?img=10',
        'city_name': 'Hồ Chí Minh',
        'industry_name': 'Công nghệ thông tin',
      },
      {
        'job_post_id': 2,
        'employer_id': 2,
        'title': 'Backend Developer (Node.js)',
        'description':
            'Tham gia phát triển hệ thống backend cho ứng dụng fintech.',
        'requirements':
            '- 2+ năm kinh nghiệm Node.js\n- Thành thạo Express, NestJS\n- Kinh nghiệm với MongoDB, PostgreSQL',
        'benefits':
            '- Lương cạnh tranh\n- Làm việc remote linh hoạt\n- Môi trường startup năng động',
        'job_type': 'remote',
        'job_level': 'middle',
        'salary_min': 20000000,
        'salary_max': 30000000,
        'salary_type': 'VND',
        'number_of_positions': 3,
        'experience_required': 2,
        'education_required': 'Đại học',
        'address': null,
        'deadline': DateTime.now()
            .add(const Duration(days: 25))
            .toIso8601String(),
        'status': 'approved',
        'is_priority': false,
        'view_count': 890,
        'application_count': 32,
        'created_at': '2024-01-20T00:00:00Z',
        'updated_at': '2024-01-20T00:00:00Z',
        'company_name': 'Momo',
        'company_logo': 'https://i.pravatar.cc/150?img=11',
        'city_name': 'Remote',
        'industry_name': 'Fintech',
      },
      {
        'job_post_id': 3,
        'employer_id': 3,
        'title': 'Junior Frontend Developer (ReactJS)',
        'description':
            'Cơ hội tuyệt vời cho fresher/junior muốn phát triển sự nghiệp Frontend.',
        'requirements':
            '- Kiến thức cơ bản về ReactJS\n- HTML, CSS, JavaScript\n- Nhiệt tình, ham học hỏi',
        'benefits':
            '- Đào tạo bài bản\n- Mentor 1-1\n- Lương tăng nhanh theo năng lực',
        'job_type': 'fulltime',
        'job_level': 'junior',
        'salary_min': 10000000,
        'salary_max': 15000000,
        'salary_type': 'VND',
        'number_of_positions': 5,
        'experience_required': 0,
        'education_required': 'Cao đẳng trở lên',
        'address': '456 Lê Lợi, Quận 1',
        'deadline': DateTime.now()
            .add(const Duration(days: 20))
            .toIso8601String(),
        'status': 'approved',
        'is_priority': false,
        'view_count': 2100,
        'application_count': 120,
        'created_at': '2024-01-22T00:00:00Z',
        'updated_at': '2024-01-22T00:00:00Z',
        'company_name': 'FPT Software',
        'company_logo': 'https://i.pravatar.cc/150?img=12',
        'city_name': 'Hồ Chí Minh',
        'industry_name': 'Công nghệ thông tin',
      },
      {
        'job_post_id': 4,
        'employer_id': 4,
        'title': 'DevOps Engineer',
        'description':
            'Xây dựng và vận hành hạ tầng cloud cho các sản phẩm công ty.',
        'requirements':
            '- Kinh nghiệm với AWS/GCP/Azure\n- Docker, Kubernetes\n- CI/CD pipelines',
        'benefits':
            '- Lương: 30-45 triệu\n- Làm việc với công nghệ mới nhất\n- Team quốc tế',
        'job_type': 'fulltime',
        'job_level': 'senior',
        'salary_min': 30000000,
        'salary_max': 45000000,
        'salary_type': 'VND',
        'number_of_positions': 1,
        'experience_required': 4,
        'education_required': 'Đại học',
        'address': '789 Trần Hưng Đạo, Ba Đình',
        'deadline': DateTime.now()
            .add(const Duration(days: 15))
            .toIso8601String(),
        'status': 'approved',
        'is_priority': true,
        'view_count': 650,
        'application_count': 18,
        'created_at': '2024-01-25T00:00:00Z',
        'updated_at': '2024-01-25T00:00:00Z',
        'company_name': 'Tiki',
        'company_logo': 'https://i.pravatar.cc/150?img=13',
        'city_name': 'Hà Nội',
        'industry_name': 'Thương mại điện tử',
      },
      {
        'job_post_id': 5,
        'employer_id': 5,
        'title': 'UI/UX Designer',
        'description': 'Thiết kế giao diện cho ứng dụng mobile và web.',
        'requirements':
            '- Thành thạo Figma, Adobe XD\n- Hiểu biết về UX principles\n- Portfolio ấn tượng',
        'benefits':
            '- Lương: 15-25 triệu\n- Làm việc với các designer senior\n- Dự án đa dạng',
        'job_type': 'fulltime',
        'job_level': 'middle',
        'salary_min': 15000000,
        'salary_max': 25000000,
        'salary_type': 'VND',
        'number_of_positions': 2,
        'experience_required': 2,
        'education_required': 'Không yêu cầu',
        'address': '321 Võ Văn Tần, Quận 3',
        'deadline': DateTime.now()
            .add(const Duration(days: 18))
            .toIso8601String(),
        'status': 'approved',
        'is_priority': false,
        'view_count': 1450,
        'application_count': 67,
        'created_at': '2024-01-28T00:00:00Z',
        'updated_at': '2024-01-28T00:00:00Z',
        'company_name': 'Shopee',
        'company_logo': 'https://i.pravatar.cc/150?img=14',
        'city_name': 'Hồ Chí Minh',
        'industry_name': 'Thương mại điện tử',
      },
      {
        'job_post_id': 6,
        'employer_id': 6,
        'title': 'Data Analyst',
        'description': 'Phân tích dữ liệu để hỗ trợ quyết định kinh doanh.',
        'requirements':
            '- SQL, Python\n- Power BI hoặc Tableau\n- Tư duy phân tích tốt',
        'benefits':
            '- Lương: 18-28 triệu\n- Làm việc với big data\n- Cơ hội thăng tiến',
        'job_type': 'fulltime',
        'job_level': 'middle',
        'salary_min': 18000000,
        'salary_max': 28000000,
        'salary_type': 'VND',
        'number_of_positions': 2,
        'experience_required': 2,
        'education_required': 'Đại học',
        'address': '555 Nguyễn Thị Minh Khai, Quận 3',
        'deadline': DateTime.now()
            .add(const Duration(days: 22))
            .toIso8601String(),
        'status': 'approved',
        'is_priority': false,
        'view_count': 780,
        'application_count': 41,
        'created_at': '2024-02-01T00:00:00Z',
        'updated_at': '2024-02-01T00:00:00Z',
        'company_name': 'Grab',
        'company_logo': 'https://i.pravatar.cc/150?img=15',
        'city_name': 'Hồ Chí Minh',
        'industry_name': 'Công nghệ - Logistics',
      },
      {
        'job_post_id': 7,
        'employer_id': 7,
        'title': 'Mobile App Developer (iOS)',
        'description': 'Phát triển ứng dụng iOS native cho ngân hàng.',
        'requirements':
            '- Swift, SwiftUI\n- 2+ năm kinh nghiệm iOS\n- Hiểu biết về security',
        'benefits':
            '- Lương: 22-32 triệu\n- Bảo hiểm cao cấp\n- Thưởng cuối năm hấp dẫn',
        'job_type': 'fulltime',
        'job_level': 'middle',
        'salary_min': 22000000,
        'salary_max': 32000000,
        'salary_type': 'VND',
        'number_of_positions': 1,
        'experience_required': 2,
        'education_required': 'Đại học',
        'address': '100 Lê Duẩn, Quận 1',
        'deadline': DateTime.now()
            .add(const Duration(days: 12))
            .toIso8601String(),
        'status': 'approved',
        'is_priority': true,
        'view_count': 520,
        'application_count': 28,
        'created_at': '2024-02-03T00:00:00Z',
        'updated_at': '2024-02-03T00:00:00Z',
        'company_name': 'Techcombank',
        'company_logo': 'https://i.pravatar.cc/150?img=16',
        'city_name': 'Hồ Chí Minh',
        'industry_name': 'Ngân hàng - Tài chính',
      },
      {
        'job_post_id': 8,
        'employer_id': 8,
        'title': 'Content Writer (Part-time)',
        'description': 'Viết content cho website và social media.',
        'requirements':
            '- Kỹ năng viết tốt\n- Hiểu biết về SEO\n- Sáng tạo, chủ động',
        'benefits': '- Lương: 5-8 triệu\n- Làm việc linh hoạt\n- Làm remote',
        'job_type': 'parttime',
        'job_level': 'fresher',
        'salary_min': 5000000,
        'salary_max': 8000000,
        'salary_type': 'VND',
        'number_of_positions': 3,
        'experience_required': 0,
        'education_required': 'Không yêu cầu',
        'address': null,
        'deadline': DateTime.now()
            .add(const Duration(days: 10))
            .toIso8601String(),
        'status': 'approved',
        'is_priority': false,
        'view_count': 1890,
        'application_count': 156,
        'created_at': '2024-02-05T00:00:00Z',
        'updated_at': '2024-02-05T00:00:00Z',
        'company_name': 'Sendo',
        'company_logo': 'https://i.pravatar.cc/150?img=17',
        'city_name': 'Remote',
        'industry_name': 'Thương mại điện tử',
      },
    ];

    return mockJobs.map((json) => JobPostModel.fromJson(json)).toList();
  }

  @override
  Future<JobPostModel> getJobById(int jobId) async {
    await Future.delayed(const Duration(seconds: 1));

    final jobs = await getJobs();
    try {
      return jobs.firstWhere((job) => job.jobPostId == jobId);
    } catch (e) {
      throw const ServerException('Không tìm thấy job post');
    }
  }

  @override
  Future<ApplicationModel> submitApplication({
    required int jobPostId,
    required int candidateId,
    String? cvFileUrl,
    String? coverLetter,
  }) async {
    // Giả lập delay network
    await Future.delayed(const Duration(seconds: 1));

    // Mock: tạo application thành công
    return ApplicationModel(
      applicationId: DateTime.now().millisecondsSinceEpoch,
      jobPostId: jobPostId,
      candidateId: candidateId,
      cvFileUrl: cvFileUrl,
      coverLetter: coverLetter,
      status: 'submitted',
      appliedAt: DateTime.now(),
    );
  }
}
