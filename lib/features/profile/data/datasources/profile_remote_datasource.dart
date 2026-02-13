import '../models/candidate_profile_model.dart';

/// Abstract interface cho Profile Data Source
abstract class ProfileRemoteDataSource {
  Future<CandidateProfileModel> getProfile();
  Future<CandidateProfileModel> updateProfile(CandidateProfileModel profile);
}

/// Mock implementation
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  CandidateProfileModel? _cachedProfile;

  @override
  Future<CandidateProfileModel> getProfile() async {
    // Giả lập delay network
    await Future.delayed(const Duration(seconds: 1));

    _cachedProfile ??= CandidateProfileModel.fromJson(_mockProfileData);
    return _cachedProfile!;
  }

  @override
  Future<CandidateProfileModel> updateProfile(
    CandidateProfileModel profile,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _cachedProfile = profile;
    return _cachedProfile!;
  }

  static final Map<String, dynamic> _mockProfileData = {
    // USERS table
    'user_id': 1,
    'email': 'nguyenvana@gmail.com',
    'phone': '0901234567',
    'full_name': 'Nguyễn Văn A',
    'avatar_url': null,

    // CANDIDATES table
    'candidate_id': 1,
    'date_of_birth': '1998-05-15',
    'gender': 'Nam',
    'address': '123 Nguyễn Huệ, Quận 1',
    'city_name': 'Hồ Chí Minh',
    'education_level': 'Đại học',
    'years_of_experience': 3,
    'current_job_title': 'Mobile Developer',
    'desired_job_title': 'Senior Flutter Developer',
    'desired_salary_min': 25000000,
    'desired_salary_max': 40000000,
    'desired_job_type': 'fulltime',
    'skills': [
      'Flutter',
      'Dart',
      'Firebase',
      'REST API',
      'Git',
      'Agile/Scrum',
      'UI/UX Design',
      'State Management',
    ],
    'cv_file_url': null,
    'industry': 'Công nghệ thông tin',
    'is_searchable': true,
    'created_at': '2024-01-15T08:00:00Z',
    'updated_at': '2025-02-10T10:30:00Z',

    // Kinh nghiệm làm việc
    'work_experiences': [
      {
        'id': 1,
        'company_name': 'VNG Corporation',
        'position': 'Mobile Developer',
        'start_date': '2023-06-01',
        'end_date': null,
        'description':
            'Phát triển ứng dụng di động với Flutter. Tham gia xây dựng tính năng chat real-time, tích hợp payment gateway. Làm việc trong team Agile 8 người.',
        'is_current_job': true,
      },
      {
        'id': 2,
        'company_name': 'FPT Software',
        'position': 'Junior Flutter Developer',
        'start_date': '2022-01-15',
        'end_date': '2023-05-30',
        'description':
            'Phát triển ứng dụng e-commerce. Sử dụng BLoC pattern, REST API. Tham gia code review và mentoring intern.',
        'is_current_job': false,
      },
      {
        'id': 3,
        'company_name': 'Freelance',
        'position': 'Mobile App Developer',
        'start_date': '2021-06-01',
        'end_date': '2021-12-31',
        'description':
            'Phát triển ứng dụng quản lý bán hàng cho cửa hàng nhỏ. Sử dụng Flutter + Firebase.',
        'is_current_job': false,
      },
    ],

    // Học vấn
    'educations': [
      {
        'id': 1,
        'institution': 'Đại học Bách Khoa TP.HCM',
        'degree': 'Đại học',
        'field_of_study': 'Khoa học Máy tính',
        'start_date': '2016-09-01',
        'end_date': '2021-06-30',
        'description':
            'GPA: 3.2/4.0. Đồ án tốt nghiệp: Ứng dụng quản lý tuyển dụng.',
      },
      {
        'id': 2,
        'institution': 'Udemy',
        'degree': 'Online Course',
        'field_of_study': 'Flutter & Dart Complete Guide',
        'start_date': '2021-03-01',
        'end_date': '2021-05-30',
        'description': 'Hoàn thành khóa học 40 giờ về Flutter development.',
      },
    ],

    // Chứng chỉ
    'certificates': [
      {
        'id': 1,
        'name': 'Google Associate Android Developer',
        'issuing_organization': 'Google',
        'issue_date': '2023-03-15',
        'expiration_date': '2026-03-15',
        'credential_url': 'https://credential.google.com/abc123',
      },
      {
        'id': 2,
        'name': 'AWS Cloud Practitioner',
        'issuing_organization': 'Amazon Web Services',
        'issue_date': '2023-08-20',
        'expiration_date': null,
        'credential_url': null,
      },
    ],

    // Ngoại ngữ
    'languages': [
      {'id': 1, 'name': 'Tiếng Anh', 'proficiency': 'Cao cấp'},
      {'id': 2, 'name': 'Tiếng Nhật', 'proficiency': 'Sơ cấp'},
    ],
  };
}
