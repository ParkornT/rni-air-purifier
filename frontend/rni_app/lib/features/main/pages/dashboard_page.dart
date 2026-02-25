import 'package:flutter/material.dart';
import 'package:rni_app/features/main/widgets/live_pm_chart.dart';
import 'package:rni_app/features/main/widgets/toggle_pm_chart_button.dart';

/*
Index 1: Dashboard Page
  Contain Graphs, Charts and device controls
*/
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: const Center(child: Column(children: [LivePMChart()])),
      floatingActionButton: const TogglePMChartButton(),
    );
  }
}
