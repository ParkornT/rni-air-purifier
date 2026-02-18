import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:rni_app/features/main/providers/live_chart_provider.dart';
import 'package:rni_app/features/main/widgets/live_pm_chart.dart';
import 'package:rni_app/features/main/widgets/toggle_pm_chart_button.dart';

/*
Index 1: Main Page
  Contain Graphs, Charts and device controls
*/
class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  final String title;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(letterSpacing: -1)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [LivePMChart()],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            //TODO: Implement bluetooth listener instead
            onPressed: () {
              context.read<ChartProvider>().addData(Random().nextDouble());
            },
            child: Icon(Icons.add),
          ),
          const Gap(15),
          TogglePMChartButton(),
        ],
      ),
    );
  }
}
