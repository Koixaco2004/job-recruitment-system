import '../../domain/entities/certificate_entity.dart';

class CertificateModel extends CertificateEntity {
  const CertificateModel({
    super.id,
    required super.name,
    required super.issueDate,
    super.expirationDate,
    super.credentialUrl,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    int? _asIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }
    return CertificateModel(
      id: _asIntNullable(json['id']),
      name: (json['name'] ?? '') as String,
      issueDate: (json['issueDate'] ?? json['issue_date']) != null
          ? DateTime.parse((json['issueDate'] ?? json['issue_date']) as String)
          : DateTime.now(),
      expirationDate: (json['expirationDate'] ?? json['expiration_date']) != null
          ? DateTime.parse((json['expirationDate'] ?? json['expiration_date']) as String)
          : null,
      // DB column is cer_img_url
      credentialUrl: (json['cer_img_url'] ?? json['cerImgUrl'] ?? json['image'] ?? json['imageUrl'] ?? json['image_url'] ?? json['credential_url']) as String?,
    );
  }

  /// Send JSON to BE with Cloudinary URL (not binary upload)
  Map<String, dynamic> toCreateDto() {
    final dto = <String, dynamic>{
      'name': name,
      'issueDate':
          '${issueDate.year}-${issueDate.month.toString().padLeft(2, '0')}-${issueDate.day.toString().padLeft(2, '0')}',
    };
    if (expirationDate != null) {
      dto['expirationDate'] =
          '${expirationDate!.year}-${expirationDate!.month.toString().padLeft(2, '0')}-${expirationDate!.day.toString().padLeft(2, '0')}';
    }
    if (credentialUrl != null && credentialUrl!.isNotEmpty) {
      // Vì DB column là cer_img_url, nên BE có thể dùng map này
      dto['cer_img_url'] = credentialUrl;
      dto['cerImgUrl'] = credentialUrl;
      dto['image'] = credentialUrl;
    }
    return dto;
  }

  Map<String, dynamic> toUpdateDto() => toCreateDto();


  static CertificateModel fromEntity(CertificateEntity entity) {
    return CertificateModel(
      id: entity.id,
      name: entity.name,
      issueDate: entity.issueDate,
      expirationDate: entity.expirationDate,
      credentialUrl: entity.credentialUrl,
    );
  }
}
