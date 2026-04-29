import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/domain/entities/skill_entity.dart';
import '../../domain/entities/job_post_entity.dart';
import '../providers/job_provider.dart';
import '../../../employer/presentation/providers/employer_provider.dart';
import '../../../monetization/presentation/providers/monetization_provider.dart';
import '../../../monetization/presentation/pages/pricing_page.dart';

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
  int? _selectedLevelId;
  String? _selectedRequiredDegree;
  DateTime? _selectedDeadline;
  bool _hideSalary = false;
  bool _requireCv = false;
  String? _currentStatus;

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
    
    final jobProvider = context.read<JobProvider>();
    jobProvider.fetchJobLevelsIfEmpty();

    final monetizationProvider = context.read<MonetizationProvider>();
    monetizationProvider.fetchSubscriptionStatus();
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
      _selectedLevelId = (job.levelId == 0) ? null : job.levelId;
      _selectedRequiredDegree = job.requiredDegree;
      _hideSalary = job.hideSalary;
      _requireCv = job.requireCv;
      _currentStatus = job.status.toLowerCase();
      
      if (job.skills != null) {
        _selectedJobSkills.clear();
        _selectedJobSkills.addAll(job.skills!);
      }
    } catch (_) {}
  }

  bool get _isFieldLocked => _currentStatus != null && _currentStatus != 'draft';

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
    if (_currentStatus != null && _currentStatus != 'draft') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể thay đổi hạn chót cho tin đã đăng hoặc đang chờ duyệt')),
      );
      return;
    }

    final monetizationProvider = context.read<MonetizationProvider>();
    final subscription = monetizationProvider.currentSubscription;
    final isVip = subscription?.package?.isVip ?? false;
    final maxDays = isVip ? 30 : 7;
    
    final now = DateTime.now();
    final firstAllowed = DateTime(now.year, now.month, now.day);
    final lastAllowed = firstAllowed.add(Duration(days: maxDays));

    // Đảm bảo initialDate nằm trong khoảng [firstDate, lastDate]
    DateTime initialDate = _selectedDeadline ?? firstAllowed.add(const Duration(days: 1));
    if (initialDate.isBefore(firstAllowed)) initialDate = firstAllowed;
    if (initialDate.isAfter(lastAllowed)) initialDate = lastAllowed;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstAllowed,
      lastDate: lastAllowed,
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
      'levelId': _selectedLevelId,
      'requiredDegree': _selectedRequiredDegree,
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
      'hideSalary': _hideSalary,
      'requireCv': _requireCv,
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
    final monetizationProvider = context.read<MonetizationProvider>();
    final data = _getFormData();
    
    // Nếu là hành động đăng tin (publish = true), kiểm tra quota trước
    if (publish) {
      final subscription = monetizationProvider.currentSubscription;
      final activeCount = provider.totalPublishedCount;
      
      if (subscription != null && subscription.package != null) {
        final package = subscription.package!;
        
        // 1. Kiểm tra Cooldown Lock (Ưu tiên 1)
        if (!package.isVip && subscription.lastJobPublishedAt != null) {
          final cooldownDate = subscription.lastJobPublishedAt!.add(Duration(days: package.jobDurationDays));
          if (DateTime.now().isBefore(cooldownDate)) {
            _showQuotaErrorDialog('Bạn đang trong thời gian giãn cách. Vui lòng đợi đến ngày ${cooldownDate.day}/${cooldownDate.month} để đăng tin tiếp theo.');
            return;
          }
        }
        
        // 2. Kiểm tra Concurrency Limit (Ưu tiên 2)
        if (activeCount >= package.maxActiveJobs) {
          _showQuotaErrorDialog('Bạn đã dùng hết hạn mức tin đăng (${activeCount}/${package.maxActiveJobs}). Vui lòng đóng bớt tin cũ hoặc nâng cấp VIP.');
          return;
        }
      }
    }
    
    // Đặt status dựa trên mục đích
    if (widget.jobId == null) {
      // Tạo mới -> Luôn là draft
      data['status'] = 'draft';
    } else if (publish) {
      // Cập nhật và muốn đăng tin -> published
      data['status'] = 'published';
    }
    // Nếu là cập nhật thường (publish = false) -> Không gửi status để BE giữ nguyên

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
        // Refresh quota info sau khi lưu/đăng thành công
        monetizationProvider.fetchSubscriptionStatus();
        
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
          if (widget.jobId != null && isAdmin) // Hiện Lưu thay đổi khi sửa tin
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: TextButton(
                onPressed: jobProvider.isSavingJob ? null : () => _handleSave(publish: false),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue[100],
                  foregroundColor: Colors.blue[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('LƯU THAY ĐỔI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                  _buildTextField(_titleController, 'Tiêu đề công việc', Icons.work, required: true, enabled: isAdmin && !_isFieldLocked),
                  const SizedBox(height: 16),
                  
                  _buildDropdown<int>(
                    label: 'Lĩnh vực',
                    value: _selectedCategoryId,
                    items: profileProvider.allJobCategories.map((c) => 
                      DropdownMenuItem(
                        value: c.id, 
                        child: Text(c.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))
                      )).toList(),
                    onChanged: (isAdmin && !_isFieldLocked) ? (val) => setState(() => _selectedCategoryId = val) : null,
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
                    label: 'Cấp bậc',
                    value: _selectedLevelId,
                    items: jobProvider.jobLevels.map((l) => 
                      DropdownMenuItem(
                        value: l.id, 
                        child: Text(l.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))
                      )).toList(),
                    onChanged: isAdmin ? (val) => setState(() => _selectedLevelId = val) : null,
                    icon: Icons.bar_chart,
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

                  _buildDropdown<String>(
                    label: 'Bằng cấp yêu cầu',
                    value: _selectedRequiredDegree,
                    items: const [
                      DropdownMenuItem(value: 'postgraduate', child: Text('Trên đại học', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'university', child: Text('Đại học', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'college', child: Text('Cao đẳng', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'intermediate', child: Text('Trung cấp', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'high_school', child: Text('Trung học', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'certificate', child: Text('Chứng chỉ / Bằng nghề', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'none', child: Text('Không yêu cầu', style: TextStyle(fontSize: 13))),
                    ],
                    onChanged: isAdmin ? (val) => setState(() => _selectedRequiredDegree = val) : null,
                    icon: Icons.school,
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
                  const SizedBox(height: 12),
                  _buildVipFeatureToggle(
                    label: 'Ẩn mức lương với ứng viên',
                    value: _hideSalary,
                    onChanged: (val) => setState(() => _hideSalary = val),
                    icon: Icons.visibility_off,
                  ),
                  _buildVipFeatureToggle(
                    label: 'Bắt buộc ứng viên đính kèm CV',
                    value: _requireCv,
                    onChanged: (val) => setState(() => _requireCv = val),
                    icon: Icons.file_present,
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
                  if (widget.jobId != null && isAdmin && _currentStatus == 'draft') // Chỉ hiện Đăng tin khi đang là nháp và là admin
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
                  const SizedBox(height: 16),
                  
                  // Nút đẩy tin (Bump Job) - Di chuyển từ MyJobsPage sang đây
                  if (widget.jobId != null && isAdmin && (_currentStatus == 'published' || _currentStatus == 'approved'))
                    Builder(
                      builder: (context) {
                        final monetizationProvider = context.watch<MonetizationProvider>();
                        final subscription = monetizationProvider.currentSubscription;
                        final package = subscription?.package;
                        final usedQuota = subscription?.usedBumpPostQuota ?? 0;
                        final maxQuota = package?.bumpPostQuota ?? 0;
                        final hasFreeQuota = (package?.isVip ?? false) && usedQuota < maxQuota;
                        
                        // Tìm entity hiện tại để lấy trạng thái isBumped
                        JobPostEntity? currentJobEntity;
                        try {
                          currentJobEntity = jobProvider.employerJobs.firstWhere((j) => j.jobPostId == widget.jobId);
                        } catch (_) {}
                        
                        final isBumped = currentJobEntity?.isBumped ?? false;
                        
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: jobProvider.isSavingJob ? null : () => _handleBumpJob(context, currentJobEntity!),
                            icon: Icon(
                              isBumped ? Icons.rocket_launch : Icons.rocket_launch_outlined,
                              color: Colors.orange[800],
                            ),
                            label: Text(
                              isBumped 
                                ? 'TIN ĐANG ĐƯỢC ĐẨY' 
                                : (hasFreeQuota ? 'ĐẨY TIN LÊN ĐẦU (MIỄN PHÍ)' : 'ĐẨY TIN LÊN ĐẦU (30 CREDIT)'),
                              style: TextStyle(
                                fontSize: 14, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.orange[800]
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.orange[400]!, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: Colors.orange[50],
                            ),
                          ),
                        );
                      }
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

  Widget _buildVipFeatureToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    final monetizationProvider = context.watch<MonetizationProvider>();
    final isVip = monetizationProvider.currentSubscription?.isVip ?? false;
    final isLoading = monetizationProvider.isLoading && monetizationProvider.currentSubscription == null;
    final theme = Theme.of(context);

    if (isLoading) {
      return ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: const Text('Đang kiểm tra quyền hạn...', style: TextStyle(fontSize: 14, color: Colors.grey)),
        trailing: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        contentPadding: EdgeInsets.zero,
        dense: true,
      );
    }

    return Opacity(
      opacity: isVip ? 1.0 : 0.6,
      child: SwitchListTile(
        secondary: Icon(icon, color: isVip ? theme.colorScheme.primary : Colors.grey),
        title: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
            if (!isVip)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'VIP',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        value: isVip ? value : false,
        onChanged: (val) {
          if (isVip) {
            onChanged(val);
          } else {
            _showVipUpgradeDialog();
          }
        },
        activeColor: theme.colorScheme.primary,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }

  void _showVipUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.stars, color: Colors.amber),
            SizedBox(width: 8),
            Text('Tính năng VIP'),
          ],
        ),
        content: const Text('Tính năng này chỉ dành cho tài khoản VIP. Vui lòng nâng cấp gói cước để sử dụng.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ĐỂ SAU'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PricingPage()),
              );
            },
            child: const Text('NÂNG CẤP NGAY'),
          ),
        ],
      ),
    );
  }

  void _showQuotaErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Hạn mức đăng tin'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ĐÓNG'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PricingPage()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700], foregroundColor: Colors.white),
            child: const Text('NÂNG CẤP VIP'),
          ),
        ],
      ),
    );
  }

  void _handleBumpJob(BuildContext context, JobPostEntity job) async {
    final jobProvider = context.read<JobProvider>();
    final monetizationProvider = context.read<MonetizationProvider>();
    final subscription = monetizationProvider.currentSubscription;
    final package = subscription?.package;
    final usedQuota = subscription?.usedBumpPostQuota ?? 0;
    final maxQuota = package?.bumpPostQuota ?? 0;
    final hasFreeQuota = (package?.isVip ?? false) && usedQuota < maxQuota;
    final remainingFree = maxQuota - usedQuota;
    
    // Check if already bumped
    if (job.isBumped) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tin này đang được đẩy đến ${job.bumpedUntil?.day}/${job.bumpedUntil?.month}'),
          backgroundColor: Theme.of(context).primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.rocket_launch, color: Colors.orange),
            SizedBox(width: 8),
            Text('Xác nhận đẩy tin'),
          ],
        ),
        content: Text(
          hasFreeQuota 
            ? 'Bạn có muốn dùng 1 lượt đẩy tin miễn phí cho tin này không?\n(Bạn còn $remainingFree lượt miễn phí trong tháng)'
            : 'Bạn có muốn dùng 30 Credit để đẩy tin này lên đầu danh sách tìm kiếm không?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await jobProvider.bumpJob(job.jobPostId);
    if (result != null) {
      // Refresh monetization state
      monetizationProvider.fetchSubscriptionStatus();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tin của bạn đã được đẩy lên đầu trang thành công!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (jobProvider.saveJobError != null) {
      // Handle insufficient credits (400 or 402)
      final error = jobProvider.saveJobError!;
      if (error.contains('400') || error.contains('402') || error.contains('không đủ') || error.contains('Credit')) {
        _showInsufficientCreditsDialog(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _showInsufficientCreditsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Không đủ Credit'),
        content: const Text('Số dư Credit của bạn không đủ để thực hiện đẩy tin (Cần 30 Credit). Vui lòng nạp thêm Credit hoặc nâng cấp VIP để tiếp tục.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PricingPage()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Nạp ngay'),
          ),
        ],
      ),
    );
  }
}
