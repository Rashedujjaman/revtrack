import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class BusinessCardSkeleton extends StatelessWidget {
  const BusinessCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color:
          Theme.of(context).colorScheme.inversePrimary.withValues(alpha: 0.3),
      child: ListTile(
        leading: Shimmer.fromColors(
          baseColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          highlightColor: Theme.of(context).colorScheme.secondary,
          child: Container(
            width: 50,
            height: 50,
            color: Colors.white,
          ),
        ),
        title: Shimmer.fromColors(
          baseColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          highlightColor: Theme.of(context).colorScheme.secondary,
          child: Container(
            height: 16,
            width: 120,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
      ),
    );
  }
}

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
      startAngle += 1.6;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
