import 'package:equatable/equatable.dart';

/// Entity đại diện cho thông tin công ty/nhà tuyển dụng
class CompanyEntity extends Equatable {
  final int employerId; // Backend 'id'
  final int? userCreatorId;
  final int? categoryId;
  final String companyName; // Backend 'name'
  final String? emailContact;
  final String? phoneContact;
  final String? address;
  final int? provinceId;
  final String? cityName; // Fallback for province
  final String? logoUrl;
  final String? coverImageUrl; // Backend 'bannerUrl'
  final String? industryName; // Fallback for category
  final String? companySize;
  final String? website; // Backend 'websiteUrl'
  final String? facebookUrl;
  final String? linkedinUrl;
  final String? description;
  final String? content;
  final String? benefits;
  final int? foundedYear;
  final int jobCount;
  final bool isVerified;
  final List<String>? images;
  final String? slug;

  const CompanyEntity({
    required this.employerId,
    required this.companyName,
    this.userCreatorId,
    this.categoryId,
    this.emailContact,
    this.phoneContact,
    this.address,
    this.provinceId,
    this.cityName,
    this.logoUrl,
    this.coverImageUrl,
    this.industryName,
    this.companySize,
    this.website,
    this.facebookUrl,
    this.linkedinUrl,
    this.description,
    this.content,
    this.benefits,
    this.foundedYear,
    this.jobCount = 0,
    this.isVerified = false,
    this.images,
    this.slug,
  });

  @override
  List<Object?> get props => [
        employerId,
        companyName,
        userCreatorId,
        categoryId,
        emailContact,
        phoneContact,
        address,
        provinceId,
        cityName,
        logoUrl,
        coverImageUrl,
        industryName,
        companySize,
        website,
        facebookUrl,
        linkedinUrl,
        description,
        content,
        benefits,
        foundedYear,
        jobCount,
        isVerified,
        images,
        slug,
      ];
}
