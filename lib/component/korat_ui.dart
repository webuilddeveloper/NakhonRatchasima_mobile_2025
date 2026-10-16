import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ratchasima/apptheme.dart';

abstract final class KoratSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class KoratRadius {
  static const BorderRadius sm = BorderRadius.all(Radius.circular(10));
  static const BorderRadius md = BorderRadius.all(Radius.circular(14));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(18));
}

class KoratAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KoratAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.showBack = false,
    this.actions = const [],
    this.subtitle,
  });

  final String title;
  final VoidCallback? onBack;
  final bool showBack;
  final List<Widget> actions;
  final String? subtitle;

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 62 : 72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      toolbarHeight: preferredSize.height,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      flexibleSpace: const _KoratAppBarBackground(),
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.only(left: 8),
              child: KoratAppBarAction(
                tooltip: 'ย้อนกลับ',
                onPressed: onBack ?? () => Navigator.maybePop(context),
                icon: Icons.arrow_back_rounded,
              ),
            )
          : null,
      leadingWidth: showBack ? 54 : null,
      titleSpacing: 16,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.surface,
              fontFamily: 'Kanit',
              fontSize: 19,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.surface.withValues(alpha: 0.78),
                fontFamily: 'Sarabun',
                fontSize: 11,
                height: 1.2,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
      actions: [
        ...actions,
        if (actions.isNotEmpty) const SizedBox(width: 8),
      ],
    );
  }
}

class KoratAppBarAction extends StatelessWidget {
  const KoratAppBarAction({
    super.key,
    required this.tooltip,
    required this.onPressed,
    this.icon,
    this.child,
  }) : assert(icon != null || child != null);

  final String tooltip;
  final VoidCallback onPressed;
  final IconData? icon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Align(
        alignment: Alignment.center,
        widthFactor: 1,
        heightFactor: 1,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Material(
            color: AppColors.surface.withValues(alpha: 0.12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: AppColors.surface.withValues(alpha: 0.24),
                width: 0.8,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: Center(
                child: child ??
                    Icon(
                      icon,
                      color: AppColors.surface,
                      size: 21,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KoratAppBarBackground extends StatelessWidget {
  const _KoratAppBarBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB90F5F),
            AppColors.primary,
            Color(0xFFD92B79),
          ],
          stops: [0, 0.56, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x3DC9166D),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -46,
            child: _AppBarGlow(size: 118, opacity: 0.07),
          ),
          Positioned(
            left: 58,
            bottom: -42,
            child: _AppBarGlow(size: 84, opacity: 0.045),
          ),
        ],
      ),
    );
  }
}

class _AppBarGlow extends StatelessWidget {
  const _AppBarGlow({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface.withValues(alpha: opacity),
      ),
    );
  }
}

class KoratPageHeader extends StatelessWidget {
  const KoratPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        KoratSpacing.md,
        MediaQuery.paddingOf(context).top + KoratSpacing.sm,
        KoratSpacing.md,
        KoratSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: KoratSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: KoratSpacing.xxs),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.surface.withValues(alpha: 0.82),
                        ),
                  ),
                ],
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

class KoratSectionTitle extends StatelessWidget {
  const KoratSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: KoratSpacing.xxs),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class KoratSurfaceCard extends StatelessWidget {
  const KoratSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(KoratSpacing.md),
    this.margin,
    this.color = AppColors.surface,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: KoratRadius.md,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A282429),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class KoratMenuTile extends StatelessWidget {
  const KoratMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: KoratRadius.sm,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KoratSpacing.xs,
            vertical: KoratSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: KoratRadius.sm,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: KoratSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: destructive
                                ? AppColors.error
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: destructive ? AppColors.error : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum KoratViewState { loading, empty, error }

class KoratStateView extends StatelessWidget {
  const KoratStateView({
    super.key,
    required this.state,
    this.title,
    this.message,
    this.onRetry,
  });

  final KoratViewState state;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (state == KoratViewState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isError = state == KoratViewState.error;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KoratSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isError ? Icons.cloud_off_rounded : Icons.inbox_outlined,
                color: isError ? AppColors.error : AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: KoratSpacing.md),
            Text(
              title ?? (isError ? 'ไม่สามารถโหลดข้อมูลได้' : 'ยังไม่มีข้อมูล'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (message != null) ...[
              const SizedBox(height: KoratSpacing.xs),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: KoratSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('ลองอีกครั้ง'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
