import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/company_provider.dart';
import '../widgets/company_card.dart';
import '../widgets/company_list_tile.dart';
import 'company_detail_page.dart';

/// Màn hình danh sách công ty
class CompaniesPage extends StatefulWidget {
  const CompaniesPage({super.key});

  @override
  State<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyProvider>().fetchCompanies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Công ty'),
        actions: [
          // Toggle Grid/List view
          Consumer<CompanyProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(provider.isGridView ? Icons.list : Icons.grid_view),
                onPressed: provider.toggleViewMode,
                tooltip: provider.isGridView
                    ? 'Chuyển sang List view'
                    : 'Chuyển sang Grid view',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm công ty...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<CompanyProvider>().searchCompanies('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (query) {
                context.read<CompanyProvider>().searchCompanies(query);
                setState(() {}); // Update to show/hide clear button
              },
            ),
          ),

          // Company list
          Expanded(
            child: Consumer<CompanyProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(provider.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.fetchCompanies(),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.companies.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.searchQuery.isEmpty
                              ? 'Chưa có công ty nào'
                              : 'Không tìm thấy công ty phù hợp',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchCompanies(),
                  child: provider.isGridView
                      ? _buildGridView(provider)
                      : _buildListView(provider),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(CompanyProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: provider.companies.length,
      itemBuilder: (context, index) {
        final company = provider.companies[index];
        return CompanyCard(
          company: company,
          onTap: () => _navigateToDetail(company.employerId),
        );
      },
    );
  }

  Widget _buildListView(CompanyProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: provider.companies.length,
      itemBuilder: (context, index) {
        final company = provider.companies[index];
        return CompanyListTile(
          company: company,
          onTap: () => _navigateToDetail(company.employerId),
        );
      },
    );
  }

  void _navigateToDetail(int employerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyDetailPage(employerId: employerId),
      ),
    );
  }
}
