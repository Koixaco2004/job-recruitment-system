import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/domain/entities/skill_entity.dart';
import '../../domain/models/candidate_filter_model.dart';
import '../providers/candidate_search_provider.dart';

class CandidateFilterBottomSheet extends StatefulWidget {
  const CandidateFilterBottomSheet({super.key});

  @override
  State<CandidateFilterBottomSheet> createState() => _CandidateFilterBottomSheetState();
}

class _CandidateFilterBottomSheetState extends State<CandidateFilterBottomSheet> {
  late CandidateFilterModel _tempFilter;
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _salaryMinController = TextEditingController();
  final TextEditingController _salaryMaxController = TextEditingController();
  final TextEditingController _skillSearchController = TextEditingController();
  List<SkillEntity> _selectedSkillEntities = [];

  @override
  void initState() {
    super.initState();
    final candidateProvider = context.read<CandidateSearchProvider>();
    _tempFilter = candidateProvider.filter;
    _selectedSkillEntities = List.from(candidateProvider.selectedSkillEntities);

    if (_tempFilter.minExperience != null) {
      _experienceController.text = _tempFilter.minExperience.toString();
    }
    if (_tempFilter.salaryMin != null) {
      _salaryMinController.text = _tempFilter.salaryMin.toString();
    }
    if (_tempFilter.salaryMax != null) {
      _salaryMaxController.text = _tempFilter.salaryMax.toString();
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      profileProvider.fetchProvincesIfEmpty();
      profileProvider.fetchJobTypesIfEmpty();
      profileProvider.fetchJobCategoriesMetadata();
    });
  }

  @override
  void dispose() {
    _experienceController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _skillSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final isMetadataLoading = profileProvider.isLoadingProvinces || 
                             profileProvider.isLoadingJobCategories || 
                             profileProvider.isLoadingJobTypes;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Text(
                  'Bộ lọc ứng viên',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Filter content
          Expanded(
            child: isMetadataLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Experience Input ---
                        _buildDropdownSection(
                          title: 'Số năm kinh nghiệm (tối thiểu)',
                          icon: Icons.history_edu_outlined,
                          child: TextField(
                            controller: _experienceController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('Ví dụ: 2'),
                            onChanged: (val) {
                              setState(() {
                                _tempFilter = _tempFilter.copyWith(
                                  minExperience: int.tryParse(val),
                                  clearExperience: val.isEmpty,
                                );
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- Salary Range ---
                        _buildDropdownSection(
                          title: 'Mức lương ngân sách (VNĐ)',
                          icon: Icons.monetization_on_outlined,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _salaryMinController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration('Tối thiểu'),
                                  onChanged: (val) {
                                    setState(() {
                                      _tempFilter = _tempFilter.copyWith(
                                        salaryMin: int.tryParse(val),
                                        clearSalaryMin: val.isEmpty,
                                      );
                                    });
                                  },
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text('—', style: TextStyle(color: Colors.grey)),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _salaryMaxController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration('Tối đa'),
                                  onChanged: (val) {
                                    setState(() {
                                      _tempFilter = _tempFilter.copyWith(
                                        salaryMax: int.tryParse(val),
                                        clearSalaryMax: val.isEmpty,
                                      );
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- Skills Section ---
                        _buildDropdownSection(
                          title: 'Kỹ năng',
                          icon: Icons.psychology_outlined,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Selected Skills Tags
                              if (_selectedSkillEntities.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _selectedSkillEntities.map((skill) => Chip(
                                      label: Text(skill.canonicalName, style: const TextStyle(fontSize: 12)),
                                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                      deleteIcon: const Icon(Icons.close, size: 16),
                                      onDeleted: () {
                                        setState(() {
                                          _selectedSkillEntities.removeWhere((s) => s.id == skill.id);
                                          final newIds = _selectedSkillEntities.map((s) => s.id).toList();
                                          _tempFilter = _tempFilter.copyWith(
                                            skillIds: newIds,
                                            clearSkillIds: newIds.isEmpty,
                                          );
                                        });
                                      },
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                                    )).toList(),
                                  ),
                                ),

                              // Search Field
                              TextFormField(
                                controller: _skillSearchController,
                                decoration: _inputDecoration('Tìm kiếm kỹ năng (vd: Java, React...)').copyWith(
                                  prefixIcon: const Icon(Icons.search, size: 20),
                                  suffixIcon: profileProvider.isLoadingSkills 
                                    ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
                                    : _skillSearchController.text.isNotEmpty 
                                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                                          _skillSearchController.clear();
                                          profileProvider.searchSkills('');
                                        })
                                      : null,
                                ),
                                onChanged: (val) => profileProvider.searchSkills(val),
                              ),

                              // Search Results
                              if (profileProvider.skillSearchResults.isNotEmpty && _skillSearchController.text.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                                    ],
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: profileProvider.skillSearchResults.length,
                                    itemBuilder: (context, index) {
                                      final skill = profileProvider.skillSearchResults[index];
                                      final isSelected = _selectedSkillEntities.any((s) => s.id == skill.id);
                                      
                                      return ListTile(
                                        title: Text(skill.canonicalName),
                                        trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
                                        onTap: () {
                                          if (!isSelected) {
                                            setState(() {
                                              _selectedSkillEntities.add(skill);
                                              final newIds = _selectedSkillEntities.map((s) => s.id).toList();
                                              _tempFilter = _tempFilter.copyWith(
                                                skillIds: newIds,
                                                clearSkillIds: false,
                                              );
                                              _skillSearchController.clear();
                                              profileProvider.searchSkills('');
                                            });
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- Province Dropdown ---
                        _buildDropdownSection(
                          title: 'Tỉnh / Thành phố',
                          icon: Icons.location_on_outlined,
                          child: DropdownButtonFormField<int>(
                            value: profileProvider.provinces.any((p) => p.id == _tempFilter.provinceId) ? _tempFilter.provinceId : null,
                            isExpanded: true,
                            decoration: _dropdownDecoration('Chọn tỉnh/thành phố'),
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('Tất cả tỉnh thành'),
                              ),
                              ...profileProvider.provinces.map((p) => DropdownMenuItem<int>(
                                value: p.id,
                                child: Text(p.name),
                              )),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _tempFilter = _tempFilter.copyWith(
                                  provinceId: val,
                                  clearProvince: val == null,
                                );
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- Category Dropdown ---
                        _buildDropdownSection(
                          title: 'Ngành nghề',
                          icon: Icons.work_outline,
                          child: DropdownButtonFormField<int>(
                            value: profileProvider.allJobCategories.any((c) => c.id == (_tempFilter.categoryIds?.first ?? -1)) ? _tempFilter.categoryIds?.first : null,
                            isExpanded: true,
                            decoration: _dropdownDecoration('Chọn ngành nghề'),
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('Tất cả ngành nghề'),
                              ),
                              ...profileProvider.allJobCategories.map((c) => DropdownMenuItem<int>(
                                value: c.id,
                                child: Text(c.name),
                              )),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _tempFilter = _tempFilter.copyWith(
                                  categoryIds: val != null ? [val] : null,
                                  clearCategory: val == null,
                                );
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- Job Type Dropdown ---
                        _buildDropdownSection(
                          title: 'Hình thức làm việc',
                          icon: Icons.access_time,
                          child: DropdownButtonFormField<int>(
                            value: profileProvider.jobTypes.any((jt) => jt.id == _tempFilter.jobTypeId) ? _tempFilter.jobTypeId : null,
                            isExpanded: true,
                            decoration: _dropdownDecoration('Chọn hình thức'),
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('Tất cả hình thức'),
                              ),
                              ...profileProvider.jobTypes.map((jt) => DropdownMenuItem<int>(
                                value: jt.id,
                                child: Text(jt.name),
                              )),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _tempFilter = _tempFilter.copyWith(
                                  jobTypeId: val,
                                  clearJobType: val == null,
                                );
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _tempFilter = const CandidateFilterModel();
                        _selectedSkillEntities = [];
                        _experienceController.clear();
                        _salaryMinController.clear();
                        _salaryMaxController.clear();
                        _skillSearchController.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Xóa bộ lọc', style: TextStyle(color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<CandidateSearchProvider>().updateFilter(
                        _tempFilter,
                        selectedSkills: _selectedSkillEntities,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Áp dụng', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSection({required String title, required IconData icon, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return _inputDecoration(hint);
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}
