import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood_log.dart';

class MoodChart extends StatelessWidget {
  final List<MoodLog> logs; // expected recent 7 logs ordered ascending by timestamp

  const MoodChart({super.key, required this.logs});

  List<FlSpot> _spots() {
    final spots = <FlSpot>[];
    for (var i = 0; i < logs.length; i++) {
      spots.add(FlSpot(i.toDouble(), logs[i].mood.toDouble()));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const SizedBox(height: 120, child: Center(child: Text('No mood data yet')));
    }
    final spots = _spots();
    return SizedBox(
      height: 180,
      child: LineChart(LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1)),
        ),
        minY: 1,
        maxY: 5,
        lineBarsData: [LineChartBarData(spots: spots, isCurved: true, dotData: FlDotData(show: true))],
      )),
    );
  }
}