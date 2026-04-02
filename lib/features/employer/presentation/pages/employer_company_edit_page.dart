import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employer_provider.dart';
import '../../../metadata/domain/usecases/get_provinces_usecase.dart';
import '../../../metadata/domain/usecases/get_job_categories_usecase.dart';
import '../../../metadata/domain/entities/province_entity.dart';
import '../../../metadata/domain/entities/job_category_entity.dart';
import '../../../../injection_container.dart';
import '../../../../core/network/api_client.dart';

class EmployerCompanyEditPage extends StatefulWidget {
  const EmployerCompanyEditPage({super.key});

  @override
  State<EmployerCompanyEditPage> createState() => _EmployerCompanyEditPageState();
}

class _EmployerCompanyEditPageState extends State<EmployerCompanyEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _websiteController;
  late TextEditingController _addressController;
  late TextEditingController _emailContactController;
  late TextEditingController _phoneContactController;
  late TextEditingController _companySizeController;
  late TextEditingController _facebookUrlController;
  late TextEditingController _linkedinUrlController;
  late TextEditingController _contentController;

  List<ProvinceEntity> _provinces = [];
  List<JobCategoryEntity> _categories = [];
  int? _selectedProvinceId;
  int? _selectedCategoryId;
  bool _isInitLoading = true;

  @override
  void initState() {
    super.initState();
    final company = context.read<EmployerProvider>().employer?.company;
    _nameController = TextEditingController(text: company?.name ?? '');
    _descriptionController = TextEditingController(text: company?.description ?? '');
    _websiteController = TextEditingController(text: company?.websiteUrl ?? '');
    _addressController = TextEditingController(text: company?.address ?? '');
    _emailContactController = TextEditingController(text: company?.emailContact ?? '');
    _phoneContactController = TextEditingController(text: company?.phoneContact ?? '');
    _companySizeController = TextEditingController(text: company?.companySize ?? '');
    _facebookUrlController = TextEditingController(text: company?.facebookUrl ?? '');
    _linkedinUrlController = TextEditingController(text: company?.linkedinUrl ?? '');
    _contentController = TextEditingController(text: company?.content ?? company?.description ?? '');
    _selectedProvinceId = company?.provinceId;
    _selectedCategoryId = company?.categoryId;
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    final getProvinces = sl<GetProvincesUseCase>();
    final getCategories = sl<GetJobCategoriesUseCase>();

    final results = await Future.wait([
      getProvinces(),
      getCategories(),
    ]);

    if (mounted) {
      setState(() {
        results[0].fold((_) => null, (list) => _provinces = list as List<ProvinceEntity>);
        results[1].fold((_) => null, (list) => _categories = list as List<JobCategoryEntity>);
        _isInitLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _emailContactController.dispose();
    _phoneContactController.dispose();
    _companySizeController.dispose();
    _facebookUrlController.dispose();
    _linkedinUrlController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String? _formatUrl(String? url) {
    if (url == null || url.trim().isEmpty) return "";
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<EmployerProvider>().updateCompanyProfile(
            name: _nameController.text,
            description: _descriptionController.text,
            content: _contentController.text,
            websiteUrl: _formatUrl(_websiteController.text),
            address: _addressController.text,
            provinceId: _selectedProvinceId,
            categoryId: _selectedCategoryId,
            emailContact: _emailContactController.text,
            phoneContact: _phoneContactController.text,
            companySize: _companySizeController.text,
            facebookUrl: _formatUrl(_facebookUrlController.text),
            linkedinUrl: _formatUrl(_linkedinUrlController.text),
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin công ty thành công')),
        );
      } else if (mounted) {
        final error = context.read<EmployerProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Lỗi cập nhật thông tin'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ công ty'),
        actions: [
          IconButton(
            onPressed: context.watch<EmployerProvider>().isSavingCompany ? null : _save,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Consumer<EmployerProvider>(
        builder: (context, provider, child) {
          final company = provider.employer?.company;
          if (company == null) return const Center(child: Text('Không tìm thấy thông tin công ty'));

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner & Logo Section
                _buildHeader(provider),
                
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildVerificationStatusAlert(company),
                        const SizedBox(height: 24),
                        const Text(
                          'Thông tin cơ bản',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(_nameController, 'Tên công ty', Icons.business, validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null),
                        const SizedBox(height: 16),
                        _buildTextField(_emailContactController, 'Email liên hệ', Icons.email, keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 16),
                        _buildTextField(_phoneContactController, 'Số điện thoại', Icons.phone, keyboardType: TextInputType.phone),
                        const SizedBox(height: 16),
                        _buildTextField(_websiteController, 'Website', Icons.link),
                        const SizedBox(height: 16),
                        _buildTextField(_facebookUrlController, 'Facebook URL', Icons.facebook),
                        const SizedBox(height: 16),
                        _buildTextField(_linkedinUrlController, 'LinkedIn URL', Icons.link),
                        const SizedBox(height: 16),
                        _buildTextField(_companySizeController, 'Quy mô (ví dụ: 50-100 nhân viên)', Icons.people),
                        const SizedBox(height: 16),
                        _buildDropdown<int>(
                          label: 'Lĩnh vực',
                          icon: Icons.category,
                          value: _selectedCategoryId,
                          items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                          onChanged: (val) => setState(() => _selectedCategoryId = val),
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown<int>(
                          label: 'Tỉnh / Thành phố',
                          icon: Icons.location_on,
                          value: _selectedProvinceId,
                          items: _provinces.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                          onChanged: (val) => setState(() => _selectedProvinceId = val),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(_addressController, 'Địa chỉ cụ thể', Icons.map),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _descriptionController, 
                          'Mô tả ngắn', 
                          Icons.description, 
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _contentController, 
                          'Nội dung chi tiết', 
                          Icons.article, 
                          maxLines: 8,
                        ),
                        const SizedBox(height: 32),

                        // Business License Section
                        const Text(
                          'Giấy phép kinh doanh',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.verified_user, color: Colors.blue),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      (company.businessLicenseUrl != null && company.businessLicenseUrl!.isNotEmpty)
                                          ? 'Đã tải lên: ${company.businessLicenseUrl!.split('/').last}'
                                          : 'Chưa có giấy phép kinh doanh',
                                      style: TextStyle(
                                        color: (company.businessLicenseUrl != null && company.businessLicenseUrl!.isNotEmpty)
                                            ? Colors.black87
                                            : Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (provider.isUploadingBusinessLicense)
                                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  else
                                    IconButton(
                                      icon: const Icon(Icons.upload_file, color: Colors.blue),
                                      onPressed: provider.pickAndUploadBusinessLicense,
                                    ),
                                ],
                              ),
                              if (company.businessLicenseUrl != null && company.businessLicenseUrl!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    company.businessLicenseUrl!.startsWith('http') 
                                        ? company.businessLicenseUrl! 
                                        : '${sl<ApiClient>().dio.options.baseUrl}${company.businessLicenseUrl}',
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 200,
                                        color: Colors.grey[100],
                                        child: const Center(child: CircularProgressIndicator()),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 100,
                                      width: double.infinity,
                                      color: Colors.grey[100],
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.insert_drive_file, color: Colors.grey, size: 40),
                                          SizedBox(height: 8),
                                          Text('Tệp đính kèm (không thể xem trước)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Gallery Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bộ sưu tập hình ảnh',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            if (provider.isUploadingGallery)
                              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            else
                              IconButton(
                                icon: const Icon(Icons.add_a_photo, color: Colors.blue),
                                onPressed: provider.pickAndUploadGalleryImage,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildGallery(provider),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(EmployerProvider provider) {
    final company = provider.employer?.company;
    const placeholderBanner = 'https://via.placeholder.com/800x400?text=Banner';
    const placeholderLogo = 'https://via.placeholder.com/200x200?text=Logo';
    
    final bannerUrl = (company?.bannerUrl != null && company!.bannerUrl!.isNotEmpty) 
        ? company.bannerUrl!.startsWith('http') ? company.bannerUrl! : '${sl<ApiClient>().dio.options.baseUrl}${company.bannerUrl}'
        : placeholderBanner;

    final logoUrl = (company?.logoUrl != null && company!.logoUrl!.isNotEmpty)
        ? company.logoUrl!.startsWith('http') ? company.logoUrl! : '${sl<ApiClient>().dio.options.baseUrl}${company.logoUrl}'
        : placeholderLogo;

    return SizedBox(
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Banner
          GestureDetector(
            onTap: provider.pickAndUploadBanner,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                image: DecorationImage(
                  image: NetworkImage(bannerUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                   if (provider.isUploadingBanner)
                    const Center(child: CircularProgressIndicator())
                  else
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 18,
                        child: Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Logo
          Positioned(
            left: 20,
            bottom: 0,
            child: GestureDetector(
              onTap: provider.pickAndUploadLogo,
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(logoUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (provider.isUploadingLogo)
                    const Positioned.fill(child: Center(child: CircularProgressIndicator()))
                  else
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 14,
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 14),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatusAlert(dynamic company) {
    final status = company.status;
    final reason = company.rejectionReason;

    Color bgColor;
    Color textColor;
    IconData icon;
    String title;
    String description;

    if (status == 'approved') {
      bgColor = Colors.green[50]!;
      textColor = Colors.green[700]!;
      icon = Icons.verified;
      title = 'Công ty đã được xác thực';
      description = 'Hồ sơ của bạn đã được phê duyệt bởi hệ thống.';
    } else if (status == 'rejected') {
      bgColor = Colors.red[50]!;
      textColor = Colors.red[700]!;
      icon = Icons.error_outline;
      title = 'Hồ sơ bị từ chối';
      description = reason ?? 'Vui lòng cập nhật lại thông tin để được duyệt.';
    } else if (status == 'pending') {
      bgColor = Colors.blue[50]!;
      textColor = Colors.blue[700]!;
      icon = Icons.hourglass_empty;
      title = 'Đang chờ phê duyệt';
      description = 'Admin đang xem xét hồ sơ của bạn.';
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, String? Function(String?)? validator, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown<T>({required String label, required IconData icon, required T? value, required List<DropdownMenuItem<T>> items, required Function(T?) onChanged}) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildGallery(EmployerProvider provider) {
    final images = provider.employer?.company?.images ?? [];
    
    if (images.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Chưa có ảnh nào trong bộ sưu tập', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imageUrl = images[index].startsWith('http') 
              ? images[index] 
              : '${sl<ApiClient>().dio.options.baseUrl}${images[index]}';
              
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 200,
                height: 150,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
              ),
            ),
          );
        },
      ),
    );
  }
}
