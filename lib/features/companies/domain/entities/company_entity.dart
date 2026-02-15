import 'package:equatable/equatable.dart';

/// Entity đại diện cho thông tin công ty/nhà tuyển dụng
class CompanyEntity extends Equatable {
  final int employerId;
  final String companyName;
  final String? logoUrl;
  final String? coverImageUrl;
  final String? industryName;
  final String? companySize;
  final String? website;
  final String? description;
  final String? address;
  final String? cityName;
  final String? benefits;
  final int? foundedYear;
  final int jobCount; // Số lượng việc làm đang tuyển

  const CompanyEntity({
    required this.employerId,
    required this.companyName,
    this.logoUrl,
    this.coverImageUrl,
    this.industryName,
    this.companySize,
    this.website,
    this.description,
    this.address,
    this.cityName,
    this.benefits,
    this.foundedYear,
    this.jobCount = 0,
  });

  @override
  List<Object?> get props => [
    employerId,
    companyName,
    logoUrl,
    coverImageUrl,
    industryName,
    companySize,
    website,
    description,
    address,
    cityName,
    benefits,
    foundedYear,
    jobCount,
  ];
}
