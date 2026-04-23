import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/domain/entities/skill_entity.dart';
import '../../domain/entities/job_post_entity.dart';
import '../providers/job_provider.dart';
import '../../../employer/presentation/providers/employer_provider.dart';

class EmployerJobEditPage extends StatefulWidget {
  final int? jobId;
  final JobPostEntity? job;

  const EmployerJobEditPage({super.key, this.jobId, this.job});

  @override
  State<EmployerJobEditPage> createState() => _EmployerJobEditPageState();
}

class _EmployerJobEditPageState extends State<EmployerJobEditPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _benefitsController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  final _slotsController = TextEditingController();
  final _expController = TextEditingController(text: '0');
  final _skillSearchController = TextEditingController();
  
  final List<dynamic> _selectedJobSkills = [];

  int? _selectedProvinceId;
  int? _selectedCategoryId;
  int? _selectedJobTypeId;
  DateTime? _selectedDeadline;

  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    if (widget.jobId == null) {
      _slotsController.text = '1';
      _expController.text = '0';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _loadMetadata();
      if (widget.job != null || widget.jobId != null) {
        _loadJobData();
      }
      _isInit = true;
    }
  }

  void _loadMetadata() {
    final profileProvider = context.read<ProfileProvider>();
    profileProvider.fetchProvincesIfEmpty();
    profileProvider.fetchJobTypesIfEmpty();
    profileProvider.fetchJobCategoriesMetadata();
  }

  void _loadJobData() {
    try {
      final JobPostEntity job;
      if (widget.job != null) {
        job = widget.job!;
      } else {
        final jobProvider = context.read<JobProvider>();
        job = jobProvider.employerJobs.firstWhere((j) => j.jobPostId == widget.jobId);
      }
      
      _titleController.text = job.title;
      _descriptionController.text = job.description;
      _requirementsController.text = job.requirements;
      _benefitsController.text = job.benefits;
      _salaryMinController.text = job.salaryMin?.toString() ?? '';
      _salaryMaxController.text = job.salaryMax?.toString() ?? '';
      _slotsController.text = (job.numberOfPositions > 0) ? job.numberOfPositions.toString() : '1';
      _expController.text = (job.experienceRequired >= 0) ? job.experienceRequired.toString() : '0';
      _selectedDeadline = job.deadline;
      
      _selectedProvinceId = (job.provinceId == 0) ? null : job.provinceId;
      _selectedCategoryId = (job.categoryId == 0) ? null : job.categoryId;
      _selectedJobTypeId = (job.jobTypeId == 0) ? null : job.jobTypeId;
      
      if (job.skills != null) {
        _selectedJobSkills.clear();
        _selectedJobSkills.addAll(job.skills!);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _benefitsController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _expController.dispose();
    _skillSearchController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  Map<String, dynamic> _getFormData() {
    return {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'requirements': _requirementsController.text,
      'benefits': _benefitsController.text,
      'salaryMin': int.tryParse(_salaryMinController.text) ?? 0,
      'salaryMax': int.tryParse(_salaryMaxController.text) ?? 0,
      'currency': 'VND',
      'yearsOfExperience': int.tryParse(_expController.text) ?? 0,
      'provinceId': _selectedProvinceId,
      'categoryId': _selectedCategoryId,
      'jobTypeId': _selectedJobTypeId,
      'slots': int.tryParse(_slotsController.text) ?? 1,
      'deadline': _selectedDeadline?.toUtc().toIso8601String(),
      'skills': _selectedJobSkills.map((s) {
        if (s is SkillEntity) return {'skillId': s.id};
        if (s is String) return {'tagText': s};
        if (s is Map<String, dynamic>) {
          if (s.containsKey('skill_metadata_id')) return {'skillId': s['skill_metadata_id']};
          if (s.containsKey('skillId')) return {'skillId': s['skillId']};
          if (s.containsKey('tagText')) return {'tagText': s['tagText']};
        }
        return null;
      }).where((s) => s != null).toList(),
    };
  }

  Future<void> _handleSave({bool publish = false}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hạn chót nộp hồ sơ')),
      );
      return;
    }

    final provider = context.read<JobProvider>();
    final data = _getFormData();
    
    // Đảm bảo có status đúng theo quy trình phân tách
    data['status'] = (widget.jobId == null) ? 'draft' : 'published';

    bool success = false;
    if (widget.jobId == null) {
      // Chỉ tạo nháp (POST)
      final newJob = await provider.createJob(data);
      success = (newJob != null);
    } else {
      // Chỉ đăng tin/cập nhật (PUT)
      success = await provider.updateJob(widget.jobId!, data);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(publish ? 'Đã đăng tin thành công!' : 'Đã lưu bản nháp thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Trả về true để reload danh sách
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.saveJobError ?? 'Có lỗi xảy ra khi lưu tin'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final employerProvider = context.watch<EmployerProvider>();
    final bool isAdmin = employerProvider.employer?.isAdminCompany ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jobId == null ? 'Đăng tin mới' : (isAdmin ? 'Chỉnh sửa tin' : 'Chi tiết tin')),
        actions: [
          if (widget.jobId == null && isAdmin) // Chỉ hiện Lưu nháp khi tạo tin mới và là admin
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: TextButton(
                onPressed: jobProvider.isSavingJob ? null : () => _handleSave(publish: false),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.amber[100],
                  foregroundColor: Colors.amber[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('LƯU NHÁP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
        ],
      ),
      body: jobProvider.isSavingJob 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Thông tin chung'),
                  _buildTextField(_titleController, 'Tiêu đề công việc', Icons.work, required: true, enabled: isAdmin),
                  const SizedBox(height: 16),
                  
                  _buildDropdown<int>(
                    label: 'Lĩnh vực',
                    value: _selectedCategoryId,
                    items: profileProvider.allJobCategories.map((c) => 
                      DropdownMenuItem(
                        value: c.id, 
                        child: Text(c.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))
                      )).toList(),
                    onChanged: isAdmin ? (val) => setState(() => _selectedCategoryId = val) : null,
                    icon: Icons.category,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDropdown<int>(
                    label: 'Hình thức',
                    value: _selectedJobTypeId,
                    items: profileProvider.jobTypes.map((t) => 
                      DropdownMenuItem(
                        value: t.id, 
                        child: Text(t.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))
                      )).toList(),
                    onChanged: isAdmin ? (val) => setState(() => _selectedJobTypeId = val) : null,
                    icon: Icons.access_time,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDropdown<int>(
                    label: 'Tỉnh/Thành phố',
                    value: _selectedProvinceId,
                    items: profileProvider.provinces.map((p) => 
                      DropdownMenuItem(
                        value: p.id, 
                        child: Text(p.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))
                      )).toList(),
                    onChanged: isAdmin ? (val) => setState(() => _selectedProvinceId = val) : null,
                    icon: Icons.location_city,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSkillSelector(profileProvider, isAdmin),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    _slotsController, 
                    'Số lượng tuyển', 
                    Icons.people, 
                    isNumber: true, 
                    enabled: isAdmin,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Vui lòng nhập số lượng';
                      final val = int.tryParse(v);
                      if (val == null || val <= 0) return 'Số lượng phải > 0';
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Yêu cầu & Lương'),
                  _buildTextField(
                    _salaryMinController, 
                    'Lương tối thiểu (VND)', 
                    Icons.money, 
                    isNumber: true, 
                    enabled: isAdmin,
                    validator: (v) {
                      if (v != null && v.isNotEmpty) {
                        final min = int.tryParse(v);
                        final max = int.tryParse(_salaryMaxController.text);
                        if (min != null && max != null && min > max) {
                          return 'Min > Max';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _salaryMaxController, 
                    'Lương tối đa (VND)', 
                    Icons.money, 
                    isNumber: true, 
                    enabled: isAdmin,
                    validator: (v) {
                      if (v != null && v.isNotEmpty) {
                        final max = int.tryParse(v);
                        final min = int.tryParse(_salaryMinController.text);
                        if (max != null && min != null && max < min) {
                          return 'Max < Min';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _expController, 
                    'Năm kinh nghiệm yêu cầu', 
                    Icons.history, 
                    isNumber: true, 
                    enabled: isAdmin,
                    validator: (v) {
                      if (v != null && v.isNotEmpty) {
                        final val = int.tryParse(v);
                        if (val == null || val < 0) return 'Kinh nghiệm không được âm';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Chi tiết nội dung'),
                  _buildTextField(_descriptionController, 'Mô tả công việc', Icons.description, maxLines: 5, required: true, maxLength: 10000, enabled: isAdmin),
                  const SizedBox(height: 16),
                  _buildTextField(_requirementsController, 'Yêu cầu ứng viên', Icons.list, maxLines: 5, maxLength: 10000, enabled: isAdmin),
                  const SizedBox(height: 16),
                  _buildTextField(_benefitsController, 'Quyền lợi', Icons.card_giftcard, maxLines: 5, maxLength: 10000, enabled: isAdmin),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Thời hạn'),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today, color: Colors.blue),
                    title: const Text('Hạn chót nộp hồ sơ'),
                    subtitle: Text(_selectedDeadline == null 
                        ? 'Chưa chọn ngày' 
                        : DateFormat('dd/MM/yyyy').format(_selectedDeadline!)),
                    trailing: isAdmin ? const Icon(Icons.chevron_right) : null,
                    onTap: isAdmin ? _selectDeadline : null,
                  ),
                  
                  const SizedBox(height: 40),
                  if (widget.jobId != null && isAdmin) // Chỉ hiện Đăng tin khi đang sửa và là admin
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: jobProvider.isSavingJob ? null : () => _handleSave(publish: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('ĐĂNG TIN NGAY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.blue[900],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSkillSelector(ProfileProvider provider, bool isAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kỹ năng yêu cầu', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        const SizedBox(height: 8),
        _buildSkillChips(isAdmin),
        if (isAdmin)
        TextField(
          controller: _skillSearchController,
          decoration: InputDecoration(
            hintText: 'Tìm kỹ năng hoặc nhập tag mới...',
            prefixIcon: const Icon(Icons.search, size: 20),
            hintStyle: const TextStyle(fontSize: 13),
            suffixIcon: _skillSearchController.text.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    final text = _skillSearchController.text.trim();
                    if (text.isNotEmpty) {
                      setState(() {
                        if (!_selectedJobSkills.any((s) => s.toString().toLowerCase() == text.toLowerCase())) {
                          _selectedJobSkills.add(text);
                        }
                        _skillSearchController.clear();
                      });
                    }
                  },
                )
              : null,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          style: const TextStyle(fontSize: 13),
          onChanged: (val) => provider.searchSkills(val),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              setState(() {
                if (!_selectedJobSkills.any((s) => s.toString().toLowerCase() == val.trim().toLowerCase())) {
                  _selectedJobSkills.add(val.trim());
                }
                _skillSearchController.clear();
              });
            }
          },
        ),
        if (provider.isLoadingSkills)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        if (provider.skillSearchResults.isNotEmpty && _skillSearchController.text.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.skillSearchResults.length,
              itemBuilder: (context, index) {
                final skill = provider.skillSearchResults[index];
                return ListTile(
                  title: Text(skill.canonicalName, style: const TextStyle(fontSize: 13)),
                  dense: true,
                  onTap: () {
                    setState(() {
                      if (!_selectedJobSkills.any((s) => s is SkillEntity && s.id == skill.id)) {
                        _selectedJobSkills.add(skill);
                      }
                      _skillSearchController.clear();
                      provider.searchSkills('');
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSkillChips(bool isAdmin) {
    if (_selectedJobSkills.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _selectedJobSkills.map((skill) {
          String name = '';
          if (skill is SkillEntity) name = skill.canonicalName;
          else if (skill is String) name = skill;
          else if (skill is Map<String, dynamic>) {
            name = skill['tagText'] ?? (skill['skillMetadata']?['canonicalName'] ?? 'Skill');
          }
          
          return Chip(
            label: Text(name, style: const TextStyle(fontSize: 12)),
            deleteIcon: isAdmin ? const Icon(Icons.close, size: 14) : null,
            onDeleted: isAdmin ? () => setState(() => _selectedJobSkills.remove(skill)) : null,
            backgroundColor: Colors.blue[50],
            side: BorderSide(color: Colors.blue[100]!),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isNumber = false, int maxLines = 1, int? maxLength, bool required = false, bool enabled = true, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
        counterText: '', // Hide default counter
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return 'Vui lòng nhập $label';
        }
        if (validator != null) {
          return validator(value);
        }
        return null;
      },
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    required IconData icon,
  }) {
    // Safety check: ensure value exists in items to avoid Flutter assertion error
    final bool valueExists = items.any((item) => item.value == value);
    final T? safeValue = valueExists ? value : null;

    return DropdownButtonFormField<T>(
      value: safeValue,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (val) => val == null ? 'Vui lòng chọn $label' : null,
    );
  }
}
