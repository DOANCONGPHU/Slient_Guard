import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile/core/utils/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/features/reports/domain/entities/event_history_item.dart';
import 'package:mobile/features/reports/presentation/cubit/event_history_cubit.dart';
import 'package:mobile/features/reports/presentation/widgets/ai_daily_summary_card.dart';
import 'package:mobile/features/reports/presentation/widgets/recent_events_section.dart';
import 'package:mobile/features/reports/presentation/widgets/report_metric_grid.dart';
import 'package:mobile/features/reports/presentation/widgets/report_summary_card.dart';
import 'package:mobile/features/reports/presentation/widgets/reports_header.dart';
import 'package:mobile/features/reports/presentation/widgets/weekly_trend_chart_card.dart';
import 'package:mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:mobile/features/home/presentation/bloc/home_state.dart';
import 'package:mobile/features/session/domain/repositories/session_repository.dart';
import 'package:mobile/features/reports/presentation/cubit/event_history_state.dart';
import 'package:mobile/injection_container.dart';

/// Reports tab — top-level composition only.
/// All API calls and data mapping happen below in cubit / datasource / mapper.
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key, this.isActive = false});

  final bool isActive;

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late final EventHistoryCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<EventHistoryCubit>();
    if (widget.isActive) {
      _tryLoad();
    }
  }

  @override
  void didUpdateWidget(ReportsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _tryLoad();
    }
  }

  void _tryLoad() {
    final householdId = sl<SessionRepository>().currentHouseholdId;
    if (householdId != null && householdId.isNotEmpty) {
      final state = _cubit.state;
      if (state is EventHistoryInitial ||
          state is EventHistoryLoading ||
          state is EventHistoryError) {
        _cubit.loadInitial();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<HomeBloc, HomeState>(
        listenWhen: (previous, current) =>
            current is HomeLoaded && previous is! HomeLoaded,
        listener: (context, state) {
          if (widget.isActive) {
            _tryLoad();
          }
        },
        child: const _ReportsPageBody(),
      ),
    );
  }
}

class _ReportsPageBody extends StatelessWidget {
  const _ReportsPageBody();

  void _showComingSoonSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onEventTap(BuildContext context, EventHistoryItem item) {
    // TODO: Navigate to event detail screen when it exists.
    // Pass item.eventId to the detail route.
    _showComingSoonSnackBar(context, 'Chi tiết sự kiện sẽ được kết nối sau.');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              24,
              AppSpacing.pagePadding,
              20,
            ),
            sliver: SliverList.list(
              children: [
                ReportsHeader(
                  onFilterTap: () => _showComingSoonSnackBar(
                    context,
                    'Bộ lọc thời gian sẽ được kết nối sau.',
                  ),
                ),
                const SizedBox(height: 24),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      Expanded(
                        child: ReportSummaryCard(
                          title: 'Hôm nay',
                          mainValue: '0',
                          unitLabel: 'cảnh báo khẩn cấp',
                          subtitle: '2 sự kiện đã ghi nhận',
                          icon: Iconsax.shield_tick,
                          accentColor: AppColors.safe,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ReportSummaryCard(
                          title: 'Phản hồi',
                          mainValue: '42s',
                          unitLabel: 'trung bình',
                          subtitle: 'Nhanh hơn 18s so với hôm qua',
                          icon: Iconsax.timer_1,
                          accentColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const WeeklyTrendChartCard(),
                const SizedBox(height: 32),
                const AiDailySummaryCard(),
                const SizedBox(height: 32),
                const ReportMetricGrid(),
                const SizedBox(height: 32),
                RecentEventsSection(
                  onEventTap: (item) => _onEventTap(context, item),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
