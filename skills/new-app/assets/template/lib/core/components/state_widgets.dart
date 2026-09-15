import 'package:flutter/material.dart';
import 'package:kit_template_app/core/constants/app_color.dart';

/// Centered indeterminate loading spinner.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({this.size = 20, this.color, super.key});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color;
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator.adaptive(
          strokeWidth: 2,
          valueColor: c == null ? null : AlwaysStoppedAnimation(c),
        ),
      ),
    );
  }
}

/// Fills the viewport so pull-to-refresh works anywhere, not just content.
class PullToRefreshBody extends StatelessWidget {
  const PullToRefreshBody({
    required this.child,
    this.alignment = Alignment.topCenter,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final Widget child;

  /// Where the child sits: cards read better at the top, messages centred.
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight - padding.vertical,
          ),
          child: Align(alignment: alignment, child: child),
        ),
      ),
    );
  }
}

/// Reusable error state with optional retry.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    this.title = 'Oops, something went wrong',
    this.message = 'An unexpected error occurred.\nPlease try again.',
    this.icon = Icons.wifi_tethering_error_rounded_outlined,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.iconColor = AppColor.error,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return _StateScaffold(
      icon: icon,
      iconColor: iconColor,
      iconBackground: iconColor.withValues(alpha: 0.12),
      title: title,
      subtitle: message,
      actionLabel: onRetry == null ? null : retryLabel,
      actionIcon: Icons.refresh_rounded,
      onAction: onRetry,
    );
  }
}

/// Reusable empty state with optional action.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    this.title = 'Nothing here yet',
    this.subtitle = "Looks like there's nothing to show right now.",
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel = 'Refresh',
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _StateScaffold(
      icon: icon,
      iconColor: scheme.onSurfaceVariant,
      iconBackground: scheme.surfaceContainerHighest,
      title: title,
      subtitle: subtitle,
      actionLabel: onAction == null ? null : actionLabel,
      actionIcon: Icons.refresh_rounded,
      onAction: onAction,
    );
  }
}

class _StateScaffold extends StatelessWidget {
  const _StateScaffold({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon, size: 16),
                label: Text(actionLabel!),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
