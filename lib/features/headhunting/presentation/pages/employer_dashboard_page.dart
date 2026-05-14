import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/employer_dashboard_provider.dart';
import '../../data/models/employer_dashboard_stats_model.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import 'job_detailed_stats_page.dart';
import 'employer_invitation_list_page.dart';
import 'employer_saved_candidates_page.dart';
import '../../../employer/presentation/pages/employer_main_page.dart';
import '../../../employer/presentation/providers/employer_provider.dart';
import '../../../employer/presentation/pages/employer_company_edit_page.dart';
import '../../../employer/presentation/pages/company_setup_page.dart';

class EmployerDashboardPage extends StatefulWidget {
  final Function(int)? onSwitchTab;
  const EmployerDashboardPage({super.key, this.onSwitchTab});

  @override
  State<EmployerDashboardPage> createState() => _EmployerDashboardPageState();
}

class _EmployerDashboardPageState extends State<EmployerDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployerDashboardProvider>().fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<EmployerDashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.stats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.stats == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!),
                  ElevatedButton(
                    onPressed: () => provider.fetchDashboardStats(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final stats = provider.stats;
          if (stats == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: () => provider.fetchDashboardStats(),
            child: CustomScrollView(
              slivers: [
                _buildHeader(context, provider),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildVerificationStatusCard(context),
                      const SizedBox(height: 16),
                      _buildSummaryCards(stats),
                      const SizedBox(height: 24),
                      _buildGrowthChart(stats.applications.trend, provider),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 10, child: _buildJobStatusChart(stats.jobs)),
                          const SizedBox(width: 12),
                          Expanded(flex: 13, child: _buildTopJobs(stats.topJobs)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildApplicationFunnel(stats.applications.conversionRate),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EmployerDashboardProvider provider) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 20,
          right: 20,
          bottom: 30,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF311B92),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hệ thống phân tích tuyển dụng thông minh',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const NotificationBell(iconColor: Colors.white),
              ],
            ),
            const SizedBox(height: 20),
            _buildFilterBar(context, provider),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildHeaderButton(
                  Icons.refresh, 
                  'Làm mới', 
                  () => provider.fetchDashboardStats(), 
                  isPrimary: true,
                  isLoading: provider.isLoading,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, EmployerDashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Bộ lọc thời gian',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildYearDropdown(provider),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildGranularitySegmentedControl(provider),
              const SizedBox(width: 12),
              Expanded(child: _buildDetailDropdown(provider)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearDropdown(EmployerDashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: provider.currentYear,
          dropdownColor: const Color(0xFF311B92),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          items: List.generate(5, (index) => 2023 + index).map((year) {
            return DropdownMenuItem(
              value: year,
              child: Text('$year'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              provider.setFilters(year: value);
              provider.fetchDashboardStats();
            }
          },
        ),
      ),
    );
  }

  Widget _buildGranularitySegmentedControl(EmployerDashboardProvider provider) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildGranularityOption(provider, 'month', 'Tháng'),
          _buildGranularityOption(provider, 'quarter', 'Quý'),
        ],
      ),
    );
  }

  Widget _buildGranularityOption(EmployerDashboardProvider provider, String value, String label) {
    final isSelected = provider.currentGranularity == value;
    return GestureDetector(
      onTap: () {
        provider.setFilters(granularity: value);
        provider.fetchDashboardStats();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF311B92) : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailDropdown(EmployerDashboardProvider provider) {
    if (provider.currentGranularity == 'month') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: provider.currentMonth,
            dropdownColor: const Color(0xFF311B92),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            items: List.generate(12, (index) => index + 1).map((month) {
              return DropdownMenuItem(
                value: month,
                child: Text('Tháng $month'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                provider.setFilters(month: value);
                provider.fetchDashboardStats();
              }
            },
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: provider.currentQuarter,
            dropdownColor: const Color(0xFF311B92),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            items: ['Q1', 'Q2', 'Q3', 'Q4'].map((q) {
              return DropdownMenuItem(
                value: q,
                child: Text('Quý $q'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                provider.setFilters(quarter: value);
                provider.fetchDashboardStats();
              }
            },
          ),
        ),
      );
    }
  }

  Widget _buildVerificationStatusCard(BuildContext context) {
    final employerProvider = context.watch<EmployerProvider>();
    final company = employerProvider.employer?.company;
    
    if (company == null) return const SizedBox.shrink();

    Color bgColor;
    Color textColor;
    IconData icon;
    String statusText;
    String description;

    switch (company.status.toLowerCase()) {
      case 'approved':
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF059669);
        icon = Icons.verified_user;
        statusText = 'ĐÃ XÁC THỰC';
        description = 'Công ty của bạn đã được xác thực chính thức.';
        break;
      case 'pending':
        bgColor = const Color(0xFFFFFBEB);
        textColor = const Color(0xFFD97706);
        icon = Icons.pending_actions;
        statusText = 'ĐANG CHỜ DUYỆT';
        description = 'Hồ sơ đang được hệ thống kiểm tra và phê duyệt.';
        break;
      case 'rejected':
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFDC2626);
        icon = Icons.error_outline;
        statusText = 'BỊ TỪ CHỐI';
        description = company.rejectionReason ?? 'Hồ sơ bị từ chối. Vui lòng cập nhật lại.';
        break;
      default: // idle or others
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF475569);
        icon = Icons.info_outline;
        statusText = 'CHƯA XÁC THỰC';
        description = 'Vui lòng hoàn tất xác thực để tăng uy tín tuyển dụng.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (company.status.toLowerCase() != 'approved')
            TextButton(
              onPressed: () {
                if (company.status.toLowerCase() == 'idle') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CompanySetupPage()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EmployerCompanyEditPage()),
                  );
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: textColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cập nhật', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, String label, VoidCallback onTap, {bool isPrimary = false, bool isLoading = false}) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onTap,
      icon: isLoading 
        ? SizedBox(
            width: 18, 
            height: 18, 
            child: CircularProgressIndicator(
              strokeWidth: 2, 
              valueColor: AlwaysStoppedAnimation<Color>(isPrimary ? const Color(0xFF311B92) : Colors.white)
            )
          )
        : Icon(icon, size: 18, color: isPrimary ? const Color(0xFF311B92) : Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.white : Colors.white.withOpacity(0.1),
        foregroundColor: isPrimary ? const Color(0xFF311B92) : Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSummaryCards(EmployerDashboardStatsModel stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'TỔNG SỐ TIN',
                stats.jobs.total.toString(),
                Icons.work_outline,
                const Color(0xFF3B82F6),
                const Color(0xFFEFF6FF),
                onTap: () {
                  if (widget.onSwitchTab != null) {
                    widget.onSwitchTab!(1);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'ỨNG VIÊN MỚI',
                stats.applications.byStatus['applied']?.toString() ?? '0',
                Icons.people_outline,
                const Color(0xFF10B981),
                const Color(0xFFECFDF5),
                onTap: () {
                  // Navigate to applications (assuming index 1 or a specific page)
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'LỜI MỜI ĐÃ GỬI',
                stats.headhunting.invitationsSent.toString(),
                Icons.send_outlined,
                const Color(0xFF8B5CF6),
                const Color(0xFFF5F3FF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EmployerInvitationListPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'ỨNG VIÊN ĐÃ LƯU',
                stats.headhunting.savedCandidates.toString(),
                Icons.bookmark_outline,
                const Color(0xFFF59E0B),
                const Color(0xFFFFFBEB),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EmployerSavedCandidatesPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, Color bgColor, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrowthChart(TrendSummary trend, EmployerDashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tăng trưởng ứng tuyển',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  Text(
                    provider.currentGranularity == 'month' 
                      ? 'LƯỢNG ĐƠN NỘP TRONG THÁNG ${provider.currentMonth}' 
                      : 'LƯỢNG ĐƠN NỘP TRONG QUÝ ${provider.currentQuarter}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('7 ngày', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 2 != 0) return const SizedBox.shrink();
                        int index = value.toInt();
                        if (index < 0 || index >= trend.data.length) return const SizedBox.shrink();
                        final dateStr = trend.data[index].date;
                        final date = DateTime.parse(dateStr);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MM-dd').format(date),
                            style: TextStyle(color: Colors.grey[400], fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: trend.data.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.count.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF311B92),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF311B92).withOpacity(0.1),
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

  Widget _buildJobStatusChart(JobStatsSummary jobs) {
    final published = jobs.byStatus['published'] ?? 0;
    final draft = jobs.byStatus['draft'] ?? 0;
    final pending = jobs.byStatus['pending'] ?? 0;
    final closed = jobs.byStatus['closed'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trạng thái tin',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Text(
            'PHÂN BỔ TIN TUYỂN DỤNG',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: const Color(0xFF311B92),
                        value: published.toDouble(),
                        title: '',
                        radius: 12,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFF10B981),
                        value: pending.toDouble(),
                        title: '',
                        radius: 12,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFFF59E0B),
                        value: draft.toDouble(),
                        title: '',
                        radius: 12,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFFEF4444),
                        value: closed.toDouble(),
                        title: '',
                        radius: 12,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      jobs.total.toString(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Text('TỔNG TIN', style: TextStyle(fontSize: 8, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildChartLegend('Đã đăng', published, const Color(0xFF311B92)),
          _buildChartLegend('Chờ duyệt', pending, const Color(0xFF10B981)),
          _buildChartLegend('Nháp', draft, const Color(0xFFF59E0B)),
          _buildChartLegend('Đã đóng', closed, const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 10))),
          Text(value.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTopJobs(List<TopJobModel> topJobs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tin tiêu biểu',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'TIN CÓ ĐƠN NỘP CAO',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: () {
                  if (widget.onSwitchTab != null) {
                    widget.onSwitchTab!(1);
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Tất cả >', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...topJobs.take(5).toList().asMap().entries.map((e) => _buildTopJobItem(e.value, e.key + 1)),
        ],
      ),
    );
  }

  Widget _buildTopJobItem(TopJobModel job, int rank) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailedStatsPage(
              jobId: job.jobId,
              jobTitle: job.title,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$rank',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(Icons.people_outline, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text('${job.applicationCount} đơn - ', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                      const Text('ĐANG CHẠY', style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 16, color: Colors.grey[300]),
        ],
      ),
    ),
  );
}

  Widget _buildApplicationFunnel(ConversionRateSummary rates) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phễu ứng tuyển',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'TỈ LỆ CHUYỂN ĐỔI ỨNG VIÊN QUA CÁC GIAI ĐOẠN',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: _buildFunnelStep('Chọn lọc', 'Từ lúc nộp đơn', rates.appliedToShortlisted ?? 0, const Color(0xFF311B92))),
              Expanded(child: _buildFunnelStep('Phỏng vấn', 'Sau khi duyệt hồ sơ', rates.shortlistedToInterview ?? 0, const Color(0xFF10B981))),
              Expanded(child: _buildFunnelStep('Trúng tuyển', 'Sau khi phỏng vấn', rates.interviewToHired ?? 0, const Color(0xFF0D9488))),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 18),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tỉ lệ chuyển đổi giúp bạn nhận biết các "điểm nghẽn" trong quy trình. Hãy tối ưu nội dung tin tuyển dụng nếu tỉ lệ Shortlist thấp.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelStep(String title, String subtitle, double rate, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              '${rate.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: rate / 100,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
