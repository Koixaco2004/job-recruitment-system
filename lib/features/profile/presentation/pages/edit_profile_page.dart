import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/candidate_profile_entity.dart';
import '../../domain/entities/work_experience_entity.dart';
import '../../domain/entities/education_entity.dart';
import '../../domain/entities/certificate_entity.dart';
import '../../domain/entities/language_entity.dart';
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
  String? _selectedCity;
  String? _selectedEducation;
  String? _selectedJobType;
  String? _selectedIndustry;
  DateTime? _dateOfBirth;
  String? _avatarUrl; // URL ảnh đại diện (cập nhật khi upload)

  // Dynamic lists
  List<WorkExperienceEntity> _workExperiences = [];
  List<EducationEntity> _educations = [];
  List<CertificateEntity> _certificates = [];
  List<LanguageEntity> _languages = [];

  final genders = ['Nam', 'Nữ', 'Khác'];
  final cities = ['Hà Nội', 'Hồ Chí Minh', 'Đà Nẵng', 'Khác'];
  final educationLevels = ['Cao đẳng', 'Đại học', 'Thạc sĩ', 'Tiến sĩ'];
  final jobTypes = ['fulltime', 'parttime', 'remote', 'freelance'];
  final proficiencyLevels = ['Sơ cấp', 'Trung cấp', 'Cao cấp', 'Bản ngữ'];
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
    _selectedCity = profile.cityName;
    _selectedEducation = profile.educationLevel;
    _selectedJobType = profile.desiredJobType;
    _selectedIndustry = profile.industry;
    _dateOfBirth = profile.dateOfBirth;
    _avatarUrl = profile.avatarUrl;

    _workExperiences = List.from(profile.workExperiences);
    _educations = List.from(profile.educations);
    _certificates = List.from(profile.certificates);
    _languages = List.from(profile.languages);
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
              _buildLanguageSection(),
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
        _buildDatePicker('Ngày sinh'),
        _buildDropdown(
          'Giới tính',
          genders,
          _selectedGender,
          (v) => setState(() => _selectedGender = v),
        ),
        _buildTextField('Địa chỉ', _addressCtrl),
        _buildDropdown(
          'Thành phố',
          cities,
          _selectedCity,
          (v) => setState(() => _selectedCity = v),
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
                onDelete: () => setState(() => _workExperiences.removeAt(i)),
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
                onDelete: () => setState(() => _educations.removeAt(i)),
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
                subtitle: cert.issuingOrganization,
                onEdit: () => _editCertificate(i),
                onDelete: () => setState(() => _certificates.removeAt(i)),
              );
            }).toList(),
    );
  }

  Widget _buildLanguageSection() {
    return _buildSectionCard(
      title: 'Ngoại ngữ',
      icon: Icons.language,
      onAdd: _addLanguage,
      children: _languages.isEmpty
          ? [
              const Text(
                'Chưa có. Nhấn + để thêm.',
                style: TextStyle(color: Colors.grey),
              ),
            ]
          : _languages.asMap().entries.map((entry) {
              final i = entry.key;
              final lang = entry.value;
              return _buildListItem(
                title: lang.name,
                subtitle: lang.proficiency,
                onEdit: () => _editLanguage(i),
                onDelete: () => setState(() => _languages.removeAt(i)),
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

  Widget _buildDatePicker(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _dateOfBirth ?? DateTime(1998),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() => _dateOfBirth = picked);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          child: Text(
            _dateOfBirth != null
                ? DateFormat('dd/MM/yyyy').format(_dateOfBirth!)
                : 'Chọn ngày',
            style: TextStyle(
              color: _dateOfBirth != null ? Colors.black : Colors.grey,
            ),
          ),
        ),
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
              onPressed: () {
                if (companyCtrl.text.isEmpty || positionCtrl.text.isEmpty) {
                  return;
                }
                final newExp = WorkExperienceEntity(
                  id: exp?.id,
                  companyName: companyCtrl.text,
                  position: positionCtrl.text,
                  startDate: startDate,
                  endDate: isCurrentJob ? null : endDate,
                  description: descCtrl.text.isEmpty ? null : descCtrl.text,
                  isCurrentJob: isCurrentJob,
                );
                setState(() {
                  if (isEdit) {
                    _workExperiences[editIndex] = newExp;
                  } else {
                    _workExperiences.add(newExp);
                  }
                });
                Navigator.pop(ctx);
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
              onPressed: () {
                if (institutionCtrl.text.isEmpty || fieldCtrl.text.isEmpty) {
                  return;
                }
                final newEdu = EducationEntity(
                  id: edu?.id,
                  institution: institutionCtrl.text,
                  degree: selectedDegree,
                  fieldOfStudy: fieldCtrl.text,
                  startDate: startDate,
                  endDate: endDate,
                  description: descCtrl.text.isEmpty ? null : descCtrl.text,
                );
                setState(() {
                  if (isEdit) {
                    _educations[editIndex] = newEdu;
                  } else {
                    _educations.add(newEdu);
                  }
                });
                Navigator.pop(ctx);
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
    final orgCtrl = TextEditingController(
      text: cert?.issuingOrganization ?? '',
    );
    DateTime issueDate = cert?.issueDate ?? DateTime.now();
    DateTime? expirationDate = cert?.expirationDate;
    String? certImageUrl = cert?.credentialUrl;
    bool isUploadingCertImage = false;

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
                const SizedBox(height: 8),
                TextField(
                  controller: orgCtrl,
                  decoration: const InputDecoration(labelText: 'Tổ chức cấp *'),
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
                      if (certImageUrl != null && certImageUrl!.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: certImageUrl!,
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
                      ],
                      OutlinedButton.icon(
                          onPressed: isUploadingCertImage
                              ? null
                              : () async {
                                  final provider = context.read<ProfileProvider>();
                                  setDialogState(() => isUploadingCertImage = true);
                                  final url = await provider.pickAndUploadImage();
                                  setDialogState(() {
                                    isUploadingCertImage = false;
                                    if (url != null) certImageUrl = url;
                                  });
                                },
                          icon: isUploadingCertImage
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  certImageUrl != null ? Icons.refresh : Icons.add_photo_alternate,
                                ),
                          label: Text(
                            isUploadingCertImage
                                ? 'Đang upload...'
                                : certImageUrl != null
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
              onPressed: () {
                if (nameCtrl.text.isEmpty || orgCtrl.text.isEmpty) return;
                final newCert = CertificateEntity(
                  id: cert?.id,
                  name: nameCtrl.text,
                  issuingOrganization: orgCtrl.text,
                  issueDate: issueDate,
                  expirationDate: expirationDate,
                  credentialUrl: certImageUrl,
                );
                setState(() {
                  if (isEdit) {
                    _certificates[editIndex] = newCert;
                  } else {
                    _certificates.add(newCert);
                  }
                });
                Navigator.pop(ctx);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _addLanguage() => _showLanguageDialog(null);
  void _editLanguage(int index) => _showLanguageDialog(index);

  void _showLanguageDialog(int? editIndex) {
    final isEdit = editIndex != null;
    final lang = isEdit ? _languages[editIndex] : null;

    final nameCtrl = TextEditingController(text: lang?.name ?? '');
    String selectedProficiency = lang?.proficiency ?? 'Trung cấp';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Sửa ngoại ngữ' : 'Thêm ngoại ngữ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Ngôn ngữ *'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedProficiency,
                decoration: const InputDecoration(labelText: 'Trình độ'),
                items: proficiencyLevels
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setDialogState(() => selectedProficiency = v);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty) return;
                final newLang = LanguageEntity(
                  id: lang?.id,
                  name: nameCtrl.text,
                  proficiency: selectedProficiency,
                );
                setState(() {
                  if (isEdit) {
                    _languages[editIndex] = newLang;
                  } else {
                    _languages.add(newLang);
                  }
                });
                Navigator.pop(ctx);
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
      dateOfBirth: _dateOfBirth,
      gender: _selectedGender,
      address: _addressCtrl.text.isEmpty ? null : _addressCtrl.text,
      cityName: _selectedCity,
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
      languages: _languages,
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
