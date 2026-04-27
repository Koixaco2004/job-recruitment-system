import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/company_provider.dart';
import '../widgets/company_info_tab.dart';
import '../widgets/company_jobs_tab.dart';

/// Màn hình chi tiết công ty
class CompanyDetailPage extends StatefulWidget {
  final int? employerId;
  final String? companySlug;

  const CompanyDetailPage({
    super.key,
    this.employerId,
    this.companySlug,
  }) : assert(employerId != null || companySlug != null,
            'Either employerId or companySlug must be provided');

  @override
  State<CompanyDetailPage> createState() => _CompanyDetailPageState();
}

class _CompanyDetailPageState extends State<CompanyDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CompanyProvider>();
      if (widget.employerId != null) {
        provider.fetchCompanyDetail(widget.employerId!).then((_) {
          final company = provider.selectedCompany;
          if (company != null && company.slug != null) {
            provider.fetchCompanyJobs(company.slug!);
          }
        });
      } else if (widget.companySlug != null) {
        provider.fetchCompanyBySlug(widget.companySlug!).then((_) {
          final company = provider.selectedCompany;
          if (company != null && company.slug != null) {
            provider.fetchCompanyJobs(company.slug!);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CompanyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.employerId != null) {
                        provider.fetchCompanyDetail(widget.employerId!).then((_) {
                          final company = provider.selectedCompany;
                          if (company != null && company.slug != null) {
                            provider.fetchCompanyJobs(company.slug!);
                          }
                        });
                      } else if (widget.companySlug != null) {
                        provider.fetchCompanyBySlug(widget.companySlug!).then((_) {
                          final company = provider.selectedCompany;
                          if (company != null && company.slug != null) {
                            provider.fetchCompanyJobs(company.slug!);
                          }
                        });
                      }
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final company = provider.selectedCompany;
          if (company == null) {
            return const Center(child: Text('Không tìm thấy công ty'));
          }

          return CustomScrollView(
            slivers: [
              // SliverAppBar with cover image and logo
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Cover image
                      if (company.coverImageUrl != null)
                        Image.network(
                          company.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.blue[700],
                              child: const Center(
                                child: Icon(
                                  Icons.business,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          color: Colors.blue[700],
                          child: const Center(
                            child: Icon(
                              Icons.business,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),

                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),

                      // Logo and company name
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Row(
                          children: [
                            // Logo
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                image: company.logoUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(company.logoUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: company.logoUrl == null
                                  ? const Icon(
                                      Icons.business,
                                      size: 40,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),

                            // Company name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    company.companyName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (company.industryName != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      company.industryName!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // TabBar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).primaryColor,
                    tabs: const [
                      Tab(text: 'Giới thiệu'),
                      Tab(text: 'Tuyển dụng'),
                    ],
                  ),
                ),
              ),

              // TabBarView
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    CompanyInfoTab(company: company),
                    CompanyJobsTab(companySlug: company.slug ?? ''),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Delegate for pinned TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
