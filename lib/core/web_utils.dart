import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pitstop/core/utils/external_links.dart';
import 'package:provider/provider.dart';
import 'package:pitstop/core/providers/user_provider.dart';
import 'package:pitstop/features/auth/presentation/providers/auth_provider.dart';
import 'package:pitstop/features/member_portal/presentation/pages/profile_page.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

class HoverCursor extends StatelessWidget {
  final Widget child;
  final MouseCursor cursor;

  const HoverCursor({
    super.key,
    required this.child,
    this.cursor = SystemMouseCursors.click,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;
    return MouseRegion(
      cursor: cursor,
      child: child,
    );
  }
}

class HoverBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;

  const HoverBuilder({super.key, required this.builder});

  @override
  State<HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.builder(context, false);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: widget.builder(context, _isHovered),
    );
  }
}

class HoverCard extends StatelessWidget {
  final Widget child;
  final double hoverLift;
  final Duration duration;

  const HoverCard({
    super.key,
    required this.child,
    this.hoverLift = 6,
    this.duration = const Duration(milliseconds: 140),
  });

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      builder: (context, isHovered) {
        return AnimatedContainer(
          duration: duration,
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(
            0,
            isHovered ? -hoverLift : 0,
            0,
          ),
          child: child,
        );
      },
    );
  }
}

class WebSelectionArea extends StatelessWidget {
  final Widget child;

  const WebSelectionArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? SelectionArea(child: child) : child;
  }
}

enum WebNavItem {
  newsfeed,
  events,
  dining,
  bookRoom,
  clubHouse,
  clubBenefits,
}

class WebScaffold extends StatelessWidget {
  final String title;
  final WebNavItem selected;
  final Widget child;
  final ValueChanged<WebNavItem> onNavSelected;
  final VoidCallback? onBellTap;
  final VoidCallback? onCalendarTap;
  final bool showFooter;

  const WebScaffold({
    super.key,
    required this.title,
    required this.selected,
    required this.child,
    required this.onNavSelected,
    this.onBellTap,
    this.onCalendarTap,
    this.showFooter = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          _WebSidebar(
            selected: selected,
            onSelect: onNavSelected,
          ),
          Expanded(
            child: Column(
              children: [
                _topBar(context),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                        child: child,
                      ),
                    ),
                  ),
                ),
                if (showFooter) _footer(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          HoverCursor(
            child: _iconSquare(
              context,
              icon: LucideIcons.bell,
              onTap: onBellTap,
            ),
          ),
          const SizedBox(width: 10),
          HoverCursor(
            child: _iconSquare(
              context,
              icon: LucideIcons.calendar,
              onTap: onCalendarTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconSquare(BuildContext context,
      {required IconData icon, VoidCallback? onTap}) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: scheme.onSurface.withValues(alpha: 0.12)),
        ),
        child: Icon(icon, size: 18, color: scheme.onSurface.withValues(alpha: 0.65)),
      ),
    );
  }

  Widget _footer(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scheme.onSurface.withValues(alpha: 0.55)),
            ),
            child: Center(
              child: Icon(
                LucideIcons.crown,
                size: 12,
                color: scheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ),
          const Spacer(),
          HoverCursor(
            child: GestureDetector(
              onTap: ExternalLinks.openInstagram,
              child: Icon(LucideIcons.instagram,
                  size: 16, color: scheme.onSurface.withValues(alpha: 0.65)),
            ),
          ),
          const SizedBox(width: 24),
          _footerLink(context, 'FAQ'),
          const SizedBox(width: 12),
          _footerLink(context, 'Terms'),
          const SizedBox(width: 12),
          _footerLink(context, 'Privacy'),
        ],
      ),
    );
  }

  Widget _footerLink(BuildContext context, String label) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return HoverCursor(
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coming soon')),
          );
        },
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class _WebSidebar extends StatelessWidget {
  final WebNavItem selected;
  final ValueChanged<WebNavItem> onSelect;

  const _WebSidebar({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: 230,
      color: scheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: scheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.onSurface.withValues(alpha: 0.12)),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/drivers_club.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _navItem(
            context,
            item: WebNavItem.newsfeed,
            icon: LucideIcons.star,
            label: 'NEWSFEED',
          ),
          _navItem(
            context,
            item: WebNavItem.events,
            icon: LucideIcons.calendar,
            label: 'EVENTS',
          ),
          _navItem(
            context,
            item: WebNavItem.dining,
            icon: LucideIcons.utensils,
            label: 'DINING',
          ),
          _navItem(
            context,
            item: WebNavItem.bookRoom,
            icon: LucideIcons.doorOpen,
            label: 'BOOK A ROOM',
          ),
          _navItem(
            context,
            item: WebNavItem.clubHouse,
            icon: LucideIcons.home,
            label: 'CLUB HOUSE',
          ),
          _navItem(
            context,
            item: WebNavItem.clubBenefits,
            icon: LucideIcons.gem,
            label: 'CLUB BENEFITS',
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: scheme.onSurface.withValues(alpha: 0.12)),
              ),
            ),
            child: _ProfileFooter(),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required WebNavItem item,
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isActive = selected == item;
    return HoverCursor(
      child: GestureDetector(
        onTap: () => onSelect(item),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? scheme.secondary : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 16,
                  color: isActive ? scheme.onSecondary : scheme.onSurface),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isActive ? scheme.onSecondary : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Consumer2<UserProvider, AuthProvider>(
      builder: (context, userProvider, authProvider, _) {
        final user = authProvider.currentUser;
        final name = (user?.fullName ?? '').trim();
        final email = (user?.email ?? '').trim();
        final imageProvider = _resolveProfileImage(userProvider, user);

        return HoverCursor(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: scheme.surface,
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? Icon(LucideIcons.user, size: 16, color: scheme.onSurface)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : 'Account',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      Text(
                        email.isNotEmpty ? email : 'View Profile',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

ImageProvider? _resolveProfileImage(UserProvider userProvider, dynamic user) {
  if (userProvider.profileImageProvider != null) {
    return userProvider.profileImageProvider!;
  }
  final base64String = user?.avatarBase64?.toString();
  final base64Bytes = _decodeBase64Image(base64String);
  if (base64Bytes != null) {
    return MemoryImage(base64Bytes);
  }
  final avatarUrl = user?.avatarUrl?.toString();
  if (avatarUrl != null && avatarUrl.isNotEmpty) {
    return NetworkImage(avatarUrl);
  }
  return const AssetImage('assets/images/user_profile.png');
}

Uint8List? _decodeBase64Image(String? base64String) {
  if (base64String == null || base64String.isEmpty) return null;
  try {
    final pure = base64String.contains(',')
        ? base64String.split(',').last
        : base64String;
    return base64Decode(pure);
  } catch (_) {
    return null;
  }
}
