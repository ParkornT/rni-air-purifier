import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:rni_app/features/main/providers/live_chart_provider.dart';

/*
  Show live value of PM2.5 readings as graph, including average
  Listen to LiveChartProvider
*/
class LivePMChart extends StatefulWidget {
  const LivePMChart({super.key});

  @override
  State<LivePMChart> createState() => _LivePMChartState();
}

class _LivePMChartState extends State<LivePMChart> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChartProvider>(
      builder: (context, chartProvider, _) {
        final graphData = chartProvider.graphData; //Points data
        final maxY = (chartProvider.max <= 0 ? 1 : chartProvider.max * 1.1)
            .ceilToDouble(); //Dynamic chart height
        final average = chartProvider.average;
        final size = chartProvider.size;
        final chartOn = chartProvider.chartOn;

        return SizedBox(
          height: 280,
          width: 800,
          child: Row(
            children: [
              const Gap(15),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Status: ',
                            style: TextStyle(fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            chartOn ? "ON" : "OFF",
                            style: TextStyle(
                              color: chartOn ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildChart(
                        graphData: graphData,
                        maxY: maxY,
                        size: size,
                        average: average,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChart({
    required List<FlSpot> graphData,
    required double maxY,
    required double size,
    required double average,
  }) {
    // If no data yet, show placeholder (Not ready to render)
    if (graphData.isEmpty) {
      return Center(
        child: Text(
          'Waiting for data...',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    // If only one data point (Not ready to render)
    if (graphData.length < 2) {
      return Center(
        child: Text(
          'Collecting data... (${graphData.length}/2)',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    // Chart is ready to render
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                // Y AXIS
                leftTitles: AxisTitles(
                  axisNameWidget: Text('PM2.5 (µg/m³)'),
                  axisNameSize: 30,
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: maxY / 5,
                    reservedSize: 40,
                  ),
                ),

                // X AXIS
                bottomTitles: AxisTitles(
                  sideTitleAlignment: SideTitleAlignment.outside,
                  axisNameWidget: Text(
                    'Time (seconds)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  axisNameSize: 30,
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 30,
                  ),
                ),
              ),

              minX: -size,
              maxX: 3,
              minY: 0,
              maxY: maxY,

              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: maxY / 5,
                verticalInterval: 1,
              ),

              lineBarsData: [
                LineChartBarData(
                  color: Colors.green,
                  spots: graphData,
                  barWidth: 2,
                  isStrokeCapRound: true,
                ),
              ],
            ),
          ),
        ),

        Text(
          'Average PM2.5: ${average.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 22),
        ),
      ],
    );
  }
}
