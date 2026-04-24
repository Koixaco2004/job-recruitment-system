import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/candidate_profile_entity.dart';
import '../../domain/entities/work_experience_entity.dart';
import '../../domain/entities/education_entity.dart';
import '../../domain/entities/certificate_entity.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/skill_entity.dart';
import '../../../metadata/domain/entities/province_entity.dart';
import '../providers/profile_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  static const Map<String, String> _degreeOptions = {
    'postgraduate': 'Trên đại học',
    'university': 'Đại học',
    'college': 'Cao đẳng',
    'intermediate': 'Trung cấp',
    'high_school': 'Trung học',
    'certificate': 'Chứng chỉ / Bằng nghề',
    'none': 'Không yêu cầu',
  };

  // Controllers cho thông tin chung
  late TextEditingController _fullNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _yearsOfExperienceCtrl;
  late TextEditingController _desiredJobTitleCtrl;
  late TextEditingController _salaryMinCtrl;
  late TextEditingController _salaryMaxCtrl;
  late TextEditingController _linkedinUrlCtrl;
  late TextEditingController _githubUrlCtrl;
  late TextEditingController _portfolioUrlCtrl;

  String? _selectedGender;
  int? _selectedProvinceId;
  String? _selectedJobType;
  int? _selectedJobTypeId;
  String? _avatarUrl; // URL ảnh đại diện (cập nhật khi upload)

  // Dynamic lists
  List<WorkExperienceEntity> _workExperiences = [];
  List<EducationEntity> _educations = [];
  List<CertificateEntity> _certificates = [];
  List<ProjectEntity> _projects = [];

  final genders = ['Nam', 'Nữ', 'Khác'];
  final educationLevels = ['Cao đẳng', 'Đại học', 'Thạc sĩ', 'Tiến sĩ'];

  Timer? _skillDebounce;
  final TextEditingController _skillSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initial fetch for metadata and mappings
    context.read<ProfileProvider>().fetchProfile();
    
    final profile = context.read<ProfileProvider>().profile!;

    _fullNameCtrl = TextEditingController(text: profile.fullName);
    _phoneCtrl = TextEditingController(text: profile.phone ?? '');
    _bioCtrl = TextEditingController(text: profile.bio ?? '');
    _yearsOfExperienceCtrl = TextEditingController(
      text: profile.yearsOfExperience >= 0 ? profile.yearsOfExperience.toString() : '0',
    );
    _desiredJobTitleCtrl = TextEditingController(
      text: profile.desiredJobTitle ?? '',
    );
    _salaryMinCtrl = TextEditingController(
      text: profile.desiredSalaryMin?.toString() ?? '',
    );
    _salaryMaxCtrl = TextEditingController(
      text: profile.desiredSalaryMax?.toString() ?? '',
    );
    _linkedinUrlCtrl = TextEditingController(text: profile.linkedinUrl ?? '');
    _githubUrlCtrl = TextEditingController(text: profile.githubUrl ?? '');
    _portfolioUrlCtrl = TextEditingController(text: profile.portfolioUrl ?? '');

    _selectedGender = profile.gender;
    _selectedProvinceId = profile.provinceId;
    _selectedJobType = profile.desiredJobType;
    _selectedJobTypeId = profile.jobTypeId;
    _avatarUrl = profile.avatarUrl;

    _workExperiences = List.from(profile.workExperiences);
    _educations = List.from(profile.educations);
    _certificates = List.from(profile.certificates);
    _projects = List.from(profile.projects);
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _yearsOfExperienceCtrl.dispose();
    _desiredJobTitleCtrl.dispose();
    _salaryMinCtrl.dispose();
    _salaryMaxCtrl.dispose();
    _linkedinUrlCtrl.dispose();
    _githubUrlCtrl.dispose();
    _portfolioUrlCtrl.dispose();
    _skillSearchCtrl.dispose();
    _skillDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<ProfileProvider>(
            builder: (context, provider, _) {
              return TextButton(
                onPressed: provider.isSaving ? null : _saveProfile,
                child: provider.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Lưu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPersonalInfoSection(),
              const SizedBox(height: 16),
              _buildSkillsSection(),
              const SizedBox(height: 16),
              _buildExperienceSection(),
              const SizedBox(height: 16),
              _buildEducationSection(),
              const SizedBox(height: 16),
              _buildCertificateSection(),
              const SizedBox(height: 16),
              _buildProjectSection(),
              const SizedBox(height: 16),
              _buildJobCategorySection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    VoidCallback? onAdd,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (onAdd != null)
                  IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: onAdd,
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSectionCard(
      title: 'Thông tin chung',
      icon: Icons.person,
      children: [
        // === Avatar Upload ===
        _buildAvatarUpload(),
        const SizedBox(height: 16),
        _buildTextField('Họ và tên *', _fullNameCtrl, required: true),
        _buildTextField(
          'Số điện thoại',
          _phoneCtrl,
          keyboardType: TextInputType.phone,
        ),
        _buildDropdown(
          'Giới tính',
          genders,
          _selectedGender,
          (v) => setState(() => _selectedGender = v),
        ),
        _buildTextField(
          'Giới thiệu bản thân (Bio)',
          _bioCtrl,
          maxLines: 4,
          maxLength: 2000,
        ),
        _buildTextField(
          'Số năm kinh nghiệm',
          _yearsOfExperienceCtrl,
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v != null && v.isNotEmpty) {
              final val = int.tryParse(v);
              if (val == null || val < 0) return 'Kinh nghiệm không được âm';
            }
            return null;
          },
        ),
        Consumer<ProfileProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingProvinces) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: CircularProgressIndicator(),
              );
            }
            return _buildProvinceDropdown(
              'Thành phố/Tỉnh',
              provider.provinces,
              _selectedProvinceId,
              (v) => setState(() => _selectedProvinceId = v),
            );
          },
        ),
        _buildTextField('Vị trí mong muốn', _desiredJobTitleCtrl),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'Lương min',
                _salaryMinCtrl,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final min = int.tryParse(v);
                    final max = int.tryParse(_salaryMaxCtrl.text);
                    if (min != null && max != null && min > max) {
                      return 'Min > Max';
                    }
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                'Lương max',
                _salaryMaxCtrl,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final max = int.tryParse(v);
                    final min = int.tryParse(_salaryMinCtrl.text);
                    if (max != null && min != null && max < min) {
                      return 'Max < Min';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        _buildJobTypeDropdown(),
        const Divider(height: 32),
        const Text(
          'Liên kết mạng xã hội',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'LinkedIn URL',
          _linkedinUrlCtrl,
          keyboardType: TextInputType.url,
          prefixIcon: Icons.link,
          validator: (v) {
            if (v != null && v.isNotEmpty) {
              if (!v.contains('.')) return 'URL không hợp lệ';
            }
            return null;
          },
        ),
        _buildTextField(
          'GitHub URL',
          _githubUrlCtrl,
          keyboardType: TextInputType.url,
          prefixIcon: Icons.code,
          validator: (v) {
            if (v != null && v.isNotEmpty) {
              if (!v.contains('.')) return 'URL không hợp lệ';
            }
            return null;
          },
        ),
        _buildTextField(
          'Portfolio URL',
          _portfolioUrlCtrl,
          keyboardType: TextInputType.url,
          prefixIcon: Icons.language,
          validator: (v) {
            if (v != null && v.isNotEmpty) {
              if (!v.contains('.')) return 'URL không hợp lệ';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Widget upload ảnh đại diện
  Widget _buildAvatarUpload() {
    return Center(
      child: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                        ? CachedNetworkImageProvider(_avatarUrl!)
                        : null,
                    child: _avatarUrl == null || _avatarUrl!.isEmpty
                        ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: provider.isUploadingImage
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () async {
                                final url = await provider.pickAndUploadImage();
                                if (url != null) {
                                  setState(() => _avatarUrl = url);
                                }
                              },
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Nhấn biểu tượng máy ảnh để đổi avatar',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExperienceSection() {
    return _buildSectionCard(
      title: 'Kinh nghiệm làm việc',
      icon: Icons.work_outline,
      onAdd: _addExperience,
      children: _workExperiences.isEmpty
          ? [
              const Text(
                'Chưa có. Nhấn + để thêm.',
                style: TextStyle(color: Colors.grey),
              ),
            ]
          : _workExperiences.asMap().entries.map((entry) {
              final i = entry.key;
              final exp = entry.value;
              return _buildListItem(
                title: exp.position,
                subtitle:
                    '${exp.companyName} • ${DateFormat('MM/yyyy').format(exp.startDate)} - ${exp.endDate != null ? DateFormat('MM/yyyy').format(exp.endDate!) : 'Hiện tại'}',
                onEdit: () => _editExperience(i),
                onDelete: () async {
                  final id = exp.id;
                  if (id != null) {
                    // Has an id => delete from API
                    final ok = await context.read<ProfileProvider>().removeWorkExperience(id);
                    if (ok && mounted) setState(() => _workExperiences.removeAt(i));
                  } else {
                    // Local-only (never saved to API yet)
                    setState(() => _workExperiences.removeAt(i));
                  }
                },
              );
            }).toList(),
    );
  }

  Widget _buildEducationSection() {
    return _buildSectionCard(
      title: 'Học vấn',
      icon: Icons.school,
      onAdd: _addEducation,
      children: _educations.isEmpty
          ? [
              const Text(
                'Chưa có. Nhấn + để thêm.',
                style: TextStyle(color: Colors.grey),
              ),
            ]
          : _educations.asMap().entries.map((entry) {
              final i = entry.key;
              final edu = entry.value;
              return _buildListItem(
                title: '${edu.degree} - ${edu.fieldOfStudy}',
                subtitle: edu.institution,
                onEdit: () => _editEducation(i),
                onDelete: () async {
                  final id = edu.id;
                  if (id != null) {
                    final ok = await context.read<ProfileProvider>().removeEducation(id);
                    if (ok && mounted) setState(() => _educations.removeAt(i));
                  } else {
                    setState(() => _educations.removeAt(i));
                  }
                },
              );
            }).toList(),
    );
  }

  Widget _buildCertificateSection() {
    return _buildSectionCard(
      title: 'Chứng chỉ / Bằng cấp',
      icon: Icons.verified,
      onAdd: _addCertificate,
      children: _certificates.isEmpty
          ? [
              const Text(
                'Chưa có. Nhấn + để thêm.',
                style: TextStyle(color: Colors.grey),
              ),
            ]
          : _certificates.asMap().entries.map((entry) {
              final i = entry.key;
              final cert = entry.value;
              return _buildListItem(
                title: cert.name,
                subtitle: DateFormat('MM/yyyy').format(cert.issueDate),
                onEdit: () => _editCertificate(i),
                onDelete: () async {
                  final id = cert.id;
                  if (id != null) {
                    final ok = await context.read<ProfileProvider>().removeCertificate(id);
                    if (ok && mounted) setState(() => _certificates.removeAt(i));
                  } else {
                    setState(() => _certificates.removeAt(i));
                  }
                },
              );
            }).toList(),
    );
  }

  Widget _buildProjectSection() {
    return _buildSectionCard(
      title: 'Dự án nổi bật',
      icon: Icons.assignment_outlined,
      onAdd: _addProject,
      children: _projects.isEmpty
          ? [
              const Text(
                'Chưa có. Nhấn + để thêm.',
                style: TextStyle(color: Colors.grey),
              ),
            ]
          : _projects.asMap().entries.map((entry) {
              final i = entry.key;
              final project = entry.value;
              return _buildListItem(
                title: project.name,
                subtitle:
                    '${project.startDate != null ? DateFormat('MM/yyyy').format(project.startDate!) : 'Chưa rõ'} - ${project.endDate != null ? DateFormat('MM/yyyy').format(project.endDate!) : 'Hiện tại'}',
                onEdit: () => _editProject(i),
                onDelete: () async {
                  final id = project.id;
                  if (id != null) {
                    final ok = await context.read<ProfileProvider>().removeProject(id);
                    if (ok && mounted) setState(() => _projects.removeAt(i));
                  } else {
                    setState(() => _projects.removeAt(i));
                  }
                },
              );
            }).toList(),
    );
  }

  Widget _buildSkillsSection() {
    return _buildSectionCard(
      title: 'Kỹ năng',
      icon: Icons.bolt,
      children: [
        Consumer<ProfileProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search field
                TextField(
                  controller: _skillSearchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm hoặc nhập kỹ năng mới...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _skillSearchCtrl.text.trim().isNotEmpty
                          ? IconButton(
                              key: const ValueKey('add_skill_btn'),
                              icon: const Icon(Icons.add_circle, color: Colors.blue, size: 28),
                              onPressed: () {
                                final text = _skillSearchCtrl.text.trim();
                                if (text.isNotEmpty) {
                                  provider.addSelectedSkill(text);
                                  _skillSearchCtrl.clear();
                                  provider.searchSkills('');
                                  setState(() {});
                                }
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    if (_skillDebounce?.isActive ?? false) _skillDebounce!.cancel();
                    _skillDebounce = Timer(const Duration(milliseconds: 500), () {
                      provider.searchSkills(value.trim());
                    });
                    setState(() {}); // For suffix icon refresh
                  },
                  onSubmitted: (value) {
                    final text = value.trim();
                    if (text.isNotEmpty) {
                      provider.addSelectedSkill(text);
                      _skillSearchCtrl.clear();
                      provider.searchSkills('');
                      setState(() {});
                    }
                  },
                ),
                
                // Search Results Dropdown-like
                if (provider.isLoadingSkills)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: LinearProgressIndicator(),
                  ),
                
                if (provider.skillSearchResults.isNotEmpty && _skillSearchCtrl.text.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: provider.skillSearchResults.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final skill = provider.skillSearchResults[index];
                        return ListTile(
                          title: Text(skill.canonicalName),
                          onTap: () {
                            provider.addSelectedSkill(skill);
                            _skillSearchCtrl.clear();
                            provider.searchSkills(''); // Clear results
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 12),
                
                // Selected Skills Chips
                if (provider.selectedSkills.isEmpty)
                  Text(
                    'Chưa có kỹ năng nào được chọn',
                    style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 0,
                    children: provider.selectedSkills.map((skill) {
                      String label = '';
                      if (skill is String) {
                        label = skill;
                      } else if (skill is SkillEntity) {
                        label = skill.canonicalName;
                      }
                      
                      return Chip(
                        label: Text(label),
                        onDeleted: () => provider.removeSelectedSkill(skill),
                        backgroundColor: (skill is String) 
                            ? Colors.orange.withOpacity(0.1) 
                            : Theme.of(context).primaryColor.withOpacity(0.1),
                        deleteIconColor: Colors.red[400],
                        labelStyle: TextStyle(
                          color: (skill is String) ? Colors.orange[900] : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),
                
                if (provider.skillError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      provider.skillError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildJobCategorySection() {
    return _buildSectionCard(
      title: 'Ngành nghề quan tâm',
      icon: Icons.category_outlined,
      children: [
        Consumer<ProfileProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingJobCategories) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.allJobCategories.isEmpty) {
              return const Text('Không có dữ liệu ngành nghề');
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dropdown to pick/add a category
                DropdownButtonFormField<int>(
                  key: ValueKey('category_dropdown_${provider.selectedJobCategoryIds.length}'),
                  value: null,
                  hint: const Text('Thêm ngành nghề quan tâm...'),
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: provider.allJobCategories
                      .where((cat) => !provider.selectedJobCategoryIds.contains(cat.id))
                      .map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id != null) {
                      provider.toggleJobCategory(id);
                      // UI will refresh via Consumer/notifyListeners
                    }
                  },
                ),
                
                if (provider.selectedJobCategoryIds.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Ngành nghề đã chọn:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 0,
                    children: provider.allJobCategories
                        .where((cat) => provider.selectedJobCategoryIds.contains(cat.id))
                        .map((cat) {
                      return Chip(
                        label: Text(cat.name),
                        onDeleted: () => provider.toggleJobCategory(cat.id),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.08),
                        deleteIconColor: Colors.red[400],
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      );
                    }).toList(),
                  ),
                ],
                
                if (provider.jobCategoryError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      provider.jobCategoryError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  // === Helper Widgets ===

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
          border: const OutlineInputBorder(),
          counterText: '', // Hide default counter
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        validator: (v) {
          if (required && (v == null || v.isEmpty)) {
            return 'Trường này bắt buộc';
          }
          if (validator != null) {
            return validator(v);
          }
          return null;
        },
      ),
    );
  }

  Widget _buildJobTypeDropdown() {
    final provider = context.watch<ProfileProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        value: provider.jobTypes.any((jt) => jt.id == _selectedJobTypeId)
            ? _selectedJobTypeId
            : null,
        decoration: const InputDecoration(
          labelText: 'Hình thức',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        items: provider.jobTypes.map((jt) {
          return DropdownMenuItem<int>(
            value: jt.id,
            child: Text(jt.name),
          );
        }).toList(),
        onChanged: (v) {
          setState(() {
            _selectedJobTypeId = v;
            // Cập nhật cả name để hiển thị fallback nếu cần
            _selectedJobType = provider.getJobTypeName(v);
          });
        },
        validator: (v) => v == null ? 'Trường này bắt buộc' : null,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    void Function(String?) onChanged, {
    Map<String, String>? labels,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(labels?[item] ?? item),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildProvinceDropdown(
    String label,
    List<ProvinceEntity> items,
    int? value,
    void Function(int?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        value: items.any((p) => p.id == value) ? value : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item.id,
                child: Text(item.name),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildListItem({
    required String title,
    required String subtitle,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: Icon(
                Icons.edit,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: onEdit,
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  // === Dialog Helpers ===

  void _addExperience() => _showExperienceDialog(null);
  void _editExperience(int index) => _showExperienceDialog(index);

  void _showExperienceDialog(int? editIndex) {
    final isEdit = editIndex != null;
    final exp = isEdit ? _workExperiences[editIndex] : null;

    final companyCtrl = TextEditingController(text: exp?.companyName ?? '');
    final positionCtrl = TextEditingController(text: exp?.position ?? '');
    final descCtrl = TextEditingController(text: exp?.description ?? '');
    DateTime startDate = exp?.startDate ?? DateTime.now();
    DateTime? endDate = exp?.endDate;
    bool isCurrentJob = exp?.isCurrentJob ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Sửa kinh nghiệm' : 'Thêm kinh nghiệm'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: companyCtrl,
                  decoration: const InputDecoration(labelText: 'Công ty *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: positionCtrl,
                  decoration: const InputDecoration(labelText: 'Vị trí *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 3,
                  maxLength: 2000,
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: Text(
                    'Bắt đầu: ${DateFormat('MM/yyyy').format(startDate)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setDialogState(() => startDate = d);
                  },
                ),
                CheckboxListTile(
                  title: const Text('Đang làm việc ở đây'),
                  value: isCurrentJob,
                  onChanged: (v) =>
                      setDialogState(() => isCurrentJob = v ?? false),
                ),
                if (!isCurrentJob)
                  ListTile(
                    title: Text(
                      endDate != null
                          ? 'Kết thúc: ${DateFormat('MM/yyyy').format(endDate!)}'
                          : 'Chọn ngày kết thúc',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: startDate,
                        lastDate: DateTime.now(),
                      );
                      if (d != null) setDialogState(() => endDate = d);
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (companyCtrl.text.isEmpty || positionCtrl.text.isEmpty) return;
                final newExp = WorkExperienceEntity(
                  id: exp?.id,
                  companyName: companyCtrl.text,
                  position: positionCtrl.text,
                  startDate: startDate,
                  endDate: isCurrentJob ? null : endDate,
                  description: descCtrl.text.isEmpty ? null : descCtrl.text,
                  isCurrentJob: isCurrentJob,
                );

                final provider = context.read<ProfileProvider>();
                if (isEdit && exp?.id != null) {
                  final ok = await provider.editWorkExperience(exp!.id!, newExp);
                  if (mounted) {
                    if (ok) {
                      Navigator.pop(ctx);
                      setState(() {
                        _workExperiences = List.from(provider.profile!.workExperiences);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.workExpError ?? 'Lỗi cập nhật'), backgroundColor: Colors.red),
                      );
                    }
                  }
                } else {
                  final ok = await provider.addWorkExperience(newExp);
                  if (mounted) {
                    if (ok) {
                      Navigator.pop(ctx);
                      setState(() {
                        _workExperiences = List.from(provider.profile!.workExperiences);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.workExpError ?? 'Lỗi thêm mới'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _addEducation() => _showEducationDialog(null);
  void _editEducation(int index) => _showEducationDialog(index);

  void _showEducationDialog(int? editIndex) {
    final isEdit = editIndex != null;
    final edu = isEdit ? _educations[editIndex] : null;

    final institutionCtrl = TextEditingController(text: edu?.institution ?? '');
    final fieldCtrl = TextEditingController(text: edu?.fieldOfStudy ?? '');
    final descCtrl = TextEditingController(text: edu?.description ?? '');
    String selectedDegree = edu?.degree ?? 'university';
    if (!_degreeOptions.containsKey(selectedDegree)) {
       // Fallback for old data or labels
       if (selectedDegree == 'Đại học') selectedDegree = 'university';
       else if (selectedDegree == 'Cao đẳng') selectedDegree = 'college';
       else if (selectedDegree == 'Thạc sĩ' || selectedDegree == 'Tiến sĩ') selectedDegree = 'postgraduate';
       else selectedDegree = 'university';
    }
    DateTime startDate = edu?.startDate ?? DateTime(2016);
    DateTime? endDate = edu?.endDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Sửa học vấn' : 'Thêm học vấn'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: institutionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Trường/Cơ sở *',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedDegree,
                  decoration: const InputDecoration(labelText: 'Bằng cấp'),
                  items: _degreeOptions.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedDegree = v);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: fieldCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Chuyên ngành *',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 2,
                  maxLength: 2000,
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: Text(
                    'Bắt đầu: ${DateFormat('MM/yyyy').format(startDate)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: startDate,
                      firstDate: DateTime(1990),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setDialogState(() => startDate = d);
                  },
                ),
                ListTile(
                  title: Text(
                    endDate != null
                        ? 'Kết thúc: ${DateFormat('MM/yyyy').format(endDate!)}'
                        : 'Chọn ngày kết thúc',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: startDate,
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 5),
                      ),
                    );
                    if (d != null) setDialogState(() => endDate = d);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (institutionCtrl.text.isEmpty || fieldCtrl.text.isEmpty) return;
                final newEdu = EducationEntity(
                  id: edu?.id,
                  institution: institutionCtrl.text,
                  degree: selectedDegree,
                  fieldOfStudy: fieldCtrl.text,
                  startDate: startDate,
                  endDate: endDate,
                  description: descCtrl.text.isEmpty ? null : descCtrl.text,
                );

                final provider = context.read<ProfileProvider>();
                if (isEdit && edu?.id != null) {
                  final ok = await provider.editEducation(edu!.id!, newEdu);
                  if (mounted) {
                    if (ok) {
                      Navigator.pop(ctx);
                      setState(() {
                        _educations = List.from(provider.profile!.educations);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.eduError ?? 'Lỗi cập nhật'), backgroundColor: Colors.red),
                      );
                    }
                  }
                } else {
                  final ok = await provider.addEducation(newEdu);
                  if (mounted) {
                    if (ok) {
                      Navigator.pop(ctx);
                      setState(() {
                        _educations = List.from(provider.profile!.educations);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.eduError ?? 'Lỗi thêm mới'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _addCertificate() => _showCertificateDialog(null);
  void _editCertificate(int index) => _showCertificateDialog(index);

  void _showCertificateDialog(int? editIndex) {
    final isEdit = editIndex != null;
    final cert = isEdit ? _certificates[editIndex] : null;

    final nameCtrl = TextEditingController(text: cert?.name ?? '');
    DateTime issueDate = cert?.issueDate ?? DateTime.now();
    DateTime? expirationDate = cert?.expirationDate;
    String? certImageUrl = cert?.credentialUrl;
    Uint8List? selectedImageBytes;
    String? selectedFileName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Sửa chứng chỉ' : 'Thêm chứng chỉ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên chứng chỉ *',
                  ),
                ),
                const SizedBox(height: 12),
                // === Ảnh chứng chỉ ===
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      if (selectedImageBytes != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            selectedImageBytes!,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      else if (certImageUrl != null && certImageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: certImageUrl,
                            height: 120,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const SizedBox(
                              height: 120,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (_, __, ___) => const SizedBox(
                              height: 120,
                              child: Center(child: Icon(Icons.broken_image, size: 40)),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'bmp'],
                            withData: true,
                          );
                          if (result != null && result.files.single.bytes != null) {
                            setDialogState(() {
                              selectedImageBytes = result.files.single.bytes;
                              selectedFileName = result.files.single.name;
                            });
                          }
                        },
                        icon: const Icon(Icons.add_photo_alternate),
                        label: Text(
                          selectedImageBytes != null || certImageUrl != null
                              ? 'Đổi ảnh chứng chỉ'
                              : 'Tải ảnh chứng chỉ lên',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: Text(
                    'Ngày cấp: ${DateFormat('MM/yyyy').format(issueDate)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: issueDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setDialogState(() => issueDate = d);
                  },
                ),
                ListTile(
                  title: Text(
                    expirationDate != null
                        ? 'Hết hạn: ${DateFormat('MM/yyyy').format(expirationDate!)}'
                        : 'Không có hạn sử dụng',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate:
                          expirationDate ??
                          DateTime.now().add(const Duration(days: 365)),
                      firstDate: issueDate,
                      lastDate: DateTime(2040),
                    );
                    if (d != null) setDialogState(() => expirationDate = d);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;

                final provider = context.read<ProfileProvider>();
                bool ok = false;
                if (isEdit && cert?.id != null) {
                  ok = await provider.editCertificate(
                    id: cert!.id!,
                    name: nameCtrl.text,
                    imageBytes: selectedImageBytes,
                    fileName: selectedFileName,
                  );
                } else {
                  ok = await provider.addCertificate(
                    name: nameCtrl.text,
                    imageBytes: selectedImageBytes,
                    fileName: selectedFileName,
                  );
                }

                if (mounted) {
                  if (ok) {
                    Navigator.pop(ctx);
                    setState(() {
                      _certificates = List.from(provider.profile!.certificates);
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.certError ?? 'Lỗi khi lưu'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }


  void _addProject() => _showProjectDialog(null);
  void _editProject(int index) => _showProjectDialog(index);

  void _showProjectDialog(int? editIndex) {
    final isEdit = editIndex != null;
    final project = isEdit ? _projects[editIndex] : null;

    final nameCtrl = TextEditingController(text: project?.name ?? '');
    final descCtrl = TextEditingController(text: project?.description ?? '');
    DateTime startDate = project?.startDate ?? DateTime.now();
    DateTime? endDate = project?.endDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Sửa dự án' : 'Thêm dự án'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên dự án *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 3,
                  maxLength: 2000,
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: Text(
                    'Bắt đầu: ${DateFormat('MM/yyyy').format(startDate)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setDialogState(() => startDate = d);
                  },
                ),
                CheckboxListTile(
                  title: const Text('Đang thực hiện'),
                  value: endDate == null,
                  onChanged: (v) {
                    setDialogState(() {
                      if (v == true) {
                        endDate = null;
                      } else {
                        endDate = DateTime.now();
                      }
                    });
                  },
                ),
                if (endDate != null)
                  ListTile(
                    title: Text(
                      'Kết thúc: ${DateFormat('MM/yyyy').format(endDate!)}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: startDate,
                        lastDate: DateTime.now(),
                      );
                      if (d != null) setDialogState(() => endDate = d);
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                final newProject = ProjectEntity(
                  id: project?.id,
                  name: nameCtrl.text,
                  startDate: startDate,
                  endDate: endDate,
                  description: descCtrl.text.isEmpty ? null : descCtrl.text,
                );

                final provider = context.read<ProfileProvider>();
                if (isEdit && project?.id != null) {
                  final ok = await provider.editProject(project!.id!, newProject);
                  if (mounted) {
                    if (ok) {
                      Navigator.pop(ctx);
                      setState(() {
                        _projects = List.from(provider.profile!.projects);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.projectError ?? 'Lỗi cập nhật'), backgroundColor: Colors.red),
                      );
                    }
                  }
                } else if (!isEdit) {
                  final ok = await provider.addProject(newProject);
                  if (mounted) {
                    if (ok) {
                      Navigator.pop(ctx);
                      setState(() {
                        _projects = List.from(provider.profile!.projects);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.projectError ?? 'Lỗi khi thêm'), backgroundColor: Colors.red),
                      );
                    }
                  }
                } else {
                  // Local edit for something without id (rare if always synced)
                  setState(() {
                    _projects[editIndex] = newProject;
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  // === Save ===

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Helper to format URL
    String? formatUrl(String value) {
      if (value.isEmpty) return null;
      var url = value.trim();
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      return url;
    }

    final provider = context.read<ProfileProvider>();
    final profile = provider.profile!;

    final skills = provider.selectedSkills.map((s) {
      if (s is String) return s;
      if (s is SkillEntity) return s.canonicalName;
      return '';
    }).where((s) => s.isNotEmpty).toList();

    final updatedProfile = CandidateProfileEntity(
      userId: profile.userId,
      email: profile.email,
      phone: _phoneCtrl.text.isEmpty ? null : _phoneCtrl.text,
      fullName: _fullNameCtrl.text,
      avatarUrl: _avatarUrl ?? profile.avatarUrl,
      candidateId: profile.candidateId,
      dateOfBirth: profile.dateOfBirth,
      gender: _selectedGender,
      bio: _bioCtrl.text.isEmpty ? null : _bioCtrl.text,
      cityName: profile.cityName, // Retain original if needed, or null
      provinceId: _selectedProvinceId,
      educationLevel: profile.educationLevel, // Maintain original state
      yearsOfExperience: int.tryParse(_yearsOfExperienceCtrl.text) ?? 0,
      currentJobTitle: profile.currentJobTitle, // Maintain original state
      desiredJobTitle: _desiredJobTitleCtrl.text.isEmpty
          ? null
          : _desiredJobTitleCtrl.text,
      desiredSalaryMin: int.tryParse(_salaryMinCtrl.text),
      desiredSalaryMax: int.tryParse(_salaryMaxCtrl.text),
      desiredJobType: _selectedJobType,
      jobTypeId: _selectedJobTypeId,
      skills: skills,
      cvFileUrl: profile.cvFileUrl,
      isSearchable: profile.isSearchable,
      linkedinUrl: formatUrl(_linkedinUrlCtrl.text),
      githubUrl: formatUrl(_githubUrlCtrl.text),
      portfolioUrl: formatUrl(_portfolioUrlCtrl.text),
      workExperiences: _workExperiences,
      educations: _educations,
      certificates: _certificates,
      projects: _projects,
      createdAt: profile.createdAt,
      updatedAt: DateTime.now(),
    );
    
    // Save Profile and Job Categories
    final results = await Future.wait([
      provider.updateProfile(updatedProfile),
      provider.saveJobCategories(),
      provider.saveSkills(),
    ]);

    final profileSuccess = results[0];
    final categorySuccess = results[1];
    final skillSuccess = results[2];

    if (mounted) {
      if (profileSuccess && categorySuccess && skillSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật hồ sơ thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        String error = '';
        if (!profileSuccess) error += provider.errorMessage ?? 'Lỗi cập nhật hồ sơ. ';
        if (!categorySuccess) error += provider.jobCategoryError ?? 'Lỗi cập nhật ngành nghề. ';
        if (!skillSuccess) error += provider.skillError ?? 'Lỗi cập nhật kỹ năng.';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.trim()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
