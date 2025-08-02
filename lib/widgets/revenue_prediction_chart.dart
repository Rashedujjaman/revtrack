import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:revtrack/models/chart_data_model.dart';

/// Revenue prediction chart widget combining historical and predicted data
/// 
/// Features:
/// - Dual line series for historical vs predicted revenue
/// - Syncfusion charts integration with smooth rendering
/// - Automatic keep-alive for performance optimization
/// - Lifecycle-aware widget management for memory efficiency
/// - Interactive tooltips for data exploration
/// - Differentiated styling (solid vs dashed lines)
/// - Rotated axis labels for better readability
/// - Currency formatting with Bangladeshi Taka symbol
/// - Empty state handling with graceful degradation
class RevenuePredictionChart extends StatefulWidget {
  final String title;
  final List<ChartData> historicalData;
  final List<ChartData> predictions;

  /// Creates a revenue prediction chart with historical and forecasted data
  /// 
  /// Parameters:
  /// - [title]: Chart title displayed at the top
  /// - [historicalData]: List of actual historical revenue data points
  /// - [predictions]: List of predicted future revenue data points
  const RevenuePredictionChart({
    Key? key,
    required this.title,
    required this.historicalData,
    required this.predictions,
  }) : super(key: key);

  @override
  State<RevenuePredictionChart> createState() => _RevenuePredictionChartState();
}

/// Stateful implementation with lifecycle management and performance optimization
class _RevenuePredictionChartState extends State<RevenuePredictionChart>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  bool _isDisposed = false;
  TooltipBehavior? _tooltipBehavior;

  /// Keeps widget alive during parent rebuilds for better performance
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

  /// Handles app lifecycle changes for memory management
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && mounted) {
      // Chart can be paused to save resources when app is backgrounded
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_isDisposed || !mounted) {
      return const SizedBox.shrink();
    }

    final historicalData = widget.historicalData;
    final predictions = widget.predictions;

    if (historicalData.isEmpty && predictions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      key: ValueKey('prediction_chart_${widget.title}'),
      child: SfCartesianChart(
        title: ChartTitle(text: widget.title),
        legend: const Legend(isVisible: true),
        primaryXAxis: const CategoryAxis(
          labelRotation: -45,
        ),
        primaryYAxis: const NumericAxis(
          title: AxisTitle(text: 'Amount (৳) '),
        ),
        tooltipBehavior: _tooltipBehavior,
        series: <CartesianSeries>[
          LineSeries<ChartData, String>(
            name: 'Historical Revenue',
            dataSource: historicalData,
            xValueMapper: (ChartData data, _) => data.key,
            yValueMapper: (ChartData data, _) => data.value,
            markerSettings: const MarkerSettings(isVisible: true),
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            color: Colors.blue,
          ),
          LineSeries<ChartData, String>(
            name: 'Predicted Revenue',
            dataSource: predictions,
            xValueMapper: (ChartData data, _) => data.key,
            yValueMapper: (ChartData data, _) => data.value,
            markerSettings: const MarkerSettings(isVisible: true),
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            color: Colors.orange,
            dashArray: const [5, 5],
          ),
        ],
      ),
    );
  }
}
