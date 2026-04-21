import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/employer_entity.dart';
import '../../domain/usecases/employer_usecases.dart';
import '../../../companies/domain/usecases/update_company_usecase.dart';
import '../../../companies/domain/usecases/upload_company_logo_usecase.dart';
import '../../../companies/domain/usecases/upload_company_banner_usecase.dart';
import '../../../companies/domain/usecases/upload_company_gallery_image_usecase.dart';
import '../../../companies/domain/usecases/upload_company_business_license_usecase.dart';

class EmployerProvider extends ChangeNotifier {
  final GetEmployerProfileUseCase getEmployerProfileUseCase;
  final SetupCompanyUseCase setupCompanyUseCase;
  final UpdateEmployerProfileUseCase updateEmployerProfileUseCase;
  final UploadEmployerAvatarUseCase uploadEmployerAvatarUseCase;

  // Company management use cases
  final UpdateCompanyUseCase updateCompanyUseCase;
  final UploadCompanyLogoUseCase uploadCompanyLogoUseCase;
  final UploadCompanyBannerUseCase uploadCompanyBannerUseCase;
  final UploadCompanyGalleryImageUseCase uploadCompanyGalleryImageUseCase;
  final UploadCompanyBusinessLicenseUseCase uploadCompanyBusinessLicenseUseCase;

  // Member management use cases
  final GetMembersUseCase getMembersUseCase;
  final AddMemberUseCase addMemberUseCase;
  final RemoveMemberUseCase removeMemberUseCase;

  EmployerProvider({
    required this.getEmployerProfileUseCase,
    required this.setupCompanyUseCase,
    required this.updateEmployerProfileUseCase,
    required this.uploadEmployerAvatarUseCase,
    required this.updateCompanyUseCase,
    required this.uploadCompanyLogoUseCase,
    required this.uploadCompanyBannerUseCase,
    required this.uploadCompanyGalleryImageUseCase,
    required this.uploadCompanyBusinessLicenseUseCase,
    required this.getMembersUseCase,
    required this.addMemberUseCase,
    required this.removeMemberUseCase,
  });

  EmployerEntity? _employer;
  EmployerEntity? get employer => _employer;

  List<EmployerEntity> _members = [];
  List<EmployerEntity> get members => _members;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _isMemberLoading = false;
  bool get isMemberLoading => _isMemberLoading;

  bool _isAddingMember = false;
  bool get isAddingMember => _isAddingMember;

  bool _isUploadingAvatar = false;
  bool get isUploadingAvatar => _isUploadingAvatar;

  bool _isSavingCompany = false;
  bool get isSavingCompany => _isSavingCompany;

  bool _isUploadingLogo = false;
  bool get isUploadingLogo => _isUploadingLogo;

  bool _isUploadingBanner = false;
  bool get isUploadingBanner => _isUploadingBanner;

  bool _isUploadingGallery = false;
  bool get isUploadingGallery => _isUploadingGallery;

  bool _isUploadingBusinessLicense = false;
  bool get isUploadingBusinessLicense => _isUploadingBusinessLicense;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  void clear() {
    _employer = null;
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
    _isSaving = false;
    _isUploadingAvatar = false;
    _isSavingCompany = false;
    _isUploadingLogo = false;
    _isUploadingBanner = false;
    _isUploadingGallery = false;
    _isUploadingBusinessLicense = false;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> getProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getEmployerProfileUseCase();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (employer) {
        _employer = employer;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> setupCompany({
    required String fullName,
    required String phoneContact,
    required String companyName,
    required int categoryId,
    int? provinceId,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await setupCompanyUseCase(
      fullName: fullName,
      phoneContact: phoneContact,
      companyName: companyName,
      categoryId: categoryId,
      provinceId: provinceId,
      address: address,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) async {
        // Refresh profile after setup
        await getProfile();
        return true;
      },
    );
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phoneContact,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await updateEmployerProfileUseCase(
      fullName: fullName,
      phoneContact: phoneContact,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isSaving = false;
        notifyListeners();
        return false;
      },
      (updatedEmployer) async {
        _successMessage = 'Cập nhật thông tin thành công!';
        // Important: Refetch the full profile to ensure the nested company object is preserved
        await getProfile();
        _isSaving = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> pickAndUploadAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final bytes = file.bytes;
      final fileName = file.name;

      if (bytes == null) {
        _errorMessage = 'Không thể đọc file ảnh';
        notifyListeners();
        return;
      }

      _isUploadingAvatar = true;
      _errorMessage = null;
      notifyListeners();

      final uploadResult = await uploadEmployerAvatarUseCase(
        imageBytes: bytes,
        fileName: fileName,
      );

      uploadResult.fold(
        (failure) {
          _errorMessage = failure.message;
        },
        (avatarUrl) async {
          _successMessage = 'Cập nhật ảnh đại diện thành công!';
          await getProfile();
        },
      );
      
      _isUploadingAvatar = false;
      notifyListeners();
    } catch (e) {
      _isUploadingAvatar = false;
      _errorMessage = 'Lỗi chọn ảnh: $e';
      notifyListeners();
    }
  }

  // --- Company Profile Management ---

  Future<bool> updateCompanyProfile({
    required String name,
    String? description,
    String? content,
    String? websiteUrl,
    String? address,
    int? provinceId,
    int? categoryId,
    String? emailContact,
    String? phoneContact,
    String? companySize,
    String? facebookUrl,
    String? linkedinUrl,
  }) async {
    _isSavingCompany = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await updateCompanyUseCase(
      name: name,
      description: description,
      content: content,
      websiteUrl: websiteUrl,
      address: address,
      provinceId: provinceId,
      categoryId: categoryId,
      emailContact: emailContact,
      phoneContact: phoneContact,
      companySize: companySize,
      facebookUrl: facebookUrl,
      linkedinUrl: linkedinUrl,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isSavingCompany = false;
        notifyListeners();
        return false;
      },
      (updatedCompany) async {
        _successMessage = 'Cập nhật thông tin công ty thành công!';
        
        // Patch local state directly using the same entity structure
        // Note: We use dynamic to bypass the type conflict between features/companies and features/employer entities
        if (_employer != null) {
          await getProfile(); // Refetch first to get the most consistent state from server
        }
        
        _isSavingCompany = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> pickAndUploadLogo() async {
    await _pickAndUploadImage(
      setLoading: (val) => _isUploadingLogo = val,
      uploadFunc: uploadCompanyLogoUseCase.call,
      successMsg: 'Cập nhật Logo thành công!',
    );
  }

  Future<void> pickAndUploadBanner() async {
    await _pickAndUploadImage(
      setLoading: (val) => _isUploadingBanner = val,
      uploadFunc: uploadCompanyBannerUseCase.call,
      successMsg: 'Cập nhật ảnh bìa thành công!',
    );
  }

  Future<void> pickAndUploadGalleryImage() async {
    await _pickAndUploadImage(
      setLoading: (val) => _isUploadingGallery = val,
      uploadFunc: uploadCompanyGalleryImageUseCase.call,
      successMsg: 'Đã thêm ảnh vào bộ sưu tập!',
    );
  }

  Future<void> pickAndUploadBusinessLicense() async {
    await _pickAndUploadImage(
      setLoading: (val) => _isUploadingBusinessLicense = val,
      uploadFunc: uploadCompanyBusinessLicenseUseCase.call,
      successMsg: 'Tải lên Giấy phép kinh doanh thành công!',
    );
  }

  Future<void> _pickAndUploadImage({
    required Function(bool) setLoading,
    required Future<Either<Failure, String>> Function(Uint8List, String) uploadFunc,
    required String successMsg,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final bytes = file.bytes;
      final fileName = file.name;

      if (bytes == null) {
        _errorMessage = 'Không thể đọc file ảnh';
        notifyListeners();
        return;
      }

      setLoading(true);
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final uploadResult = await uploadFunc(bytes, fileName);

      await uploadResult.fold(
        (failure) async {
          _errorMessage = failure.message;
        },
        (url) async {
          _successMessage = successMsg;
          await getProfile();
        },
      );

      setLoading(false);
      notifyListeners();
    } catch (e) {
      setLoading(false);
      _errorMessage = 'Lỗi upload ảnh: $e';
      notifyListeners();
    }
  }

  // --- Member Management ---

  Future<void> fetchMembers() async {
    _isMemberLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getMembersUseCase();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isMemberLoading = false;
        notifyListeners();
      },
      (members) {
        _members = members;
        _isMemberLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> addMember({
    required String email,
    required String fullName,
    required String role,
    required String password,
  }) async {
    _isAddingMember = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await addMemberUseCase(
      email: email,
      fullName: fullName,
      role: role,
      password: password,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isAddingMember = false;
        notifyListeners();
        return false;
      },
      (_) async {
        _successMessage = 'Thêm thành viên thành công!';
        await fetchMembers();
        _isAddingMember = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> removeMember(int id) async {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await removeMemberUseCase(id);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) async {
        _successMessage = 'Gỡ thành viên thành công!';
        await fetchMembers();
        return true;
      },
    );
  }
}
