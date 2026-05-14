import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/employer_dashboard_provider.dart';
import '../../data/models/job_detailed_stats_model.dart';
import '../../data/models/employer_dashboard_stats_model.dart';

class JobDetailedStatsPage extends StatefulWidget {
  final int jobId;
  final String jobTitle;

  const JobDetailedStatsPage({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<JobDetailedStatsPage> createState() => _JobDetailedStatsPageState();
}

class _JobDetailedStatsPageState extends State<JobDetailedStatsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployerDashboardProvider>().fetchJobDetailedStats(widget.jobId);
    });
  }

  @override
  void dispose() {
    // Clear job stats when leaving the page to avoid showing old data next time
    context.read<EmployerDashboardProvider>().clearJobStats();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.jobTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Consumer<EmployerDashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.jobStats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.jobStats;
          if (stats == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage ?? 'Không thể tải dữ liệu'),
                  ElevatedButton(
                    onPressed: () => provider.fetchJobDetailedStats(widget.jobId),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterBar(context, provider),
                const SizedBox(height: 16),
                _buildJobInfoCard(stats.job),
                const SizedBox(height: 24),
                _buildApplicationSummary(stats.applications),
                const SizedBox(height: 24),
                _buildInvitationSummary(stats.invitations),
                const SizedBox(height: 24),
                _buildConversionChart(stats.applications.conversionRate),
                const SizedBox(height: 24),
                _buildTrendChart(stats.applications.trend),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobInfoCard(JobInfo job) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: job.status == 'published' ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  job.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: job.status == 'published' ? const Color(0xFF10B981) : Colors.grey,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Hạn: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(job.deadline))}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            job.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text('Số lượng cần tuyển: ${job.slots}', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationSummary(ApplicationStatsSummary apps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Đơn ứng tuyển', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildSmallStatCard('Tổng đơn', apps.total.toString(), const Color(0xFF3B82F6)),
            _buildSmallStatCard('Trúng tuyển', (apps.byStatus['hired'] ?? 0).toString(), const Color(0xFF10B981)),
            _buildSmallStatCard('Phỏng vấn', (apps.byStatus['interview'] ?? 0).toString(), const Color(0xFF8B5CF6)),
            _buildSmallStatCard('Từ chối', (apps.byStatus['rejected'] ?? 0).toString(), const Color(0xFFEF4444)),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInvitationSummary(InvitationStatsSummary invs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.send_outlined, color: Color(0xFF8B5CF6), size: 20),
              SizedBox(width: 8),
              Text('Hiệu quả mời ứng tuyển', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF5B21B6))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInvStat('Đã gửi', invs.sent.toString()),
              _buildInvStat('Chấp nhận', invs.accepted.toString()),
              _buildInvStat('Đang chờ', invs.pending.toString()),
              _buildInvStat('Từ chối', invs.declined.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5B21B6))),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF7C3AED))),
      ],
    );
  }

  Widget _buildConversionChart(ConversionRateSummary rates) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tỷ lệ chuyển đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildRateBar('Nộp đơn -> Shortlist', rates.appliedToShortlisted ?? 0, const Color(0xFF3B82F6)),
          const SizedBox(height: 16),
          _buildRateBar('Shortlist -> Phỏng vấn', rates.shortlistedToInterview ?? 0, const Color(0xFF8B5CF6)),
          const SizedBox(height: 16),
          _buildRateBar('Phỏng vấn -> Trúng tuyển', rates.interviewToHired ?? 0, const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildRateBar(String label, double rate, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text('${rate.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: rate / 100,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildTrendChart(TrendSummary trend) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Xu hướng nộp đơn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Text('DỮ LIỆU THEO THỜI GIAN ĐÃ CHỌN', style: TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 30),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= trend.data.length) return const SizedBox.shrink();
                        final dateStr = trend.data[index].date;
                        try {
                           final date = DateTime.parse(dateStr);
                           return Text(
                             DateFormat('dd').format(date),
                             style: const TextStyle(fontSize: 10, color: Colors.grey),
                           );
                        } catch (e) {
                           return Text(
                             dateStr.substring(dateStr.length - 2),
                             style: const TextStyle(fontSize: 10, color: Colors.grey),
                           );
                        }
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: trend.data.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.count.toDouble(),
                        color: const Color(0xFF3B82F6),
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, EmployerDashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF311B92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text('Thời gian thống kê', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              provider.fetchJobDetailedStats(widget.jobId);
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
        provider.fetchJobDetailedStats(widget.jobId);
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
                provider.fetchJobDetailedStats(widget.jobId);
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
                provider.fetchJobDetailedStats(widget.jobId);
              }
            },
          ),
        ),
      );
    }
  }
}
