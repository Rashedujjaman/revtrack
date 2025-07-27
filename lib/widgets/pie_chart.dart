// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:revtrack/models/chart_data_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PieChart extends StatefulWidget {
  final List<ChartData> data;
  final String title;
  final Color? borderColor;

  const PieChart(
      {super.key, required this.data, required this.title, this.borderColor});

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  bool _isDisposed = false;
  TooltipBehavior? _tooltipBehavior;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _tooltipBehavior = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && mounted) {
      // Handle app lifecycle changes
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_isDisposed || !mounted || widget.data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      key: ValueKey('pie_chart_${widget.title}'),
      child: SfCircularChart(
        title: ChartTitle(text: widget.title),
        borderColor: widget.borderColor ?? Colors.transparent,
        borderWidth: 1,
        tooltipBehavior: _tooltipBehavior,
        legend: const Legend(
          isVisible: true,
          overflowMode: LegendItemOverflowMode.wrap,
          position: LegendPosition.bottom,
          // alignment: ChartAlignment.far,
        ),
        series: <PieSeries<ChartData, String>>[
          PieSeries<ChartData, String>(
            dataSource: widget.data,
            xValueMapper: (ChartData data, _) => data.key,
            yValueMapper: (ChartData data, _) => data.value,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              connectorLineSettings: ConnectorLineSettings(
                type: ConnectorType.curve,
                length: '15%',
              ),
            ),
            explode: true,
            // pointColorMapper: (ChartData data, _) {
            //   // You can customize the color mapping here
            //   int total = data.value.toInt();
            //   if (total < 0) {
            //     return Colors.red; // Negative values in red
            //   }
            //   // Use the index to assign unique colors for each company
            //   return Colors
            //       .primaries[data.key.hashCode % Colors.primaries.length];
            // },
          ),
        ],
      ),
    );
  }
}
