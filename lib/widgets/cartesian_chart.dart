import 'package:flutter/material.dart';
import 'package:revtrack/models/chart_data_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CartesianChart extends StatefulWidget {
  final List<ChartData> data;
  final String title;
  const CartesianChart({super.key, required this.data, required this.title});

  @override
  State<CartesianChart> createState() => _CartesianChartState();
}

class _CartesianChartState extends State<CartesianChart>
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
      key: ValueKey('cartesian_chart_${widget.title}'),
      child: SfCartesianChart(
        title: ChartTitle(text: widget.title),
        legend: const Legend(isVisible: true),
        primaryXAxis: const CategoryAxis(
          labelRotation: -90,
        ),
        tooltipBehavior: _tooltipBehavior,
        series: <CartesianSeries<ChartData, String>>[
          LineSeries<ChartData, String>(
            dataSource: widget.data,
            xValueMapper: (ChartData sales, _) => sales.key,
            yValueMapper: (ChartData sales, _) => sales.value,
            name: 'Revenue',
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            markerSettings: const MarkerSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}
