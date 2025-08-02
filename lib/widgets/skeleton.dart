import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

/// Skeleton loading widget for business card placeholder
/// 
/// Features:
/// - Shimmer animation effect during data loading
/// - Theme-aware colors with transparency
/// - Card layout matching actual BusinessCard widget structure
/// - Logo, header, stats, and action button placeholders
/// - Proper spacing and sizing to match real card dimensions
class BusinessCardSkeleton extends StatelessWidget {
  const BusinessCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Theme.of(context).colorScheme.surfaceDim.withValues(alpha: 0.3),
                Theme.of(context).colorScheme.surfaceDim.withValues(alpha: 0.6),
              ],
            ),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Logo and Actions
                Row(
                  children: [
                    // Business Logo Skeleton
                    Shimmer.fromColors(
                      baseColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.3),
                      highlightColor: Theme.of(context).colorScheme.secondary,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Business Name Skeleton
                    Expanded(
                      child: Shimmer.fromColors(
                        baseColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3),
                        highlightColor: Theme.of(context).colorScheme.secondary,
                        child: Container(
                          height: 24,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    // Menu Icon Skeleton
                    Shimmer.fromColors(
                      baseColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.3),
                      highlightColor: Theme.of(context).colorScheme.secondary,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Business Stats Row Skeleton
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildStatItemSkeleton(context)),
                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                      ),
                      Expanded(child: _buildStatItemSkeleton(context)),
                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                      ),
                      Expanded(child: _buildStatItemSkeleton(context)),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Action Button Skeleton
                Shimmer.fromColors(
                  baseColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.3),
                  highlightColor: Theme.of(context).colorScheme.secondary,
                  child: Container(
                    width: double.infinity,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItemSkeleton(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      highlightColor: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 12,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 10,
            width: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loading widget for transaction card placeholder
/// 
/// Features:
/// - Shimmer animation for smooth loading experience
/// - Theme-aware color scheme matching transaction cards
/// - Leading circular icon placeholder
/// - Multiple text placeholders for transaction details
/// - Trailing amount placeholder with proper alignment
class TransactionCardSkeleton extends StatelessWidget {
  const TransactionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color:
          Theme.of(context).colorScheme.inversePrimary.withValues(alpha: 0.5),
      child: ListTile(
        leading: Shimmer.fromColors(
          baseColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          highlightColor: Theme.of(context).colorScheme.secondary,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        title: Shimmer.fromColors(
          baseColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          highlightColor: Theme.of(context).colorScheme.secondary,
          child: Container(
            height: 16,
            width: 80,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              highlightColor: Theme.of(context).colorScheme.secondary,
              child: Container(
                height: 12,
                width: 100,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 2.0),
              ),
            ),
            Shimmer.fromColors(
              baseColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              highlightColor: Theme.of(context).colorScheme.secondary,
              child: Container(
                height: 12,
                width: 60,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 2.0),
              ),
            ),
          ],
        ),
        trailing: Shimmer.fromColors(
          baseColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          highlightColor: Theme.of(context).colorScheme.secondary,
          child: Container(
            height: 20,
            width: 50,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class CartesianChartSkeleton extends StatelessWidget {
  final double height;
  final double width;
  const CartesianChartSkeleton(
      {super.key, this.height = 250, this.width = double.infinity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Shimmer.fromColors(
          baseColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          highlightColor:
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                width: 120,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 16),
              ),
              Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomPaint(
                  painter: _CartesianChartSkeletonPainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartesianChartSkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw X and Y axes
    canvas.drawLine(Offset(40, size.height - 20),
        Offset(size.width - 10, size.height - 20), paint);
    canvas.drawLine(Offset(40, size.height - 20), const Offset(40, 10), paint);

    // Draw fake line chart
    final path = Path();
    path.moveTo(40, size.height - 40);
    path.lineTo(size.width * 0.3, size.height - 80);
    path.lineTo(size.width * 0.5, size.height - 60);
    path.lineTo(size.width * 0.7, size.height - 120);
    path.lineTo(size.width - 20, size.height - 50);
    canvas.drawPath(path, paint..color = Colors.grey[400]!);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PieChartSkeleton extends StatelessWidget {
  final double height;
  final double width;
  const PieChartSkeleton(
      {super.key, this.height = 250, this.width = double.infinity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Shimmer.fromColors(
          baseColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          highlightColor:
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                width: 120,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 16),
              ),
              Center(
                child: Container(
                  height: height,
                  width: height, // Make it a square for the pie
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CustomPaint(
                    painter: _PieChartSkeletonPainter(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PieChartSkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..color = Colors.grey[300]!;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 16;

    // Draw 4 segments as fake pie slices
    double startAngle = -1.57; // -90 degrees
    for (int i = 0; i < 4; i++) {
      paint.color = Colors.grey[300]!.withValues(alpha: 0.7 - i * 0.15);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        1.4, // ~80 degrees per slice
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BankAccountCardSkeleton extends StatelessWidget {
  const BankAccountCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  highlightColor: Theme.of(context).colorScheme.secondary,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  highlightColor: Theme.of(context).colorScheme.secondary,
                  child: Container(
                    height: 20,
                    width: 80,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  highlightColor: Theme.of(context).colorScheme.secondary,
                  child: Container(
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Account name
            Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              highlightColor: Theme.of(context).colorScheme.secondary,
              child: Container(
                height: 18,
                width: 150,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Bank name and account number
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  highlightColor: Theme.of(context).colorScheme.secondary,
                  child: Container(
                    height: 14,
                    width: 100,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  highlightColor: Theme.of(context).colorScheme.secondary,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  highlightColor: Theme.of(context).colorScheme.secondary,
                  child: Container(
                    height: 14,
                    width: 60,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Balance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      highlightColor: Theme.of(context).colorScheme.secondary,
                      child: Container(
                        height: 12,
                        width: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Shimmer.fromColors(
                      baseColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      highlightColor: Theme.of(context).colorScheme.secondary,
                      child: Container(
                        height: 20,
                        width: 120,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      highlightColor: Theme.of(context).colorScheme.secondary,
                      child: Container(
                        height: 12,
                        width: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Shimmer.fromColors(
                      baseColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      highlightColor: Theme.of(context).colorScheme.secondary,
                      child: Container(
                        height: 14,
                        width: 80,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
