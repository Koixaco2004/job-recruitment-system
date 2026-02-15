import '../../../../core/error/exceptions.dart';
import '../../../jobs/data/datasources/job_remote_datasource.dart';
import '../../../jobs/data/models/job_post_model.dart';
import '../models/company_model.dart';

/// Interface cho Company Remote Data Source
abstract class CompanyRemoteDataSource {
  Future<List<CompanyModel>> getCompanies();
  Future<CompanyModel> getCompanyById(int employerId);
  Future<List<CompanyModel>> searchCompanies(String query);
  Future<List<JobPostModel>> getCompanyJobs(int employerId);
}

/// Mock implementation
class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  final JobRemoteDataSource jobRemoteDataSource;

  CompanyRemoteDataSourceImpl({required this.jobRemoteDataSource});

  // Mock storage
  static final List<CompanyModel> _mockCompanies = [
    const CompanyModel(
      employerId: 1,
      companyName: 'FPT Software',
      logoUrl: 'https://i.pravatar.cc/150?img=1',
      coverImageUrl: 'https://picsum.photos/800/300?random=1',
      industryName: 'Công nghệ thông tin',
      companySize: '1000+',
      website: 'https://fptsoftware.com',
      description:
          'FPT Software là công ty phần mềm hàng đầu Việt Nam, cung cấp dịch vụ chuyển đổi số toàn diện cho khách hàng toàn cầu.',
      address: '17 Duy Tân, Cầu Giấy',
      cityName: 'Hà Nội',
      benefits:
          '• Lương thưởng cạnh tranh\n• Bảo hiểm sức khỏe\n• Đào tạo nâng cao kỹ năng\n• Môi trường làm việc quốc tế',
      foundedYear: 1999,
      jobCount: 15,
    ),
    const CompanyModel(
      employerId: 2,
      companyName: 'VNG Corporation',
      logoUrl: 'https://i.pravatar.cc/150?img=2',
      coverImageUrl: 'https://picsum.photos/800/300?random=2',
      industryName: 'Game & Entertainment',
      companySize: '501-1000',
      website: 'https://vng.com.vn',
      description:
          'VNG là tập đoàn công nghệ hàng đầu Việt Nam, phát triển các sản phẩm game, mạng xã hội và dịch vụ số.',
      address: 'Tòa nhà VNG, Tân Bình',
      cityName: 'Hồ Chí Minh',
      benefits:
          '• Lương cao + Thưởng KPI\n• Bảo hiểm cao cấp\n• Du lịch hàng năm\n• Văn hóa làm việc trẻ trung',
      foundedYear: 2004,
      jobCount: 12,
    ),
    const CompanyModel(
      employerId: 3,
      companyName: 'Tiki Corporation',
      logoUrl: 'https://i.pravatar.cc/150?img=3',
      coverImageUrl: 'https://picsum.photos/800/300?random=3',
      industryName: 'Thương mại điện tử',
      companySize: '201-500',
      website: 'https://tiki.vn',
      description:
          'Tiki là sàn thương mại điện tử hàng đầu Việt Nam, cung cấp hàng triệu sản phẩm với dịch vụ giao hàng nhanh.',
      address: '52 Út Tịch, Tân Bình',
      cityName: 'Hồ Chí Minh',
      benefits:
          '• Mức lương hấp dẫn\n• Thưởng theo hiệu quả\n• Cơ hội thăng tiến\n• Môi trường startup năng động',
      foundedYear: 2010,
      jobCount: 8,
    ),
    const CompanyModel(
      employerId: 4,
      companyName: 'Viettel Solutions',
      logoUrl: 'https://i.pravatar.cc/150?img=4',
      coverImageUrl: 'https://picsum.photos/800/300?random=4',
      industryName: 'Viễn thông & CNTT',
      companySize: '1000+',
      website: 'https://viettelsolutions.vn',
      description:
          'Viettel Solutions cung cấp giải pháp chuyển đổi số toàn diện cho doanh nghiệp và chính phủ.',
      address: 'Tòa nhà Viettel, Cầu Giấy',
      cityName: 'Hà Nội',
      benefits:
          '• Lương thưởng theo năng lực\n• Chế độ BHXH đầy đủ\n• Đào tạo chuyên sâu\n• Cơ hội làm việc với công nghệ mới',
      foundedYear: 2008,
      jobCount: 20,
    ),
    const CompanyModel(
      employerId: 5,
      companyName: 'Shopee Vietnam',
      logoUrl: 'https://i.pravatar.cc/150?img=5',
      coverImageUrl: 'https://picsum.photos/800/300?random=5',
      industryName: 'E-commerce',
      companySize: '501-1000',
      website: 'https://shopee.vn',
      description:
          'Shopee là nền tảng thương mại điện tử hàng đầu Đông Nam Á, phục vụ hàng triệu người dùng mỗi ngày.',
      address: 'Tòa nhà Viettel Complex, Hà Đông',
      cityName: 'Hà Nội',
      benefits:
          '• Lương cạnh tranh + Bonus\n• Bảo hiểm sức khỏe toàn diện\n• Team building định kỳ\n• Văn hóa đa quốc gia',
      foundedYear: 2015,
      jobCount: 10,
    ),
    const CompanyModel(
      employerId: 6,
      companyName: 'Grab Vietnam',
      logoUrl: 'https://i.pravatar.cc/150?img=6',
      coverImageUrl: 'https://picsum.photos/800/300?random=6',
      industryName: 'Technology & Logistics',
      companySize: '201-500',
      website: 'https://grab.com',
      description:
          'Grab là siêu ứng dụng hàng đầu Đông Nam Á, cung cấp dịch vụ giao thông, giao hàng và thanh toán.',
      address: 'Tòa nhà Sài Gòn Centre, Quận 1',
      cityName: 'Hồ Chí Minh',
      benefits:
          '• Lương cao + Stock options\n• Bảo hiểm premium\n• Flexible working\n• Cơ hội làm việc khu vực',
      foundedYear: 2014,
      jobCount: 7,
    ),
    const CompanyModel(
      employerId: 7,
      companyName: 'Momo E-Wallet',
      logoUrl: 'https://i.pravatar.cc/150?img=7',
      coverImageUrl: 'https://picsum.photos/800/300?random=7',
      industryName: 'Fintech',
      companySize: '201-500',
      website: 'https://momo.vn',
      description:
          'Momo là ví điện tử hàng đầu Việt Nam với hơn 30 triệu người dùng, cung cấp dịch vụ thanh toán toàn diện.',
      address: 'Tòa nhà Phú Mỹ Hưng, Quận 7',
      cityName: 'Hồ Chí Minh',
      benefits:
          '• Lương thưởng hấp dẫn\n• ESOP cho nhân viên\n• Bảo hiểm cao cấp\n• Môi trường fintech năng động',
      foundedYear: 2007,
      jobCount: 9,
    ),
    const CompanyModel(
      employerId: 8,
      companyName: 'Sendo Technology',
      logoUrl: 'https://i.pravatar.cc/150?img=8',
      industryName: 'E-commerce Platform',
      companySize: '51-200',
      website: 'https://sendo.vn',
      description:
          'Sendo là nền tảng thương mại điện tử kết nối người mua và người bán trên toàn quốc.',
      address: 'Tòa nhà Flemington, Quận 11',
      cityName: 'Hồ Chí Minh',
      benefits:
          '• Lương cạnh tranh\n• Thưởng theo dự án\n• Bảo hiểm đầy đủ\n• Cơ hội phát triển',
      foundedYear: 2012,
      jobCount: 5,
    ),
    const CompanyModel(
      employerId: 9,
      companyName: 'VinID - VinGroup',
      logoUrl: 'https://i.pravatar.cc/150?img=9',
      coverImageUrl: 'https://picsum.photos/800/300?random=9',
      industryName: 'Technology & Retail',
      companySize: '1000+',
      website: 'https://vinid.net',
      description:
          'VinID là nền tảng công nghệ của VinGroup, cung cấp giải pháp số hóa cho hệ sinh thái Vingroup.',
      address: 'Vinhomes Central Park, Bình Thạnh',
      cityName: 'Hồ Chí Minh',
      benefits:
          '• Lương thưởng theo năng lực\n• Bảo hiểm VinGroup\n• Ưu đãi sản phẩm Vingroup\n• Môi trường tập đoàn lớn',
      foundedYear: 2018,
      jobCount: 11,
    ),
    const CompanyModel(
      employerId: 10,
      companyName: 'Zalo - VNG',
      logoUrl: 'https://i.pravatar.cc/150?img=10',
      coverImageUrl: 'https://picsum.photos/800/300?random=10',
      industryName: 'Social Network',
      companySize: '201-500',
      website: 'https://zalo.me',
      description:
          'Zalo là ứng dụng nhắn tin và mạng xã hội hàng đầu Việt Nam với hơn 100 triệu người dùng.',
      address: 'Tòa nhà VNG, Tân Bình',
      cityName: 'Hồ Chí Minh',
      benefits:
          '• Lương cao + Bonus\n• Bảo hiểm sức khỏe\n• Làm việc với sản phẩm hàng đầu\n• Văn hóa sáng tạo',
      foundedYear: 2012,
      jobCount: 6,
    ),
  ];

  @override
  Future<List<CompanyModel>> getCompanies() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockCompanies;
  }

  @override
  Future<CompanyModel> getCompanyById(int employerId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _mockCompanies.firstWhere((c) => c.employerId == employerId);
    } catch (e) {
      throw const ServerException('Không tìm thấy công ty');
    }
  }

  @override
  Future<List<CompanyModel>> searchCompanies(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (query.isEmpty) {
      return _mockCompanies;
    }

    final lowerQuery = query.toLowerCase();
    return _mockCompanies
        .where(
          (c) =>
              c.companyName.toLowerCase().contains(lowerQuery) ||
              (c.industryName?.toLowerCase().contains(lowerQuery) ?? false),
        )
        .toList();
  }

  @override
  Future<List<JobPostModel>> getCompanyJobs(int employerId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Get all jobs from JobRemoteDataSource
    final allJobs = await jobRemoteDataSource.getJobs();

    // Filter jobs by employerId
    return allJobs.where((job) => job.employerId == employerId).toList();
  }
}
