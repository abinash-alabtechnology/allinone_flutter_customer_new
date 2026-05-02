import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HourlyWeatherCard extends StatelessWidget {
  final HourlyTemperature data;

  const HourlyWeatherCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
            ),
          ),
          child: Column(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                formatToAmPm(data.time),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
             resolveWeatherIcon(
                  time: data.time,
                  temperature: data.temperature,
                ),
              Text(
                "${data.temperature.round()}°",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
String formatToAmPm(String time24) {
  final parts = time24.split(':');
  final hour24 = int.parse(parts[0]);

  if (hour24 == 0) return '12 AM';
  if (hour24 == 12) return '12 PM';

  final hour12 = hour24 % 12;
  return hour24 < 12
      ? '$hour12 AM'
      : '$hour12 PM';
}


class HourlyWeatherView extends StatefulWidget {
  final List<HourlyTemperature> hourlyData;

  const HourlyWeatherView({super.key, required this.hourlyData});

  @override
  State<HourlyWeatherView> createState() => _HourlyWeatherViewState();
}

class _HourlyWeatherViewState extends State<HourlyWeatherView> {
  late final ScrollController _scrollController;

  static const double itemWidth = 92;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentHour();
    });
  }

  void _scrollToCurrentHour() {
    if (widget.hourlyData.isEmpty) return;

    final nowHour =
    DateTime.now().hour.toString().padLeft(2, '0');

    final index = widget.hourlyData.indexWhere(
          (e) => e.time.startsWith(nowHour),
    );

    if (index == -1) return;

    final offset = index * itemWidth;

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    debugPrint("sjnsj");
    for (final item in widget.hourlyData) {
      debugPrint(
        'Time: ${item.time}, Temp: ${item.temperature}',
      );
    }

    return widget.hourlyData.isNotEmpty?Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        height: 115,
        width: Get.width,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
            color: Colors.blue.shade200,
            borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade50)
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.hourlyData.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return HourlyWeatherCard(data: widget.hourlyData[index]);
            },
          ),
        ),
      ),
    ):Container();
  }
}

Widget resolveWeatherIcon({
  required String time,
  required double temperature,
  double size = 22,
}) {
  final hour = int.parse(time.split(':')[0]);
  final bool isDay = hour >= 6 && hour < 19;
  final bool isCloudy = temperature < 27;


  if (isCloudy && isDay) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Icon(
          Icons.wb_sunny_rounded,
          size: size,
          color: Colors.yellowAccent,
        ),
        Positioned(
          bottom: -4,
          right: 4,
          child:  Icon(
              Icons.cloud_rounded,
              size: size,
              color: Colors.white,
            ),
          ),
      ],
    );
  }

  if (isCloudy && !isDay) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Icon(
          Icons.nights_stay_rounded,
          size: size,
          color: Colors.black87,
        ),
        Positioned(
          bottom: -4,
          right: 10,
          child:  Icon(
            Icons.cloud_rounded,
            size: size,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  if (!isCloudy && isDay) {
    return Icon(
      Icons.wb_sunny_rounded,
      size: size,
      color: Colors.yellowAccent,
    );
  }

  return Icon(
    Icons.nights_stay_rounded,
    size: size,
    color: Colors.black87,
  );
}




class HourlyTemperature {
  final String time;
  final double temperature;

  HourlyTemperature({
    required this.time,
    required this.temperature,
  });

  factory HourlyTemperature.fromJson(Map<String, dynamic> json) {
    return HourlyTemperature(
      time: json['time'],
      temperature: (json['temperature'] as num).toDouble(),
    );
  }
}
