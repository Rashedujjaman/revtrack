import 'package:flutter/material.dart';
import 'package:revtrack/models/chart_data_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Circular pie chart widget for data distribution visualization
/// 
/// Features:
/// - Syncfusion circular chart integration
/// - Automatic keep-alive for performance optimization
/// - Lifecycle-aware widget management
/// - Interactive tooltips and exploded segments
/// - Bottom legend with overflow wrapping
/// - Data label connectors with curved lines
/// - Custom border color support
/// - Empty state handling with graceful degradation
class PieChart extends StatefulWidget {
  final List<ChartData> data;
  final String title;
  final Color? borderColor;

  /// Creates a pie chart for data distribution display
  /// 
  /// Parameters:
  /// - [data]: List of chart data points for pie segments
  /// - [title]: Chart title displayed at the top
  /// - [borderColor]: Optional border color for the chart
  const PieChart({
    super.key,
    required this.data,
    required this.title,
    this.borderColor,
  });

  @override
  State<PieChart> createState() => _PieChartState();
}

/// Stateful implementation with lifecycle management and performance optimization
class _PieChartState extends State<PieChart>
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
            explode: true, // Creates visual separation between segments
          ),
        ],
      ),
    );
  }
}
