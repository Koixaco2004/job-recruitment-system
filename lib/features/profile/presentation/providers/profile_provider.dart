import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/candidate_profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ProfileRepository profileRepository;

  ProfileProvider({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.profileRepository,
  });

  // State
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingCV = false;
  CandidateProfileEntity? _profile;
  String? _errorMessage;
  String? _successMessage;
  String? _uploadError; // Separate error for CV upload
  String? _uploadedCvUrl;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isUploadingCV => _isUploadingCV;
  CandidateProfileEntity? get profile => _profile;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get uploadError => _uploadError;
  String? get uploadedCvUrl => _uploadedCvUrl;

  /// Fetch profile
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getProfileUseCase();
    result.fold(
      (failure) {
        _isLoading = false;
        _errorMessage = failure.message;
      },
      (profile) {
        _isLoading = false;
        _profile = profile;
      },
    );
    notifyListeners();
  }

  /// Update profile
  Future<bool> updateProfile(CandidateProfileEntity updatedProfile) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final result = await updateProfileUseCase(updatedProfile);
    bool success = false;
    result.fold(
      (failure) {
        _isSaving = false;
        _errorMessage = failure.message;
      },
      (profile) {
        _isSaving = false;
        _profile = profile;
        _successMessage = 'Cập nhật hồ sơ thành công!';
        success = true;
      },
    );
    notifyListeners();
    return success;
  }

  /// Pick and upload CV (hỗ trợ Web + Mobile/Desktop)
  Future<void> pickAndUploadCV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // Đảm bảo lấy bytes cho Web
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final bytes = file.bytes;
      final fileName = file.name;

      if (bytes == null) {
        _uploadError = 'Không thể đọc file. Vui lòng thử lại.';
        notifyListeners();
        return;
      }

      _isUploadingCV = true;
      _uploadError = null;
      notifyListeners();

      final uploadResult = await profileRepository.uploadCV(bytes, fileName);
      uploadResult.fold(
        (failure) {
          _isUploadingCV = false;
          _uploadError =
              failure.message; // Dùng uploadError, KHÔNG ghi đè errorMessage
        },
        (url) {
          _isUploadingCV = false;
          _uploadedCvUrl = url;
          _successMessage = 'Upload CV thành công!';
          // Update profile with new CV URL
          if (_profile != null) {
            _profile = CandidateProfileEntity(
              userId: _profile!.userId,
              email: _profile!.email,
              phone: _profile!.phone,
              fullName: _profile!.fullName,
              avatarUrl: _profile!.avatarUrl,
              candidateId: _profile!.candidateId,
              dateOfBirth: _profile!.dateOfBirth,
              gender: _profile!.gender,
              address: _profile!.address,
              cityName: _profile!.cityName,
              educationLevel: _profile!.educationLevel,
              yearsOfExperience: _profile!.yearsOfExperience,
              currentJobTitle: _profile!.currentJobTitle,
              desiredJobTitle: _profile!.desiredJobTitle,
              desiredSalaryMin: _profile!.desiredSalaryMin,
              desiredSalaryMax: _profile!.desiredSalaryMax,
              desiredJobType: _profile!.desiredJobType,
              skills: _profile!.skills,
              cvFileUrl: url,
              workExperiences: _profile!.workExperiences,
              educations: _profile!.educations,
              certificates: _profile!.certificates,
              languages: _profile!.languages,
              createdAt: _profile!.createdAt,
              updatedAt: DateTime.now(),
            );
          }
        },
      );
      notifyListeners();
    } catch (e) {
      _isUploadingCV = false;
      _uploadError = 'Lỗi chọn file: $e';
      notifyListeners();
    }
  }

  // Upload image state
  bool _isUploadingImage = false;
  bool get isUploadingImage => _isUploadingImage;

  /// Pick ảnh từ gallery và upload lên Cloudinary (dùng chung cho avatar, chứng chỉ, v.v.)
  /// Trả về URL ảnh đã upload, hoặc null nếu thất bại
  Future<String?> pickAndUploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.single;
      final bytes = file.bytes;
      final fileName = file.name;

      if (bytes == null) {
        _uploadError = 'Không thể đọc ảnh. Vui lòng thử lại.';
        notifyListeners();
        return null;
      }

      _isUploadingImage = true;
      _uploadError = null;
      notifyListeners();

      final uploadResult = await profileRepository.uploadCV(bytes, fileName);
      String? uploadedUrl;

      uploadResult.fold(
        (failure) {
          _uploadError = failure.message;
        },
        (url) {
          uploadedUrl = url;
          _successMessage = 'Upload ảnh thành công!';
        },
      );

      _isUploadingImage = false;
      notifyListeners();
      return uploadedUrl;
    } catch (e) {
      _isUploadingImage = false;
      _uploadError = 'Lỗi chọn ảnh: $e';
      notifyListeners();
      return null;
    }
  }

  /// Bật/Tắt trạng thái tìm việc
  Future<void> toggleSearchable() async {
    if (_profile == null) return;

    final updatedProfile = CandidateProfileEntity(
      userId: _profile!.userId,
      email: _profile!.email,
      phone: _profile!.phone,
      fullName: _profile!.fullName,
      avatarUrl: _profile!.avatarUrl,
      candidateId: _profile!.candidateId,
      dateOfBirth: _profile!.dateOfBirth,
      gender: _profile!.gender,
      address: _profile!.address,
      cityName: _profile!.cityName,
      educationLevel: _profile!.educationLevel,
      yearsOfExperience: _profile!.yearsOfExperience,
      currentJobTitle: _profile!.currentJobTitle,
      desiredJobTitle: _profile!.desiredJobTitle,
      desiredSalaryMin: _profile!.desiredSalaryMin,
      desiredSalaryMax: _profile!.desiredSalaryMax,
      desiredJobType: _profile!.desiredJobType,
      skills: _profile!.skills,
      cvFileUrl: _profile!.cvFileUrl,
      industry: _profile!.industry,
      isSearchable: !_profile!.isSearchable, // Toggle
      workExperiences: _profile!.workExperiences,
      educations: _profile!.educations,
      certificates: _profile!.certificates,
      languages: _profile!.languages,
      createdAt: _profile!.createdAt,
      updatedAt: DateTime.now(),
    );

    await updateProfile(updatedProfile);
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _uploadError = null;
    notifyListeners();
  }
}
