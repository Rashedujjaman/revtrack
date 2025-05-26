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
