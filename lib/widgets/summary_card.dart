import 'package:flutter/material.dart';
import 'package:animated_number/animated_number.dart';
import 'package:shimmer/shimmer.dart';

/// Summary card widget for displaying key metrics with animations
/// 
/// Features:
/// - Animated number transitions for value changes
/// - Gradient background with customizable colors
/// - Loading state with shimmer animation
/// - Optional tap callback for navigation
/// - Icon and subtitle support for context
/// - Material elevation and theming integration
class SummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final bool isLoading;
  final String? subtitle;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.isLoading = false,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        shadowColor: color.withValues(alpha: 0.3),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundColor,
                backgroundColor.withValues(alpha: 0.8),
              ],
            ),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with icon and title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Value display
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '৳ ',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                        ),
                        if (isLoading)
                          Shimmer.fromColors(
                            baseColor: color.withValues(alpha: 0.3),
                            highlightColor: color.withValues(alpha: 0.6),
                            child: Container(
                              width: 80,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          )
                        else
                          AnimatedNumber(
                            startValue: 0,
                            endValue: value,
                            duration: const Duration(seconds: 2),
                            isFloatingPoint: true,
                            decimalPoint: 2,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Multi-item summary card widget for displaying grouped statistics
/// 
/// Features:
/// - Multiple summary items in a single card
/// - Consistent theming with Material Design 3
/// - Individual item styling with icons and colors
/// - Loading state with shimmer animations
/// - Card-level tap interaction
/// - Gradient background with elevation shadow
class MultiSummaryCard extends StatelessWidget {
  final String title;
  final List<SummaryItem> items;
  final bool isLoading;
  final VoidCallback? onTap;

  const MultiSummaryCard({
    super.key,
    required this.title,
    required this.items,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        shadowColor: Theme.of(context).shadowColor.withValues(alpha: 0.3),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              ],
            ),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),

                  const SizedBox(height: 20),

                  // Items
                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildSummaryItem(context, item),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds individual summary item with icon, label and animated value
  /// 
  /// Parameters:
  /// - [context]: Build context for theming
  /// - [item]: Summary item data with label, value, icon and color
  /// 
  /// Returns: Container with formatted summary item display
  Widget _buildSummaryItem(BuildContext context, SummaryItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '৳ ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: item.color,
                          ),
                    ),
                    if (isLoading)
                      Shimmer.fromColors(
                        baseColor: item.color.withValues(alpha: 0.3),
                        highlightColor: item.color.withValues(alpha: 0.6),
                        child: Container(
                          width: 60,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      )
                    else
                      AnimatedNumber(
                        startValue: 0,
                        endValue: item.value,
                        duration: const Duration(seconds: 2),
                        isFloatingPoint: true,
                        decimalPoint: 2,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: item.color,
                                ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Data model for individual summary items in MultiSummaryCard
/// 
/// Properties:
/// - [label]: Display text for the item
/// - [value]: Numeric value to display with animation
/// - [icon]: Icon to show alongside the label
/// - [color]: Theme color for icon and value text
class SummaryItem {
  final String label;
  final double value;
  final IconData icon;
  final Color color;

  /// Creates a summary item with required display properties
  /// 
  /// All parameters are required for proper item display:
  /// - [label]: Text description of the metric
  /// - [value]: Numeric value with 2 decimal places
  /// - [icon]: Material icon for visual context
  /// - [color]: Color theme for styling consistency
  const SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}
