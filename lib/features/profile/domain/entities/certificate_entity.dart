import 'package:equatable/equatable.dart';

/// Entity cho chứng chỉ/bằng cấp
class CertificateEntity extends Equatable {
  final int? id;
  final String name;
  final String issuingOrganization;
  final DateTime issueDate;
  final DateTime? expirationDate;
  final String? credentialUrl;

  const CertificateEntity({
    this.id,
    required this.name,
    required this.issuingOrganization,
    required this.issueDate,
    this.expirationDate,
    this.credentialUrl,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    issuingOrganization,
    issueDate,
    expirationDate,
    credentialUrl,
  ];
}
