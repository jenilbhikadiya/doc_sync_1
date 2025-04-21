// lib/components/common_appbar.dart (or your path)
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final String logoAssetPath; // <<< Changed: Pass path instead of widget
  final double logoHeight; // <<< New: Allow specifying height
  final Color? logoColor; // <<< New: Allow specifying color (for filter)
  final Color? backgroundColor;
  final Color iconColor;
  final double elevation;

  const CommonAppBar({
    super.key,
    required this.onMenuPressed,
    this.onSearchPressed,
    this.onNotificationPressed,
    this.onProfilePressed,
    required this.logoAssetPath, // <<< Changed: Now required string
    this.logoHeight = 30.0, // <<< New: Default height
    this.logoColor = Colors.white, // <<< New: Default color (white)
    this.backgroundColor,
    this.iconColor = Colors.white,
    this.elevation = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor =
        backgroundColor ?? const Color(0xFF192B4A); // Default dark blue/slate

    // --- Create the logo widget internally ---
    final Widget logoWidget = SvgPicture.asset(
      logoAssetPath, // Use the provided path
      height: logoHeight, // Use the height parameter
      // Apply color filter only if logoColor is not null
      colorFilter:
          logoColor != null
              ? ColorFilter.mode(logoColor!, BlendMode.srcIn)
              : null,
    );
    // --- End internal logo creation ---

    return AppBar(
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: iconColor,
      elevation: elevation,
      automaticallyImplyLeading: false,
      leadingWidth: 56.0,
      leading: IconButton(
        icon: Icon(Icons.menu, color: iconColor),
        onPressed: onMenuPressed,
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      ),
      titleSpacing: 0.0,
      title: logoWidget, // <<< Use the internally created logo widget
      centerTitle: false,
      actions: [
        if (onSearchPressed != null)
          IconButton(
            icon: Icon(Icons.search, color: iconColor),
            onPressed: onSearchPressed,
            tooltip: 'Search',
          ),
        if (onNotificationPressed != null)
          IconButton(
            icon: Icon(Icons.notifications_none, color: iconColor),
            onPressed: onNotificationPressed,
            tooltip: 'Notifications',
          ),
        if (onProfilePressed != null)
          IconButton(
            icon: Icon(Icons.person_outline, color: iconColor),
            onPressed: onProfilePressed,
            tooltip: 'Profile',
          ),
        if (onSearchPressed != null ||
            onNotificationPressed != null ||
            onProfilePressed != null)
          const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
