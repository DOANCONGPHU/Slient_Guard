import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile/core/utils/app_colors.dart';
import 'package:mobile/features/home/domain/entities/weather_info.dart';

class _SafetyWeatherDisplayData {
  const _SafetyWeatherDisplayData({
    required this.statusTitle,
    required this.statusMessage,
    required this.cameraLabel,
    required this.alertLabel,
    required this.weatherLabel,
    required this.hasCameras,
  });

  final String statusTitle;
  final String statusMessage;
  final String cameraLabel;
  final String alertLabel;
  final String weatherLabel;
  final bool hasCameras;
}

class SafetyWeatherCard extends StatefulWidget {
  const SafetyWeatherCard({
    super.key,
    required this.weather,
    required this.totalCameras,
    required this.onlineCameras,
  });

  final WeatherInfo? weather;
  final int totalCameras;
  final int onlineCameras;

  @override
  State<SafetyWeatherCard> createState() => _SafetyWeatherCardState();
}

class _SafetyWeatherCardState extends State<SafetyWeatherCard>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  late final AnimationController _floatController;
  late final Animation<Offset> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    final entranceCurve = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(entranceCurve);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(entranceCurve);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _floatAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, -0.04),
        ).chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, -0.04),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
    ]).animate(_floatController);

    _entranceController.forward();
    _floatController.repeat();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  _SafetyWeatherDisplayData get _displayData {
    final hasCameras = widget.totalCameras > 0;
    final weatherLabel = widget.weather != null
        ? '${widget.weather!.temperature.toStringAsFixed(0)}°C · Hà Nội'
        : 'Không có dữ liệu · Hà Nội';

    if (!hasCameras) {
      return _SafetyWeatherDisplayData(
        statusTitle: 'Chưa bắt đầu giám sát',
        statusMessage: 'Thêm camera để bảo vệ người thân tốt hơn.',
        cameraLabel: '0 thiết bị',
        alertLabel: 'Chưa có dữ liệu',
        weatherLabel: weatherLabel,
        hasCameras: false,
      );
    } else {
      return _SafetyWeatherDisplayData(
        statusTitle: 'Nhà đang được giám sát',
        statusMessage: 'Các camera đang theo dõi an toàn cho người thân.',
        cameraLabel: '${widget.onlineCameras}/${widget.totalCameras} camera',
        alertLabel: 'Sẵn sàng cảnh báo',
        weatherLabel: weatherLabel,
        hasCameras: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final display = _displayData;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      theme.colorScheme.surfaceContainerHighest,
                      theme.colorScheme.surfaceContainer,
                    ]
                  : [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              // Decorative background blobs
              Positioned(
                right: -40,
                top: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.03),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TRẠNG THÁI AN TOÀN',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                display.statusTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                display.statusMessage,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        _AnimatedSafetyIcon(
                          floatAnimation: _floatAnimation,
                          isProtected: display.hasCameras,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: [
                          _SafetyMetricChip(
                            icon: Iconsax.camera,
                            label: display.cameraLabel,
                            isActive: display.hasCameras,
                          ),
                          const SizedBox(width: 8),
                          _SafetyMetricChip(
                            icon: display.hasCameras
                                ? Iconsax.shield_tick
                                : Iconsax.shield_cross,
                            label: display.alertLabel,
                            isActive: display.hasCameras,
                          ),
                          const SizedBox(width: 8),
                          _SafetyMetricChip(
                            icon: Iconsax.cloud_sunny,
                            label: display.weatherLabel,
                            isActive: true,
                          ),
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
    );
  }
}

class _AnimatedSafetyIcon extends StatelessWidget {
  const _AnimatedSafetyIcon({
    required this.floatAnimation,
    required this.isProtected,
  });

  final Animation<Offset> floatAnimation;
  final bool isProtected;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: floatAnimation,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              isProtected ? Icons.shield_rounded : Icons.gpp_maybe_rounded,
              color: isProtected ? AppColors.safe : AppColors.primary,
              size: 28,
            ),
          ),
          if (isProtected)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.safe,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SafetyMetricChip extends StatelessWidget {
  const _SafetyMetricChip({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
