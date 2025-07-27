import 'package:flutter/material.dart';

/// A safe container for charts that prevents disposed RenderObject mutations
/// This addresses issues that can occur in newer Flutter versions when
/// charts are disposed during navigation
class SafeChartContainer extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Widget? loadingWidget;

  const SafeChartContainer({
    super.key,
    required this.child,
    this.isLoading = false,
    this.loadingWidget,
  });

  @override
  State<SafeChartContainer> createState() => _SafeChartContainerState();
}

class _SafeChartContainerState extends State<SafeChartContainer>
    with AutomaticKeepAliveClientMixin {
  bool _isDisposed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    if (widget.isLoading) {
      return widget.loadingWidget ??
          const Center(
            child: CircularProgressIndicator(),
          );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: widget.child,
    );
  }
}
