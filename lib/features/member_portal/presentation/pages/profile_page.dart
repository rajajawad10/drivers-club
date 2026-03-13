import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'notifications_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pitstop/core/providers/user_provider.dart';


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
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  static const _bg      = Color(0xFFF5F5F5);
  static const _divider = Color(0xFFBFBDB7);

  // ── State ──────────────────────────────────────────────────────────────────
  int _navIndex       = 1;  // Profile selected
  int _tabIndex       = 0;  // Account Details sub-tab
  int _scheduleTab    = 0;  // 0=Upcoming, 1=Past
  int _walletTab      = 0;  // 0=Payment Methods, 1=Tickets, 2=Vouchers
  int _billingTab     = 0;  // 0=Statements, 1=Dues, 2=Orders, 3=House Account

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File selectedFile = File(pickedFile.path);

      // 1. Provider ko update karein (Ye Home page ko notify karega)
      Provider.of<UserProvider>(context, listen: false).updateProfileImage(selectedFile);

      // 2. Local state update karein (Isi page ke liye)
      setState(() {
        _profileImage = selectedFile;
      });
    }
  }

  static const _navItems = [
    'Memberships', 'Profile', 'My Schedule', 'Wallet', 'Billing',
  ];
  static const _tabs = [
    'Account Details', 'Personal Details', 'Advanced Settings',
  ];

  // Account Details form controllers
  final _firstName   = TextEditingController();
  final _lastName    = TextEditingController();
  final _middleName  = TextEditingController();
  final _email       = TextEditingController();
  final _company     = TextEditingController();
  final _jobTitle    = TextEditingController();
  final _phone       = TextEditingController();
  final _mobile      = TextEditingController();
  final _address     = TextEditingController();
  final _apt         = TextEditingController();
  final _city        = TextEditingController();
  final _postal      = TextEditingController();
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

  @override
  void dispose() {
    for (final c in [_firstName,_lastName,_middleName,_email,_company,
      _jobTitle,_phone,_mobile,_address,_apt,_city,_postal,
      _currentPw,_newPw,_confirmPw]) {
      c.dispose();
    }
    super.dispose();
  }

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
                _OutlinedIcon(icon: LucideIcons.calendar, onTap: () {}),
              ],
            ),
          ),

          // ── User row ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: userProvider.profileImage != null
                            ? FileImage(userProvider.profileImage!)
                            : (_profileImage != null
                            ? FileImage(_profileImage!)
                            : const AssetImage('assets/images/user_profile.png') as ImageProvider),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ammar Raja',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'ammar.raja1@gmail.com',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.logOut,
                    size: 20, color: Colors.black54),
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
          _footer(),
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
        _footer(),
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
        _footer(),
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
        _footer(),
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
        _footer(),
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
          _fieldCol('Email Address', _email),
        ),
        const SizedBox(height: 12),

        // Company / Job Title
        _row2(
          _fieldCol('Company Name (Optional)', _company),
          _fieldCol('Job Title (Optional)', _jobTitle),
        ),
        const SizedBox(height: 12),

        // Phone / Mobile
        _row2(
          _phoneCol('Phone Number'),
          _phoneCol('Mobile Number'),
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
          items: const ['Germany', 'Pakistan', 'USA', 'UK', 'France'],
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
                items: const ['Baden-Württemberg','Bavaria','Berlin','Hamburg'],
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
        _footer(),
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

        const SizedBox(height: 28),
        _saveBtn(),
        const SizedBox(height: 16),
        _footer(),
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
        _footer(),
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

  // Plain white text field
  Widget _fieldCol(String label, TextEditingController ctrl,
      {int flex = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelText(label),
        TextField(
          controller: ctrl,
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
          ),
        ),
      ],
    );
  }

  // Phone field with "DE ▼" prefix
  Widget _phoneCol(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelText(label),
        Container(
          color: Colors.white,
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
                  style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: '+49',
                    filled: true,
                    fillColor: Colors.white,
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
          items: items
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
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Changes saved!',
                style: GoogleFonts.inter(
                    color: Colors.white)),
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
  Widget _footer() => Row(
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
      const Icon(LucideIcons.instagram,
          size: 18, color: Colors.black54),
      Row(
        children: ['FAQ','Terms','Privacy'].map((l) => Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(l,
              style: GoogleFonts.inter(
                  fontSize: 12, color: Colors.black54)),
        )).toList(),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Outlined square icon button (shared)
// ─────────────────────────────────────────────────────────────────────────────
class _OutlinedIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _OutlinedIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 18, color: Colors.black87),
    ),
  );
}
