import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/candidate_profile_entity.dart';
import '../../domain/entities/work_experience_entity.dart';
import '../../domain/entities/education_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../injection_container.dart' as di;
import '../../../metadata/domain/usecases/get_provinces_usecase.dart';
import '../../../metadata/domain/entities/province_entity.dart';

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

  List<ProvinceEntity> _provinces = [];
  bool _isLoadingProvinces = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isUploadingCV => _isUploadingCV;
  CandidateProfileEntity? get profile => _profile;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get uploadError => _uploadError;
  String? get uploadedCvUrl => _uploadedCvUrl;
  List<ProvinceEntity> get provinces => _provinces;
  bool get isLoadingProvinces => _isLoadingProvinces;

  Future<void> fetchProvincesIfEmpty() async {
    if (_provinces.isNotEmpty) return;
    _isLoadingProvinces = true;
    notifyListeners();

    try {
      final getProvincesUseCase = di.sl<GetProvincesUseCase>();
      final result = await getProvincesUseCase();
      result.fold(
        (failure) {
          _isLoadingProvinces = false;
        },
        (provinces) {
          _provinces = provinces;
          _isLoadingProvinces = false;
        },
      );
    } catch (_) {
      _isLoadingProvinces = false;
    }
    notifyListeners();
  }

  String? getProvinceName(int? id) {
    if (id == null) return null;
    try {
      return _provinces.firstWhere((p) => p.id == id).name;
    } catch (_) {
      return null;
    }
  }

  /// Fetch profile
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await fetchProvincesIfEmpty();

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
        (url) async {
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
              provinceId: _profile!.provinceId,
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
            // Gửi cập nhật này lên Backend
            await updateProfile(_profile!);
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
      provinceId: _profile!.provinceId,
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

  // ─── Work Experience CRUD ──────────────────────────────────────────────

  bool _isWorkExpLoading = false;
  String? _workExpError;
  bool get isWorkExpLoading => _isWorkExpLoading;
  String? get workExpError => _workExpError;

  Future<bool> addWorkExperience(WorkExperienceEntity exp) async {
    _isWorkExpLoading = true;
    _workExpError = null;
    notifyListeners();

    final result = await profileRepository.createWorkExperience(exp);
    return result.fold(
      (failure) {
        _workExpError = failure.message;
        _isWorkExpLoading = false;
        notifyListeners();
        return false;
      },
      (created) {
        // Add to local profile state
        if (_profile != null) {
          final updated = List<WorkExperienceEntity>.from(_profile!.workExperiences)
            ..add(created);
          _profile = _rebuildProfileWithExperiences(updated);
        }
        _isWorkExpLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> editWorkExperience(int id, WorkExperienceEntity exp) async {
    _isWorkExpLoading = true;
    _workExpError = null;
    notifyListeners();

    final result = await profileRepository.updateWorkExperience(id, exp);
    return result.fold(
      (failure) {
        _workExpError = failure.message;
        _isWorkExpLoading = false;
        notifyListeners();
        return false;
      },
      (updated) {
        if (_profile != null) {
          final list = _profile!.workExperiences.map((e) => e.id == id ? updated : e).toList();
          _profile = _rebuildProfileWithExperiences(list);
        }
        _isWorkExpLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> removeWorkExperience(int id) async {
    _isWorkExpLoading = true;
    _workExpError = null;
    notifyListeners();

    final result = await profileRepository.deleteWorkExperience(id);
    return result.fold(
      (failure) {
        _workExpError = failure.message;
        _isWorkExpLoading = false;
        notifyListeners();
        return false;
      },
      (_) {
        if (_profile != null) {
          final list = _profile!.workExperiences.where((e) => e.id != id).toList();
          _profile = _rebuildProfileWithExperiences(list);
        }
        _isWorkExpLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  CandidateProfileEntity _rebuildProfileWithExperiences(List<WorkExperienceEntity> exps) {
    return CandidateProfileEntity(
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
      provinceId: _profile!.provinceId,
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
      isSearchable: _profile!.isSearchable,
      workExperiences: exps,
      educations: _profile!.educations,
      certificates: _profile!.certificates,
      languages: _profile!.languages,
      createdAt: _profile!.createdAt,
      updatedAt: _profile!.updatedAt,
    );
  }

  // ─── Education CRUD ────────────────────────────────────────────────────

  bool _isEduLoading = false;
  String? _eduError;
  bool get isEduLoading => _isEduLoading;
  String? get eduError => _eduError;

  Future<bool> addEducation(EducationEntity edu) async {
    _isEduLoading = true;
    _eduError = null;
    notifyListeners();
    final result = await profileRepository.createEducation(edu);
    return result.fold(
      (failure) {
        _eduError = failure.message;
        _isEduLoading = false;
        notifyListeners();
        return false;
      },
      (created) {
        if (_profile != null) {
          final updated = List<EducationEntity>.from(_profile!.educations)..add(created);
          _profile = _rebuildProfileWithEducations(updated);
        }
        _isEduLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> editEducation(int id, EducationEntity edu) async {
    _isEduLoading = true;
    _eduError = null;
    notifyListeners();
    final result = await profileRepository.updateEducation(id, edu);
    return result.fold(
      (failure) {
        _eduError = failure.message;
        _isEduLoading = false;
        notifyListeners();
        return false;
      },
      (updated) {
        if (_profile != null) {
          final list = _profile!.educations.map((e) => e.id == id ? updated : e).toList();
          _profile = _rebuildProfileWithEducations(list);
        }
        _isEduLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> removeEducation(int id) async {
    _isEduLoading = true;
    _eduError = null;
    notifyListeners();
    final result = await profileRepository.deleteEducation(id);
    return result.fold(
      (failure) {
        _eduError = failure.message;
        _isEduLoading = false;
        notifyListeners();
        return false;
      },
      (_) {
        if (_profile != null) {
          final list = _profile!.educations.where((e) => e.id != id).toList();
          _profile = _rebuildProfileWithEducations(list);
        }
        _isEduLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  CandidateProfileEntity _rebuildProfileWithEducations(List<EducationEntity> edus) {
    return CandidateProfileEntity(
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
      provinceId: _profile!.provinceId,
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
      isSearchable: _profile!.isSearchable,
      workExperiences: _profile!.workExperiences,
      educations: edus,
      certificates: _profile!.certificates,
      languages: _profile!.languages,
      createdAt: _profile!.createdAt,
      updatedAt: _profile!.updatedAt,
    );
  }
}
