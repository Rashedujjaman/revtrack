import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:revtrack/models/business_model.dart';
import 'package:intl/intl.dart';

class BusinessCard extends StatelessWidget {
  final Business business;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BusinessCard({
    super.key,
    required this.business,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final reveneue = (business.incomes ?? 0.0) - (business.expenses ?? 0.0);
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
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Logo and Actions
                  Row(
                    children: [
                      // Business Logo
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Theme.of(context).colorScheme.primaryContainer,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .shadowColor
                                  .withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: business.logoUrl != null &&
                                  business.logoUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: business.logoUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    child: Icon(
                                      Icons.business,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 30,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    child: Icon(
                                      Icons.business,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 30,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  child: Icon(
                                    Icons.business,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 30,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Business Name and Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              business.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // const SizedBox(height: 4),
                            // Container(
                            //   padding: const EdgeInsets.symmetric(
                            //       horizontal: 8, vertical: 0),
                            //   decoration: BoxDecoration(
                            //     color: Theme.of(context)
                            //         .colorScheme
                            //         .primaryContainer
                            //         .withValues(alpha: 0.5),
                            //     borderRadius: BorderRadius.circular(8),
                            //   ),
                            //   child: Text(
                            //     'B.ID: ${business.id.substring(0, 10)}...',
                            //     style: Theme.of(context)
                            //         .textTheme
                            //         .bodySmall
                            //         ?.copyWith(
                            //           color: Theme.of(context)
                            //               .colorScheme
                            //               .onPrimaryContainer,
                            //         ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),

                      // Action Menu
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                const Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete,
                                    color: Theme.of(context).colorScheme.error),
                                const SizedBox(width: 8),
                                const Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit?.call();
                              break;
                            case 'delete':
                              onDelete?.call();
                              break;
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Business Stats Row
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
                        Expanded(
                          child: _buildStatItem(
                            context,
                            reveneue >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            'Revenue',
                            NumberFormat.currency(symbol: '৳').format(reveneue.abs()),
                            reveneue >= 0
                                ? Colors.green
                                : Colors.red,
                            reveneue >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.2),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            Icons.receipt_long,
                            'Transactions',
                            '${business.transactionsCount ?? 0}',
                            Colors.blue,
                            Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.2),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            Icons.access_time,
                            'Created',
                            _formatDate(business.dateCreated.toDate()),
                            Colors.orange,
                            Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.visibility),
                          label: const Text('View Details'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                      ),
                      // const SizedBox(width: 12),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     border: Border.all(
                      //       color: Theme.of(context)
                      //           .colorScheme
                      //           .outline
                      //           .withValues(alpha: 0.3),
                      //     ),
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   child: IconButton(
                      //     onPressed: onEdit,
                      //     icon: Icon(
                      //       Icons.edit,
                      //       color: Theme.of(context).colorScheme.primary,
                      //     ),
                      //     tooltip: 'Edit Business',
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color iconColor,
    Color? textColor
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor ??Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
              ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference}d ago';
    } else if (difference < 30) {
      return '${(difference / 7).round()}w ago';
    } else if (difference < 365) {
      return '${(difference / 30).round()}m ago';
    } else {
      return '${(difference / 365).round()}y ago';
    }
  }
}
