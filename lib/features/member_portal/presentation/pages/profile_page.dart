import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'notifications_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pitstop/core/providers/user_provider.dart';
import 'package:pitstop/core/utils/external_links.dart';
import 'package:pitstop/features/auth/presentation/pages/minimal_login_page.dart';
import 'package:pitstop/features/auth/presentation/providers/auth_provider.dart';
import 'package:pitstop/core/storage/secure_storage.dart';
import 'package:pitstop/core/web_utils.dart';


// ─────────────────────────────────────────────────────────────────────────────
//  Profile / Account Page
//  Matches the reference design exactly:
//  · Warm-beige background
//  · "ACCOUNT" title top-left + outlined bell/calendar icons
//  · User avatar row + logout icon
//  · Left sidebar: Memberships, Profile (active), My Schedule, Wallet, Billing
//  · Right content: 3 tabs — Account Details | Personal Details | Advanced Settings
// ─────────────────────────────────────────────────────────────────────────────
class ProfileContent extends StatefulWidget {
  final int initialNavIndex;

  const ProfileContent({super.key, this.initialNavIndex = 1});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
        child: ProfileContent(),
      ),
    );
  }
}

class MySchedulePage extends StatefulWidget {
  const MySchedulePage({super.key});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage> {
  int _scheduleTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: _ProfileContentState._bg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(LucideIcons.arrowLeft,
                          size: 18, color: Colors.black),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'MY SCHEDULE',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    _OutlinedIcon(
                      icon: LucideIcons.bell,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsPage()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _OutlinedIcon(
                      icon: LucideIcons.calendar,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              _MyScheduleTabs(
                activeIndex: _scheduleTab,
                onTap: (i) => setState(() => _scheduleTab = i),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _scheduleTab == 0
                            ? 'You have no upcoming items in your schedule.'
                            : 'No past items found.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyScheduleTabs extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;

  const _MyScheduleTabs({
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = ['Upcoming', 'Past'];
    return Container(
      color: _ProfileContentState._bg,
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 24),
              itemBuilder: (_, i) {
                final active = i == activeIndex;
                return GestureDetector(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        tabs[i],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                          color: active ? Colors.black : Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        width: active ? 32 : 0,
                        color: Colors.black,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: _ProfileContentState._divider),
        ],
      ),
    );
  }
}

class _ProfileContentState extends State<ProfileContent>
    with WidgetsBindingObserver {
  static const _bg      = Color(0xFFF5F5F5);
  static const _divider = Color(0xFFBFBDB7);

  // ── State ──────────────────────────────────────────────────────────────────
  int _navIndex       = 1;  // Profile selected
  int _tabIndex       = 0;  // Account Details sub-tab
  int _scheduleTab    = 0;  // 0=Upcoming, 1=Past
  int _walletTab      = 0;  // 0=Payment Methods, 1=Tickets, 2=Vouchers
  int _billingTab     = 0;  // 0=Statements, 1=Dues, 2=Orders, 3=House Account

  Uint8List? _profileImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _navIndex = widget.initialNavIndex;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadProfileToForm();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final c in [_firstName,_lastName,_middleName,_birthday,_email,_company,
      _jobTitle,_phone,_mobile,_address,_apt,_city,_postal,
      _customerType,_customerCategory,_gender,_vehicleChoice,_vinePref,_customFields,
      _currentPw,_newPw,_confirmPw]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadProfileToForm();
    }
  }

  Future<void> _loadProfileToForm() async {
    final auth = context.read<AuthProvider>();
    await auth.loadProfile();
    final user = auth.currentUser;
    if (user == null || !mounted) return;

    _firstName.text  = user.firstName;
    _lastName.text   = user.lastName;
    _middleName.text = user.middleName ?? '';
    _birthday.text   = user.birthday ?? '';
    _email.text      = user.email;
    _company.text    = user.company ?? '';
    _jobTitle.text   = user.jobTitle ?? '';
    _phone.text      = user.phone ?? '';
    _mobile.text     = user.mobileNumber ?? '';
    _address.text    = user.address ?? '';
    _apt.text        = user.aptSuite ?? user.houseNumber ?? '';
    _city.text       = user.city ?? user.ort ?? '';
    _postal.text     = user.postalCode ?? '';
    _customerType.text     = user.customerType ?? '';
    _customerCategory.text = user.customerCategory ?? '';
    _gender.text           = user.gender ?? '';
    _vehicleChoice.text    = user.vehicleChoice ?? '';
    _vinePref.text         = user.vinePref ?? '';
    _customFields.text     = user.customFields ?? '';

    final hasAvatar = (user.avatarBase64 ?? '').trim().isNotEmpty ||
        (user.avatarUrl ?? '').trim().isNotEmpty;
    if (!hasAvatar) {
      Provider.of<UserProvider>(context, listen: false).clearProfileImage();
      _profileImageBytes = null;
    }

    setState(() {
      _emailOptIn = user.emailOptIn ?? _emailOptIn;
      _country = user.country ?? user.land ?? _country;
      _region  = user.region ?? _region;
    });

    final tags = await SecureStorage.getInterestTags();
    if (!mounted || tags.isEmpty) return;
    setState(() {
      _selectedInterests
        ..clear()
        ..addAll(tags);
    });
  }

  Future<void> _showImagePickerSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              if (!kIsWeb)
                _sheetTile(
                  icon: LucideIcons.camera,
                  label: 'Take Photo',
                  onTap: () => _handlePick(ImageSource.camera),
                ),
              _sheetTile(
                icon: LucideIcons.image,
                label: 'Choose from Gallery',
                onTap: () => _handlePick(ImageSource.gallery),
              ),
              if (_profileImageBytes != null ||
                  Provider.of<UserProvider>(context, listen: false).profileImageBytes != null)
                _sheetTile(
                  icon: LucideIcons.trash2,
                  label: 'Remove Photo',
                  isDestructive: true,
                  onTap: _removeImage,
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handlePick(ImageSource source) async {
    Navigator.pop(context);
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile == null) return;
    final bytes = await pickedFile.readAsBytes();
    final avatarBase64 = base64Encode(bytes);
    final ext = pickedFile.path.toLowerCase();
    final mime = ext.endsWith('.png') ? 'image/png' : 'image/jpeg';
    final dataUri = 'data:$mime;base64,$avatarBase64';
    var success = await context.read<AuthProvider>().updateAvatar(dataUri);
    if (!success) {
      success = await context.read<AuthProvider>().updateAvatar(avatarBase64);
    }
    if (!success && mounted) {
      final message = context.read<AuthProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.isNotEmpty
            ? message
            : 'Failed to update profile photo')),
      );
      return;
    }
    if (mounted) {
      Provider.of<UserProvider>(context, listen: false)
          .updateProfileImageBytes(bytes);
      setState(() => _profileImageBytes = bytes);
    }
  }

  void _removeImage() {
    Navigator.pop(context);
    _removeAvatarOnServer();
  }

  Future<void> _removeAvatarOnServer() async {
    final auth = context.read<AuthProvider>();
    // Try empty string as "remove"
    var success = await auth.updateAvatar('');
    if (!success) {
      // Fallback to explicit null marker if backend expects it
      success = await auth.updateAvatar('null');
    }
    if (!mounted) return;

    if (success) {
      Provider.of<UserProvider>(context, listen: false).clearProfileImage();
      setState(() {
        _profileImageBytes = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage.isNotEmpty
            ? auth.errorMessage
            : 'Failed to remove profile photo')),
      );
    }
  }

  static const _navItems = [
    'Memberships', 'Profile', 'My Schedule', 'Wallet', 'Billing',
  ];
  static const _tabs = [
    'Account Details', 'Personal Details', 'Advanced Settings',
  ];
  static const _countryOptions = [
    'Germany', 'Pakistan', 'USA', 'UK', 'France',
  ];
  static const _regionOptions = [
    'Baden-Württemberg', 'Bavaria', 'Berlin', 'Hamburg',
  ];

  // Account Details form controllers
  final _firstName   = TextEditingController();
  final _lastName    = TextEditingController();
  final _middleName  = TextEditingController();
  final _birthday    = TextEditingController();
  final _email       = TextEditingController();
  final _company     = TextEditingController();
  final _jobTitle    = TextEditingController();
  final _phone       = TextEditingController();
  final _mobile      = TextEditingController();
  final _address     = TextEditingController();
  final _apt         = TextEditingController();
  final _city        = TextEditingController();
  final _postal      = TextEditingController();
  final _customerType     = TextEditingController();
  final _customerCategory = TextEditingController();
  final _gender           = TextEditingController();
  final _vehicleChoice    = TextEditingController();
  final _vinePref         = TextEditingController();
  final _customFields     = TextEditingController();
  String _country    = '';
  String _region     = '';

  // Personal Details
  final _selectedInterests = <String>{};
  static const _interests  = [
    'ART','AVIATION','BOATING','CIGAR','CLASSIC CARS','CLUB ONSITE SPORTS',
    'CULINARY','EQUESTRIAN','EXTREME SPORTS','GOLF','HUNTING','MOVIES',
    'MUSIC','OUTDOOR SPORTS','RACING','SPORTS CARS','SPORTS','TRAVEL',
    'WINE','WINTER SPORTS',
  ];
  String? _collectibles;
  String? _prefLang;
  String? _newsletterLang;

  // Advanced Settings
  bool   _emailOptIn          = true;
  bool   _showCurrent        = false;
  bool   _showNew            = false;
  bool   _showConfirm        = false;
  final  _currentPw          = TextEditingController();
  final  _newPw              = TextEditingController();
  final  _confirmPw          = TextEditingController();

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final isWide = size.width > 680;

    return Container(
      color: _bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'ACCOUNT',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                _OutlinedIcon(
                  icon: LucideIcons.bell,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationsPage())),
                ),
                const SizedBox(width: 8),
                _OutlinedIcon(
                  icon: LucideIcons.calendar,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MySchedulePage()),
                  ),
                ),
              ],
            ),
          ),

          // ── User row ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Consumer2<UserProvider, AuthProvider>(
                  builder: (context, userProvider, authProvider, child) {
                    final avatarUrl = authProvider.currentUser?.avatarUrl;
                    final avatarBase64 = authProvider.currentUser?.avatarBase64;
                    final avatarBytes = _decodeBase64Image(avatarBase64);
                    final imageProvider = userProvider.profileImageBytes != null
                        ? MemoryImage(userProvider.profileImageBytes!)
                        : (_profileImageBytes != null
                            ? MemoryImage(_profileImageBytes!)
                            : (avatarBytes != null
                                ? MemoryImage(avatarBytes)
                                : (avatarUrl != null && avatarUrl.isNotEmpty
                                    ? NetworkImage(avatarUrl)
                                    : const AssetImage('assets/images/user_profile.png')
                                        as ImageProvider)));
                    return HoverCursor(
                      child: GestureDetector(
                        onTap: _showImagePickerSheet,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: imageProvider,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          final user = authProvider.currentUser;
                          final name = (user?.fullName ?? '').trim();
                          final email = (user?.email ?? '').trim();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name.isNotEmpty ? name : 'Member',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                email.isNotEmpty ? email : 'email@domain.com',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                HoverCursor(
                  child: GestureDetector(
                    onTap: () async {
                      await context.read<AuthProvider>().logout();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MinimalLoginPage()),
                        (route) => false,
                      );
                    },
                    child: const Icon(LucideIcons.logOut,
                        size: 20, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(color: _divider, height: 1),

          // ── Body: sidebar + content ────────────────────────────────────────
          Expanded(
            child: isWide
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─ Left sidebar ─────────────────────────────────────
                SizedBox(
                  width: 180,
                  child: _buildSideNav(),
                ),
                VerticalDivider(
                    width: 1, color: _divider),
                // ─ Right content ─────────────────────────────────────
                Expanded(child: _buildContent()),
              ],
            )
                : Column(
              children: [
                _buildSideNavHorizontal(),
                Divider(color: _divider, height: 1),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sidebar (vertical for tablet) ─────────────────────────────────────────
  Widget _buildSideNav() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: _navItems.length,
      itemBuilder: (_, i) {
        final active = i == _navIndex;
        return GestureDetector(
          onTap: () => setState(() {
            _navIndex = i;
            _tabIndex = 0;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 13),
            decoration: active
                ? BoxDecoration(
              border: Border.all(
                  color: Colors.black, width: 1),
            )
                : null,
            child: Text(
              _navItems[i],
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight:
                active ? FontWeight.w700 : FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Sidebar (horizontal for mobile) ───────────────────────────────────────
  Widget _buildSideNavHorizontal() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _navItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (_, i) {
          final active = i == _navIndex;
          return GestureDetector(
            onTap: () => setState(() {
              _navIndex = i;
              _tabIndex = 0;
            }),
            child: Center(
              child: Text(
                _navItems[i],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight:
                  active ? FontWeight.w700 : FontWeight.w400,
                  color: active ? Colors.black : Colors.black54,
                  decoration: active
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Right content pane ────────────────────────────────────────────────────
  Widget _buildContent() {
    switch (_navIndex) {
      case 0:  return _buildMemberships();
      case 2:  return _buildMySchedule();
      case 3:  return _buildWallet();
      case 4:  return _buildBilling();
      default: return _buildProfileSection();
    }
  }

  // ── Profile (nav index 1) ─────────────────────────────────────────────────
  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // sub-tab bar
        Container(
          color: _bg,
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _tabs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 24),
                  itemBuilder: (_, i) {
                    final active = i == _tabIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _tabIndex = i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _tabs[i],
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                              color: active ? Colors.black : Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 2,
                            width: active ? 32 : 0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Divider(height: 1, color: _divider),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: _tabIndex == 0
                ? _buildAccountDetails()
                : _tabIndex == 1
                ? _buildPersonalDetails()
                : _buildAdvancedSettings(),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  Nav 0 — Memberships
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildMemberships() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Corporate section ─────────────────────────────────────────────
          Text(
            'Corporate - Global network',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(fontSize: 12, color: Colors.black54, height: 1.6),
              children: const [
                TextSpan(text: 'As a member of '),
                TextSpan(
                  text: 'Club portal ',
                  style: TextStyle(color: Color(0xFFC0742A)),
                ),
                TextSpan(text: ' you will gain access to member only experiences.'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Membership card ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Club logo circle
                    Container(
                      width: 72, height: 72,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.settings2, color: Colors.white, size: 28),
                      ),
                    ),
                    // "..." menu
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(LucideIcons.moreHorizontal, size: 16, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Ammar Raja ',
                  style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2618',
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black54),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Nominate a Member ─────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nominate a Member',
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.black54, height: 1.6),
                        children: const [
                          TextSpan(text: 'Nominate an individual to be '),
                          TextSpan(
                            text: 'considered for a membership.',
                            style: TextStyle(color: Color(0xFFC0742A)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'You have not nominated any members yet.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFFC0742A),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Nominate a Member — coming soon',
                            style: GoogleFonts.inter(color: Colors.white)),
                        backgroundColor: Colors.black,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: Text(
                    'NOMINATE A MEMBER',
                    style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w800,
                      letterSpacing: 1.2, color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          _footer(context),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  Nav 2 — My Schedule
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildMySchedule() {
    const scheduleTabs = ['Upcoming', 'Past'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // sub-tabs
        _subTabBar(
          tabs: scheduleTabs,
          activeIndex: _scheduleTab,
          onTap: (i) => setState(() => _scheduleTab = i),
        ),
        // content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_scheduleTab == 0)
                  Text(
                    'You have no upcoming items in your schedule.',
                    style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  Text(
                    'No past items found.',
                    style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  Nav 3 — Wallet
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildWallet() {
    const walletTabs = ['Payment Methods', 'Tickets', 'Vouchers'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subTabBar(
          tabs: walletTabs,
          activeIndex: _walletTab,
          onTap: (i) => setState(() => _walletTab = i),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: _walletTab == 0
                ? _buildPaymentMethods()
                : _buildEmptyWalletTab(walletTabs[_walletTab]),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Wallet',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
            ),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Add Payment Method — coming soon',
                          style: GoogleFonts.inter(color: Colors.white)),
                      backgroundColor: Colors.black,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: Text(
                  'ADD PAYMENT METHOD',
                  style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w800,
                    letterSpacing: 1.0, color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'No payment methods.',
          style: GoogleFonts.inter(
            fontSize: 13, color: const Color(0xFFC0742A),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 32),
        _footer(context),
      ],
    );
  }

  Widget _buildEmptyWalletTab(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        const SizedBox(height: 16),
        Text(
          'No $label found.',
          style: GoogleFonts.inter(
            fontSize: 13, color: const Color(0xFFC0742A),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 32),
        _footer(context),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  Nav 4 — Billing
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBilling() {
    const billingTabs = ['Statements', 'Dues', 'Orders', 'House Account'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subTabBar(
          tabs: billingTabs,
          activeIndex: _billingTab,
          onTap: (i) => setState(() => _billingTab = i),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: _billingTab == 0
                ? _buildStatements()
                : _buildEmptyBillingTab(billingTabs[_billingTab]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatements() {
    // Sample statement data
    const statements = [
      {'month': 'July 2025', 'transactions': '2 transactions', 'amount': '€13.09'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statements',
          style: GoogleFonts.inter(
              fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        const SizedBox(height: 16),
        ...statements.map((s) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  const Icon(LucideIcons.calendarDays, size: 18, color: Colors.black54),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['month']!,
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s['transactions']!,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: const Color(0xFFC0742A)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    s['amount']!,
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                ],
              ),
            ),
            Divider(color: _divider, height: 1),
          ],
        )),
        const SizedBox(height: 32),
        _footer(context),
      ],
    );
  }

  Widget _buildEmptyBillingTab(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        const SizedBox(height: 16),
        Text(
          'No $label found.',
          style: GoogleFonts.inter(
            fontSize: 13, color: const Color(0xFFC0742A),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 32),
        _footer(context),
      ],
    );
  }

  // ── Shared sub-tab bar (Upcoming/Past, Payment Methods/Tickets etc.) ────────
  Widget _subTabBar({
    required List<String> tabs,
    required int activeIndex,
    required ValueChanged<int> onTap,
  }) {
    return Container(
      color: _bg,
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 24),
              itemBuilder: (_, i) {
                final active = i == activeIndex;
                return GestureDetector(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        tabs[i],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                          color: active ? const Color(0xFFC0742A) : Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        width: active ? 32 : 0,
                        color: const Color(0xFFC0742A),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: _divider),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  Tab 1 — Account Details
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildAccountDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Account Information'),
        const SizedBox(height: 16),

        // First / Last Name
        _row2(
          _fieldCol('First Name', _firstName),
          _fieldCol('Last Name', _lastName),
        ),
        const SizedBox(height: 12),

        // Middle / Email
        _row2(
          _fieldCol('Middle Name', _middleName),
          _fieldCol('Email Address', _email, enabled: false),
        ),
        const SizedBox(height: 12),

        // Birthday / Customer Type
        _row2(
          _fieldCol('Birthday', _birthday),
          _fieldCol('Customer Type', _customerType, enabled: false),
        ),
        const SizedBox(height: 12),

        // Customer Category
        _fieldCol('Customer Category', _customerCategory, enabled: false),
        const SizedBox(height: 12),

        // Company / Job Title
        _row2(
          _fieldCol('Company Name (Optional)', _company),
          _fieldCol('Job Title (Optional)', _jobTitle),
        ),
        const SizedBox(height: 12),

        // Phone / Mobile
        _row2(
          _phoneCol('Phone Number', _phone),
          _phoneCol('Mobile Number', _mobile),
        ),

        const SizedBox(height: 28),
        Divider(color: _divider),
        const SizedBox(height: 16),

        _sectionTitle('Address'),
        const SizedBox(height: 14),

        // Country dropdown
        _labelText('Country'),
        _dropdownField(
          value: _country.isEmpty ? null : _country,
          items: _countryOptions,
          onChanged: (v) => setState(() => _country = v ?? _country),
          hint: 'Select country',
        ),
        const SizedBox(height: 12),

        // Address / Apt
        _row2(
          _fieldCol('Address', _address, flex: 2),
          _fieldCol('Apt # / Suite', _apt),
        ),
        const SizedBox(height: 12),

        // City / Region / Postal
        _row3(
          _fieldCol('City', _city),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _labelText('Region'),
              _dropdownField(
                value: _region.isEmpty ? null : _region,
                items: _regionOptions,
                onChanged: (v) => setState(() => _region = v ?? ''),
                hint: '',
              ),
            ],
          ),
          _fieldCol('Postal Code', _postal),
        ),

        const SizedBox(height: 28),
        _saveBtn(),
        const SizedBox(height: 16),
        _footer(context),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  Tab 2 — Personal Details
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPersonalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information in der APP',
          style: GoogleFonts.inter(
              fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 20),

        _sectionTitle('Interests'),
        const SizedBox(height: 6),
        Text(
          'Use tags to share your interests and preferences',
          style: GoogleFonts.inter(
              fontSize: 12, color: Colors.black45),
        ),
        const SizedBox(height: 12),

        // Interest chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _interests.map((tag) {
            final selected = _selectedInterests.contains(tag);
            return GestureDetector(
              onTap: () => setState(() {
                if (selected) {
                  _selectedInterests.remove(tag);
                } else {
                  _selectedInterests.add(tag);
                }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? Colors.black : Colors.transparent,
                  border: Border.all(
                    color: selected ? Colors.black : Colors.black38,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.black,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),
        _labelText('Collectibles'),
        _dropdownField(
          value: _collectibles,
          items: const ['Cars','Art','Watches','Wine'],
          onChanged: (v) => setState(() => _collectibles = v),
          hint: '',
        ),

        const SizedBox(height: 24),
        _sectionTitle('Additional Information'),
        const SizedBox(height: 14),

        _row2(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _labelText('Prefered Language'),
              _dropdownField(
                value: _prefLang,
                items: const ['English','German','French','Arabic'],
                onChanged: (v) => setState(() => _prefLang = v),
                hint: '',
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _labelText('Newsletter Sprache'),
              _dropdownField(
                value: _newsletterLang,
                items: const ['English','German','French','Arabic'],
                onChanged: (v) => setState(() => _newsletterLang = v),
                hint: '',
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        _sectionTitle('Profile Details'),
        const SizedBox(height: 12),
        _row2(
          _fieldCol('Gender', _gender, enabled: false),
          _fieldCol('Vehicle Choice', _vehicleChoice, enabled: false),
        ),
        const SizedBox(height: 12),
        _row2(
          _fieldCol('Vine Preference', _vinePref, enabled: false),
          _fieldCol('Custom Fields', _customFields, enabled: false),
        ),

        const SizedBox(height: 28),
        _saveBtn(),
        const SizedBox(height: 16),
        _footer(context),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  Tab 3 — Advanced Settings
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildAdvancedSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Communication'),
        const SizedBox(height: 16),

        Row(
          children: [
            Switch(
              value: _emailOptIn,
              onChanged: (v) => setState(() => _emailOptIn = v),
              activeColor: Colors.black,
              activeTrackColor: Colors.black38,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.black12,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'I would like to Opt-in to receive e-mail messages',
                style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.black87),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),
        Divider(color: _divider),
        const SizedBox(height: 16),

        _sectionTitle('Password Update'),
        const SizedBox(height: 16),

        _pwField('Current password',  _currentPw, _showCurrent,
                () => setState(() => _showCurrent = !_showCurrent)),
        const SizedBox(height: 12),
        _pwField('New password',       _newPw,     _showNew,
                () => setState(() => _showNew = !_showNew)),
        const SizedBox(height: 12),
        _pwField('Password confirmation', _confirmPw, _showConfirm,
                () => setState(() => _showConfirm = !_showConfirm)),

        const SizedBox(height: 28),
        _saveBtn(),
        const SizedBox(height: 16),
        _footer(context),
      ],
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────

  Widget _sectionTitle(String t) => Text(
    t,
    style: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
  );

  Widget _labelText(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      t,
      style: GoogleFonts.inter(
          fontSize: 11, color: Colors.black54),
    ),
  );

  Uint8List? _decodeBase64Image(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final cleaned = value.startsWith('data:image')
          ? value.split(',').last
          : value;
      return base64Decode(cleaned);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _buildProfilePayload() {
    return {
      'firstName': _firstName.text.trim(),
      'lastName': _lastName.text.trim(),
      'middleName': _middleName.text.trim(),
      'birthday': _birthday.text.trim(),
      'company': _company.text.trim(),
      'jobTitle': _jobTitle.text.trim(),
      'phone': _phone.text.trim(),
      'mobileNumber': _mobile.text.trim(),
      'country': _country.trim(),
      'address': _address.text.trim(),
      'aptSuite': _apt.text.trim(),
      'city': _city.text.trim(),
      'region': _region.trim(),
      'postalCode': _postal.text.trim(),
      'emailOptIn': _emailOptIn,
    };
  }

  // Plain white text field
  Widget _fieldCol(String label, TextEditingController ctrl,
      {int flex = 1, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelText(label),
        TextField(
          controller: ctrl,
          enabled: enabled,
          style: GoogleFonts.inter(
              fontSize: 13,
              color: enabled ? Colors.black87 : Colors.black54),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                  color: Colors.grey.shade200, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                  color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide:
              BorderSide(color: Colors.black, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  // Phone field with "DE ▼" prefix
  Widget _phoneCol(String label, TextEditingController ctrl,
      {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelText(label),
        Container(
          color: enabled ? Colors.white : Colors.grey.shade100,
          child: Row(
            children: [
              // Country code button
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                        color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Text('DE',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                    const SizedBox(width: 4),
                    const Icon(LucideIcons.chevronDown,
                        size: 12, color: Colors.black54),
                  ],
                ),
              ),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  enabled: enabled,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: enabled ? Colors.black87 : Colors.black54),
                  decoration: InputDecoration(
                    hintText: '+49',
                    filled: true,
                    fillColor: enabled ? Colors.white : Colors.grey.shade100,
                    contentPadding:
                    const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Outer border
        Container(
          height: 1,
          color: Colors.grey.shade200,
        ),
      ],
    );
  }

  // Password field with eye toggle
  Widget _pwField(String label, TextEditingController ctrl,
      bool visible, VoidCallback toggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelText(label),
        TextField(
          controller: ctrl,
          obscureText: !visible,
          style: GoogleFonts.inter(
              fontSize: 13, color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                  color: Colors.grey.shade200, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                  color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide:
              BorderSide(color: Colors.black, width: 1),
            ),
            suffixIcon: GestureDetector(
              onTap: toggle,
              child: Icon(
                visible
                    ? LucideIcons.eyeOff
                    : LucideIcons.eye,
                size: 18,
                color: Colors.black38,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Dropdown
  Widget _dropdownField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? hint,
  }) {
    final menuItems = (value != null &&
            value.isNotEmpty &&
            !items.contains(value))
        ? [value, ...items]
        : items;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
            color: Colors.grey.shade200, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: hint != null
              ? Text(hint,
              style: GoogleFonts.inter(
                  fontSize: 13, color: Colors.black54))
              : null,
          icon: const Icon(LucideIcons.chevronDown,
              size: 16, color: Colors.black54),
          style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500),
          items: menuItems
              .map((e) => DropdownMenuItem(
            value: e,
            child: Text(e),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // 2-column row
  Widget _row2(Widget a, Widget b) {
    return LayoutBuilder(builder: (_, c) {
      if (c.maxWidth < 380) {
        return Column(children: [
          a,
          const SizedBox(height: 12),
          b,
        ]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: a),
          const SizedBox(width: 12),
          Expanded(child: b),
        ],
      );
    });
  }

  // 3-column row
  Widget _row3(Widget a, Widget b, Widget c) {
    return LayoutBuilder(builder: (_, cs) {
      if (cs.maxWidth < 380) {
        return Column(children: [
          a,
          const SizedBox(height: 12),
          b,
          const SizedBox(height: 12),
          c,
        ]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: a),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: b),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: c),
        ],
      );
    });
  }

  // SAVE CHANGES button
  Widget _saveBtn() => SizedBox(
    width: 220,
    height: 48,
    child: ElevatedButton(
      onPressed: () async {
        final auth = context.read<AuthProvider>();

        final hasPw =
            _currentPw.text.isNotEmpty || _newPw.text.isNotEmpty || _confirmPw.text.isNotEmpty;
        if (hasPw) {
          if (_newPw.text != _confirmPw.text) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('New password and confirmation do not match!',
                    style: GoogleFonts.inter(color: Colors.white)),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
            );
            return;
          }

          final pwSuccess = await auth.changePassword(
            currentPassword: _currentPw.text.trim(),
            newPassword:     _newPw.text.trim(),
            confirmPassword: _confirmPw.text.trim(),
          );

          if (!mounted) return;

          if (pwSuccess) {
            _currentPw.clear();
            _newPw.clear();
            _confirmPw.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password changed successfully!',
                    style: GoogleFonts.inter(color: Colors.white)),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(auth.errorMessage,
                    style: GoogleFonts.inter(color: Colors.white)),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
            );
            return;
          }
        }

        final profileSuccess = await auth.updateProfile(_buildProfilePayload());
        if (!mounted) return;

        if (profileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully!',
                  style: GoogleFonts.inter(color: Colors.white)),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(auth.errorMessage,
                  style: GoogleFonts.inter(color: Colors.white)),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        elevation: 0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero),
      ),
      child: Text(
        'SAVE CHANGES',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: Colors.white,
        ),
      ),
    ),
  );

  // Footer
  Widget _footer(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black87, width: 2),
        ),
        child: const Center(
          child: Icon(LucideIcons.crown,
              size: 12, color: Colors.black87),
        ),
      ),
      HoverCursor(
        child: GestureDetector(
          onTap: ExternalLinks.openInstagram,
          child: const Icon(LucideIcons.instagram,
              size: 18, color: Colors.black54),
        ),
      ),
      Row(
        children: ['FAQ','Terms','Privacy'].map((l) => Padding(
          padding: const EdgeInsets.only(left: 16),
          child: HoverCursor(
            child: GestureDetector(
              onTap: () => _showComingSoon(context),
              child: Text(l,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.black54)),
            ),
          ),
        )).toList(),
      ),
    ],
  );

  Widget _sheetTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return HoverCursor(
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : Colors.black87),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Coming soon',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Outlined square icon button (shared)
// ─────────────────────────────────────────────────────────────────────────────
class _OutlinedIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _OutlinedIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => HoverCursor(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    ),
  );
}
