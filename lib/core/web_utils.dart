import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pitstop/core/responsive.dart';
import 'package:pitstop/core/utils/external_links.dart';
import 'package:pitstop/core/web_history_stub.dart'
    if (dart.library.html) 'package:pitstop/core/web_history_web.dart'
        as web_history;
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

  void _setHovered(bool value) {
    if (_isHovered == value || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isHovered == value) return;
      setState(() => _isHovered = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.builder(context, false);
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
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
  communities,
}

class WebScaffold extends StatelessWidget {
  final String title;
  final WebNavItem selected;
  final Widget child;
  final ValueChanged<WebNavItem> onNavSelected;
  final VoidCallback? onBellTap;
  final VoidCallback? onCalendarTap;
  final VoidCallback? onProfileTap;
  final bool showFooter;

  const WebScaffold({
    super.key,
    required this.title,
    required this.selected,
    required this.child,
    required this.onNavSelected,
    this.onBellTap,
    this.onCalendarTap,
    this.onProfileTap,
    this.showFooter = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final narrow = w < kWebNavDrawerBreakpoint;
        final horizontalPad = narrow ? 12.0 : 24.0;
        final bodyPadding = EdgeInsets.fromLTRB(
          horizontalPad,
          narrow ? 12 : 20,
          horizontalPad,
          narrow ? 16 : 24,
        );
        final topBarPadding = EdgeInsets.fromLTRB(
          horizontalPad,
          narrow ? 12 : 16,
          horizontalPad,
          narrow ? 12 : 16,
        );

        Widget mainColumn(
          BuildContext hostContext, {
          VoidCallback? onOpenDrawer,
        }) {
          return Column(
            children: [
              Padding(
                padding: topBarPadding,
                child: _topBar(
                  hostContext,
                  padding: EdgeInsets.zero,
                  onOpenDrawer: onOpenDrawer,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: bodyPadding,
                  child: child,
                ),
              ),
              if (showFooter) _footer(hostContext, compact: narrow),
            ],
          );
        }

        if (!narrow) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Row(
              children: [
                _WebSidebar(
                  selected: selected,
                  onSelect: onNavSelected,
                ),
                Expanded(
                  child: mainColumn(context),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          drawer: Drawer(
            width: math.min(288.0, w * 0.9),
            child: SafeArea(
              child: _WebSidebar(
                selected: selected,
                onSelect: (item) {
                  onNavSelected(item);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          body: Builder(
            builder: (scaffoldCtx) {
              return mainColumn(
                context,
                onOpenDrawer: () => Scaffold.of(scaffoldCtx).openDrawer(),
              );
            },
          ),
        );
      },
    );
  }

  Widget _topBar(
    BuildContext context, {
    required EdgeInsetsGeometry padding,
    VoidCallback? onOpenDrawer,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final titleSize = onOpenDrawer != null ? 16.0 : 18.0;
    return Container(
      padding: padding,
      child: Row(
        children: [
          if (onOpenDrawer != null) ...[
            HoverCursor(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onOpenDrawer,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      LucideIcons.menu,
                      size: 22,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          HoverCursor(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.maybePop(context);
                  } else {
                    web_history.platformWebHistoryBack();
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    LucideIcons.chevronLeft,
                    size: 22,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                color: scheme.onSurface,
                letterSpacing: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onBellTap != null) ...[
            HoverCursor(
              child: _iconSquare(
                context,
                icon: LucideIcons.bell,
                onTap: onBellTap,
              ),
            ),
            SizedBox(width: onOpenDrawer != null ? 6 : 10),
          ],
          if (onCalendarTap != null)
            HoverCursor(
              child: _iconSquare(
                context,
                icon: LucideIcons.calendar,
                onTap: onCalendarTap,
              ),
            ),
          if (onProfileTap != null) ...[
            SizedBox(width: onOpenDrawer != null ? 6 : 10),
            HoverCursor(
              child: _iconSquare(
                context,
                icon: LucideIcons.user,
                onTap: onProfileTap,
              ),
            ),
          ],
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

  Widget _footer(BuildContext context, {bool compact = false}) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final crown = Container(
      width: compact ? 26 : 28,
      height: compact ? 26 : 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.55)),
      ),
      child: Center(
        child: Icon(
          LucideIcons.crown,
          size: compact ? 11 : 12,
          color: scheme.onSurface.withValues(alpha: 0.65),
        ),
      ),
    );
    final ig = HoverCursor(
      child: GestureDetector(
        onTap: ExternalLinks.openInstagram,
        child: Icon(
          LucideIcons.instagram,
          size: compact ? 15 : 16,
          color: scheme.onSurface.withValues(alpha: 0.65),
        ),
      ),
    );
    final links = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _footerLink(context, 'FAQ'),
        SizedBox(width: compact ? 10 : 12),
        _footerLink(context, 'Terms'),
        SizedBox(width: compact ? 10 : 12),
        _footerLink(context, 'Privacy'),
      ],
    );

    if (compact) {
      return Container(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + bottomInset),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: scheme.onSurface.withValues(alpha: 0.08)),
          ),
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                crown,
                const SizedBox(width: 14),
                ig,
              ],
            ),
            links,
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 16 + bottomInset),
      child: Row(
        children: [
          crown,
          const Spacer(),
          ig,
          const SizedBox(width: 24),
          links,
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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 230,
      color: scheme.surface,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: scheme.onSurface.withValues(alpha: 0.12)),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/drivers_club.png',
                        fit: BoxFit.cover,
                      ),
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
                _navItem(
                  context,
                  item: WebNavItem.communities,
                  icon: LucideIcons.users,
                  label: 'COMMUNITIES',
                ),
              ],
            ),
          ),
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
