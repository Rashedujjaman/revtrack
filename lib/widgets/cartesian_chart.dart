import 'package:flutter/material.dart';
import 'package:revtrack/models/chart_data_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Cartesian line chart widget for revenue data visualization
/// 
/// Features:
/// - Syncfusion charts integration for smooth rendering
/// - Automatic keep-alive for performance optimization
/// - Lifecycle-aware widget disposal and cleanup
/// - Tooltip behavior for interactive data exploration
/// - Rotated category axis labels for better readability
/// - Data point markers and labels for clarity
/// - Empty state handling with graceful degradation
class CartesianChart extends StatefulWidget {
  final List<ChartData> data;
  final String title;
  
  /// Creates a cartesian chart with revenue data
  /// 
  /// Parameters:
  /// - [data]: List of chart data points with key-value pairs
  /// - [title]: Chart title displayed at the top
  const CartesianChart({super.key, required this.data, required this.title});

  @override
  State<CartesianChart> createState() => _CartesianChartState();
}

/// Stateful implementation with lifecycle management and performance optimization
class _CartesianChartState extends State<CartesianChart>
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

    // Early return for invalid states to prevent rendering errors
    if (_isDisposed || !mounted || widget.data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      key: ValueKey('cartesian_chart_${widget.title}'),
      child: SfCartesianChart(
        title: ChartTitle(text: widget.title),
        legend: const Legend(isVisible: true),
        primaryXAxis: const CategoryAxis(
          labelRotation: -90, // Rotate labels for better readability
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
