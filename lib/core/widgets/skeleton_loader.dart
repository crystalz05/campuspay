import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final BoxShape shape;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    final containerColor = isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: shape == BoxShape.circle ? null : (borderRadius ?? BorderRadius.circular(8)),
          shape: shape,
        ),
      ),
    );
  }
}

class TransactionSkeletonList extends StatelessWidget {
  final int itemCount;

  const TransactionSkeletonList({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        indent: 80,
        color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
      ),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: [
              const SkeletonBox(
                width: 44,
                height: 44,
                shape: BoxShape.circle,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(width: 140, height: 16),
                    const SizedBox(height: 8),
                    const SkeletonBox(width: 80, height: 12),
                  ],
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SkeletonBox(width: 70, height: 16),
                  SizedBox(height: 8),
                  SkeletonBox(width: 50, height: 14, borderRadius: BorderRadius.all(Radius.circular(4))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class NotificationSkeletonList extends StatelessWidget {
  final int itemCount;

  const NotificationSkeletonList({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
      ),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBox(
                width: 48,
                height: 48,
                shape: BoxShape.circle,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(width: double.infinity, height: 14),
                    const SizedBox(height: 8),
                    const SkeletonBox(width: 180, height: 14),
                    const SizedBox(height: 12),
                    const SkeletonBox(width: 60, height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 80, height: 14),
                  const SizedBox(height: 8),
                  const SkeletonBox(width: 150, height: 24),
                ],
              ),
              const SkeletonBox(width: 48, height: 48, shape: BoxShape.circle),
            ],
          ),
          const SizedBox(height: 24),
          const SkeletonBox(
            width: double.infinity,
            height: 180,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          const SizedBox(height: 32),
          const SkeletonBox(width: 120, height: 20),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) => const Column(
              children: [
                SkeletonBox(width: 56, height: 56, shape: BoxShape.circle),
                SizedBox(height: 8),
                SkeletonBox(width: 50, height: 12),
              ],
            )),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SkeletonBox(width: 160, height: 20),
              const SkeletonBox(width: 60, height: 16),
            ],
          ),
          const SizedBox(height: 16),
          const TransactionSkeletonList(itemCount: 4),
        ],
      ),
    );
  }
}
