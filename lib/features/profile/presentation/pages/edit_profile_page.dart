import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/candidate_profile_entity.dart';
import '../../domain/entities/work_experience_entity.dart';
import '../../domain/entities/education_entity.dart';
import '../../domain/entities/certificate_entity.dart';
import '../../domain/entities/project_entity.dart';
import '../../../metadata/domain/entities/province_entity.dart';
import '../providers/profile_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers cho thông tin chung
  late TextEditingController _fullNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _currentJobTitleCtrl;
  late TextEditingController _desiredJobTitleCtrl;
  late TextEditingController _salaryMinCtrl;
  late TextEditingController _salaryMaxCtrl;
  late TextEditingController _skillsCtrl;

  String? _selectedGender;
  int? _selectedProvinceId;
  String? _selectedEducation;
  String? _selectedJobType;
  String? _selectedIndustry;
  String? _avatarUrl; // URL ảnh đại diện (cập nhật khi upload)

  // Dynamic lists
  List<WorkExperienceEntity> _workExperiences = [];
  List<EducationEntity> _educations = [];
  List<CertificateEntity> _certificates = [];
  List<ProjectEntity> _projects = [];

  final genders = ['Nam', 'Nữ', 'Khác'];
  final educationLevels = ['Cao đẳng', 'Đại học', 'Thạc sĩ', 'Tiến sĩ'];
  final jobTypes = ['fulltime', 'parttime', 'remote', 'freelance'];
  final industries = [
    'Công nghệ thông tin',
    'Tài chính - Ngân hàng',
    'Marketing - Truyền thông',
    'Giáo dục - Đào tạo',
    'Y tế - Sức khỏe',
    'Xây dựng - Bất động sản',
    'Sản xuất - Chế tạo',
    'Thương mại - Bán lẻ',
    'Du lịch - Nhà hàng - Khách sạn',
    'Vận tải - Logistics',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile!;

    _fullNameCtrl = TextEditingController(text: profile.fullName);
    _phoneCtrl = TextEditingController(text: profile.phone ?? '');
    _addressCtrl = TextEditingController(text: profile.address ?? '');
    _currentJobTitleCtrl = TextEditingController(
      text: profile.currentJobTitle ?? '',
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
    _skillsCtrl = TextEditingController(text: profile.skills.join(', '));

    _selectedGender = profile.gender;
    _selectedProvinceId = profile.provinceId;
    _selectedEducation = profile.educationLevel;
    _selectedJobType = profile.desiredJobType;
    _selectedIndustry = profile.industry;
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
    _addressCtrl.dispose();
    _currentJobTitleCtrl.dispose();
    _desiredJobTitleCtrl.dispose();
    _salaryMinCtrl.dispose();
    _salaryMaxCtrl.dispose();
    _skillsCtrl.dispose();
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
        _buildTextField('Địa chỉ', _addressCtrl),
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
        _buildDropdown(
          'Trình độ học vấn',
          educationLevels,
          _selectedEducation,
          (v) => setState(() => _selectedEducation = v),
        ),
        _buildTextField('Vị trí hiện tại', _currentJobTitleCtrl),
        _buildTextField('Vị trí mong muốn', _desiredJobTitleCtrl),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'Lương min',
                _salaryMinCtrl,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                'Lương max',
                _salaryMaxCtrl,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        _buildDropdown(
          'Hình thức',
          jobTypes,
          _selectedJobType,
          (v) => setState(() => _selectedJobType = v),
          labels: {
            'fulltime': 'Full-time',
            'parttime': 'Part-time',
            'remote': 'Remote',
            'freelance': 'Freelance',
          },
        ),
        _buildDropdown(
          'Ngành nghề',
          industries,
          _selectedIndustry,
          (v) => setState(() => _selectedIndustry = v),
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

  Widget _buildSkillsSection() {
    return _buildSectionCard(
      title: 'Kỹ năng',
      icon: Icons.code,
      children: [
        TextFormField(
          controller: _skillsCtrl,
          decoration: const InputDecoration(
            labelText: 'Kỹ năng (phân cách bằng dấu phẩy)',
            hintText: 'Flutter, Dart, Firebase...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
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

  // === Helper Widgets ===

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        validator: required
            ? (v) => v == null || v.isEmpty ? 'Trường này bắt buộc' : null
            : null,
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
    String selectedDegree = edu?.degree ?? 'Đại học';
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
                  items: [...educationLevels, 'Online Course']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
                            type: FileType.image,
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

    final profile = context.read<ProfileProvider>().profile!;

    final skills = _skillsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final updatedProfile = CandidateProfileEntity(
      userId: profile.userId,
      email: profile.email,
      phone: _phoneCtrl.text.isEmpty ? null : _phoneCtrl.text,
      fullName: _fullNameCtrl.text,
      avatarUrl: _avatarUrl ?? profile.avatarUrl,
      candidateId: profile.candidateId,
      dateOfBirth: profile.dateOfBirth,
      gender: _selectedGender,
      address: _addressCtrl.text.isEmpty ? null : _addressCtrl.text,
      cityName: profile.cityName, // Retain original if needed, or null
      provinceId: _selectedProvinceId,
      educationLevel: _selectedEducation,
      yearsOfExperience: profile.yearsOfExperience,
      currentJobTitle: _currentJobTitleCtrl.text.isEmpty
          ? null
          : _currentJobTitleCtrl.text,
      desiredJobTitle: _desiredJobTitleCtrl.text.isEmpty
          ? null
          : _desiredJobTitleCtrl.text,
      desiredSalaryMin: int.tryParse(_salaryMinCtrl.text),
      desiredSalaryMax: int.tryParse(_salaryMaxCtrl.text),
      desiredJobType: _selectedJobType,
      skills: skills,
      cvFileUrl: profile.cvFileUrl,
      industry: _selectedIndustry,
      isSearchable: profile.isSearchable,
      workExperiences: _workExperiences,
      educations: _educations,
      certificates: _certificates,
      projects: _projects,
      createdAt: profile.createdAt,
      updatedAt: DateTime.now(),
    );

    final provider = context.read<ProfileProvider>();
    final success = await provider.updateProfile(updatedProfile);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật hồ sơ thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Lỗi cập nhật'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
