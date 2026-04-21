import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../widgets/transaction_list_item.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/skeleton_loader.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TransactionType? _selectedType;

  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(const FetchHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: BlocBuilder<HistoryBloc, HistoryState>(
              builder: (context, state) {
                if (state is HistoryLoading) {
                  return const TransactionSkeletonList(itemCount: 8);
                } else if (state is HistoryLoaded) {
                  if (state.transactions.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.history_rounded,
                      title: 'No transactions found',
                      subtitle: 'Try filtering by a different category.',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<HistoryBloc>().add(RefreshHistoryEvent(type: _selectedType));
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: state.transactions.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        indent: 80,
                        color: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                      itemBuilder: (context, index) {
                        final tx = state.transactions[index];
                        return TransactionListItem(
                          transaction: tx,
                          onTap: () {
                            context.push('/history/detail', extra: tx);
                          },
                        );
                      },
                    ),
                  );
                } else if (state is HistoryError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message, style: TextStyle(color: cs.error)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<HistoryBloc>().add(FetchHistoryEvent(type: _selectedType)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'type': null},
      {'label': 'Fees', 'type': TransactionType.fee},
      {'label': 'Transfers', 'type': TransactionType.transfer},
      {'label': 'Data', 'type': TransactionType.data},
      {'label': 'Airtime', 'type': TransactionType.airtime},
      {'label': 'Deposits', 'type': TransactionType.deposit},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedType == filter['type'];

          return ChoiceChip(
            label: Text(filter['label'] as String),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedType = filter['type'] as TransactionType?;
                });
                context.read<HistoryBloc>().add(FetchHistoryEvent(type: _selectedType));
              }
            },
            selectedColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.transparent : Theme.of(context).dividerColor.withValues(alpha: 0.5),
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
