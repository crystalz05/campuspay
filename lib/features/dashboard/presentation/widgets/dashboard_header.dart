import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../../../notifications/presentation/bloc/notifications_state.dart';

class DashboardHeader extends StatelessWidget {
  final String fullName;

  const DashboardHeader({
    super.key,
    required this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${fullName.split(' ')[0]}',
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome back to CampusPay',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
          ),
          child: BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              int unreadCount = 0;
              if (state is NotificationsLoaded) {
                unreadCount = state.unreadCount;
              }

              return Badge(
                isLabelVisible: unreadCount > 0,
                label: Text(unreadCount.toString()),
                child: IconButton(
                  onPressed: () {
                    context.push('/notifications');
                  },
                  icon: Icon(Icons.notifications_none_rounded, color: cs.primary),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
