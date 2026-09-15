import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';
import 'package:kit_template_app/core/helpers/ui_helpers.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.bottom,
    this.centerTitle,
    this.backgroundColor,
    this.foregroundColor,
    this.showBackButton = true,
    this.onBackPressed,
    this.elevation,
    this.height,
    this.titleSpacing,
    super.key,
  }) : assert(
         title == null || titleWidget == null,
         'Provide either title or titleWidget, not both',
       );

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool? centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double? elevation;
  final double? height;
  final double? titleSpacing;

  @override
  Size get preferredSize => Size.fromHeight(
    (height ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final colors = AppThemeColors.of(context);
    final resolvedLeading =
        leading ??
        (showBackButton && canPop
            ? IconButton(
                icon: Icon(
                  IconsaxPlusLinear.arrow_left,
                  size: 30,
                  color: colors.textHeading,
                ),
                onPressed: onBackPressed ?? () => UiHelpers.pop(context),
              )
            : null);

    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      titleSpacing: titleSpacing,
      leading: resolvedLeading,
      automaticallyImplyLeading: false,
      actions: actions,
      bottom: bottom,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      toolbarHeight: height,
    );
  }
}
