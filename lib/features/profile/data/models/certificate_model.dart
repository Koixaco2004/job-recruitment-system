import '../../domain/entities/certificate_entity.dart';

class CertificateModel extends CertificateEntity {
  const CertificateModel({
    super.id,
    required super.name,
    required super.issuingOrganization,
    required super.issueDate,
    super.expirationDate,
    super.credentialUrl,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      issuingOrganization: json['issuing_organization'] as String,
      issueDate: DateTime.parse(json['issue_date'] as String),
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'] as String)
          : null,
      credentialUrl: json['credential_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'issuing_organization': issuingOrganization,
      'issue_date': issueDate.toIso8601String(),
      'expiration_date': expirationDate?.toIso8601String(),
      'credential_url': credentialUrl,
    };
  }
}
