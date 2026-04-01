import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/job_post_entity.dart';
import '../providers/job_provider.dart';

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
  final _expController = TextEditingController();

  int? _selectedProvinceId;
  int? _selectedCategoryId;
  int? _selectedJobTypeId;
  DateTime? _selectedDeadline;

  bool _isInit = false;

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
      _slotsController.text = (job.numberOfPositions > 0) ? job.numberOfPositions.toString() : '';
      _expController.text = (job.experienceRequired > 0) ? job.experienceRequired.toString() : '';
      _selectedDeadline = job.deadline;
      
      _selectedProvinceId = job.provinceId;
      _selectedCategoryId = job.categoryId;
      _selectedJobTypeId = job.jobTypeId;
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
    _slotsController.dispose();
    _expController.dispose();
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
      'skills': [],
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jobId == null ? 'Đăng tin mới' : 'Chỉnh sửa tin'),
        actions: [
          if (widget.jobId == null) // Chỉ hiện Lưu nháp khi tạo tin mới
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
                  _buildTextField(_titleController, 'Tiêu đề công việc', Icons.work, required: true),
                  const SizedBox(height: 16),
                  
                  _buildDropdown<int>(
                    label: 'Lĩnh vực',
                    value: _selectedCategoryId,
                    items: profileProvider.allJobCategories.map((c) => 
                      DropdownMenuItem(
                        value: c.id, 
                        child: Text(c.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))
                      )).toList(),
                    onChanged: (val) => setState(() => _selectedCategoryId = val),
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
                    onChanged: (val) => setState(() => _selectedJobTypeId = val),
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
                    onChanged: (val) => setState(() => _selectedProvinceId = val),
                    icon: Icons.location_city,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(_slotsController, 'Số lượng tuyển', Icons.people, isNumber: true),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Yêu cầu & Lương'),
                  _buildTextField(_salaryMinController, 'Lương tối thiểu (VND)', Icons.money, isNumber: true),
                  const SizedBox(height: 16),
                  _buildTextField(_salaryMaxController, 'Lương tối đa (VND)', Icons.money, isNumber: true),
                  const SizedBox(height: 16),
                  _buildTextField(_expController, 'Năm kinh nghiệm yêu cầu', Icons.history, isNumber: true),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Chi tiết nội dung'),
                  _buildTextField(_descriptionController, 'Mô tả công việc', Icons.description, maxLines: 5, required: true),
                  const SizedBox(height: 16),
                  _buildTextField(_requirementsController, 'Yêu cầu ứng viên', Icons.list, maxLines: 5),
                  const SizedBox(height: 16),
                  _buildTextField(_benefitsController, 'Quyền lợi', Icons.card_giftcard, maxLines: 5),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Thời hạn'),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today, color: Colors.blue),
                    title: const Text('Hạn chót nộp hồ sơ'),
                    subtitle: Text(_selectedDeadline == null 
                        ? 'Chưa chọn ngày' 
                        : DateFormat('dd/MM/yyyy').format(_selectedDeadline!)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _selectDeadline,
                  ),
                  
                  const SizedBox(height: 40),
                  if (widget.jobId != null) // Chỉ hiện Đăng tin khi đang sửa bản ghi đã tồn tại
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    {bool isNumber = false, int maxLines = 1, bool required = false}
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.multiline,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return 'Vui lòng nhập $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (val) => val == null ? 'Bắt buộc' : null,
    );
  }
}
