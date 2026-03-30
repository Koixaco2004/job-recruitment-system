import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employer_provider.dart';
import '../../../metadata/domain/usecases/get_provinces_usecase.dart';
import '../../../metadata/domain/usecases/get_job_categories_usecase.dart';
import '../../../metadata/domain/entities/province_entity.dart';
import '../../../metadata/domain/entities/job_category_entity.dart';
import '../../../../injection_container.dart';

class CompanySetupPage extends StatefulWidget {
  const CompanySetupPage({super.key});

  @override
  State<CompanySetupPage> createState() => _CompanySetupPageState();
}

class _CompanySetupPageState extends State<CompanySetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _addressController = TextEditingController();

  List<ProvinceEntity> _provinces = [];
  List<JobCategoryEntity> _categories = [];
  int? _selectedProvinceId;
  int? _selectedCategoryId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn lĩnh vực kinh doanh')),
        );
        return;
      }

      final success = await context.read<EmployerProvider>().setupCompany(
            fullName: _fullNameController.text,
            phoneContact: _phoneController.text,
            companyName: _companyNameController.text,
            categoryId: _selectedCategoryId!,
            provinceId: _selectedProvinceId,
            address: _addressController.text,
          );

      if (success && mounted) {
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<EmployerProvider>().errorMessage ?? 'Lỗi khi lưu thông tin')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thiết lập công ty'),
        automaticallyImplyLeading: false, // Mandatory: No back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Chào mừng! Vui lòng hoàn thành thông tin công ty để tiếp tục.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text('Thông tin cá nhân HR', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              const Divider(),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Họ và tên HR', prefixIcon: Icon(Icons.person)),
                validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập họ tên' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại contact', prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
              ),
              const SizedBox(height: 32),
              const Text('Thông tin công ty', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              const Divider(),
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(labelText: 'Tên Công ty', prefixIcon: Icon(Icons.business)),
                validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tên công ty' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Lĩnh vực / Ngành nghề', prefixIcon: Icon(Icons.category)),
                items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                 validator: (v) => v == null ? 'Vui lòng chọn ngành nghề' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedProvinceId,
                decoration: const InputDecoration(labelText: 'Tỉnh / Thành phố', prefixIcon: Icon(Icons.location_on)),
                items: _provinces.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                onChanged: (val) => setState(() => _selectedProvinceId = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Địa chỉ cụ thể'),
              ),
              const SizedBox(height: 32),
              Consumer<EmployerProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: provider.isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('BẮT ĐẦU NGAY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
