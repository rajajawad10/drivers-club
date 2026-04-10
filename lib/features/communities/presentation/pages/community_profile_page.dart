import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:pitstop/core/app_theme.dart';
import 'package:pitstop/core/providers/user_provider.dart';
import 'package:pitstop/core/storage/secure_storage.dart';
import 'package:pitstop/core/web_routes.dart';
import 'package:pitstop/core/web_utils.dart';
import 'package:pitstop/features/auth/presentation/providers/auth_provider.dart';
import 'package:pitstop/features/auth/data/auth_model.dart';
import 'package:pitstop/features/communities/data/community_model.dart';

class CommunityProfilePage extends StatefulWidget {
  const CommunityProfilePage({super.key});

  @override
  State<CommunityProfilePage> createState() => _CommunityProfilePageState();
}

class _CommunityProfilePageState extends State<CommunityProfilePage> {
  static const _cardBorder = Color(0xFFE5E7EB);

  final _aboutController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _locationController = TextEditingController();
  final _companyController = TextEditingController();
  final _customInterestController = TextEditingController();
  final _picker = ImagePicker();

  Uint8List? _avatarBytes;
  /// Avatar bytes from backend (`avatarBase64`) after [AuthProvider.loadProfile].
  Uint8List? _serverAvatarBytes;
  bool _aboutSaved = false;
  bool _saved = false;
  bool _showCustomInput = false;
  bool _profileVisible = true;
  bool _showActivity = true;

  final List<String> _selectedInterests = [];
  final List<_InterestOption> _extraInterests = [];

  static const _predefinedInterests = [
    _InterestOption(label: '🏎 Track Days', value: 'track_days'),
    _InterestOption(label: '⛳ Golf', value: 'golf'),
    _InterestOption(label: '🍷 Dining', value: 'dining'),
    _InterestOption(label: '🏛 Classic Cars', value: 'classic_cars'),
    _InterestOption(label: '✈️ Travel', value: 'travel'),
    _InterestOption(label: '⚽ Sports', value: 'sports'),
    _InterestOption(label: '📸 Photography', value: 'photography'),
    _InterestOption(label: '🎾 Tennis', value: 'tennis'),
    _InterestOption(label: '🎵 Music', value: 'music'),
    _InterestOption(label: '🍳 Cooking', value: 'cooking'),
  ];

  List<_InterestOption> get _allInterests =>
      [..._predefinedInterests, ..._extraInterests];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrateFromBackend());
  }

  Future<void> _hydrateFromBackend() async {
    final auth = context.read<AuthProvider>();
    await auth.loadProfile();
    if (!mounted) return;
    final user = auth.currentUser;
    _serverAvatarBytes = user != null ? _decodeUserAvatar(user) : null;
    _seedFieldsFromUser();
    await _loadProfileDraft();
    if (mounted) setState(() {});
  }

  Uint8List? _decodeUserAvatar(UserModel user) {
    final raw = user.avatarBase64?.trim();
    if (raw == null || raw.isEmpty) return null;
    try {
      final pure = raw.contains(',') ? raw.split(',').last : raw;
      return base64Decode(pure);
    } catch (_) {
      return null;
    }
  }

  String _accountSubtitle(UserModel? user) {
    final email = (user?.email ?? '').trim();
    if (email.isNotEmpty) return email;
    return 'Community profile';
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _vehicleController.dispose();
    _locationController.dispose();
    _companyController.dispose();
    _customInterestController.dispose();
    super.dispose();
  }

  void _seedFieldsFromUser() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final location = [
      user.city,
      user.country,
    ].where((e) => e.toString().trim().isNotEmpty).join(', ');
    _locationController.text = location;
    _companyController.text = user.company ?? '';
    _vehicleController.text = user.vehicleChoice ?? '';
  }

  Future<void> _loadProfileDraft() async {
    final bio = await SecureStorage.getMemberBio();
    final tags = await SecureStorage.getInterestTags();
    if (!mounted) return;
    setState(() {
      _aboutController.text = bio;
      _selectedInterests
        ..clear()
        ..addAll(tags);
    });
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 900,
      maxHeight: 900,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    context.read<UserProvider>().updateProfileImageBytes(bytes);
    setState(() => _avatarBytes = bytes);
  }

  Future<void> _saveAbout() async {
    await SecureStorage.saveMemberBio(_aboutController.text.trim());
    if (!mounted) return;
    setState(() => _aboutSaved = true);
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _aboutSaved = false);
    });
  }

  Future<void> _saveAll() async {
    await SecureStorage.saveMemberBio(_aboutController.text.trim());
    await SecureStorage.saveInterestTags(_selectedInterests);
    final auth = context.read<AuthProvider>();
    if (_avatarBytes != null) {
      final base64 = base64Encode(_avatarBytes!);
      final dataUri = 'data:image/jpeg;base64,$base64';
      var ok = await auth.updateAvatar(dataUri);
      if (!ok) {
        ok = await auth.updateAvatar(base64);
      }
      if (ok && mounted) {
        setState(() => _avatarBytes = null);
      }
    }
    await auth.loadProfile();
    if (!mounted) return;
    final u = auth.currentUser;
    setState(() {
      _serverAvatarBytes = u != null ? _decodeUserAvatar(u) : null;
      _seedFieldsFromUser();
      _saved = true;
    });
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  void _toggleInterest(String value) {
    setState(() {
      if (_selectedInterests.contains(value)) {
        _selectedInterests.remove(value);
      } else {
        _selectedInterests.add(value);
      }
    });
  }

  void _addCustomInterest() {
    final trimmed = _customInterestController.text.trim();
    if (trimmed.isEmpty) return;
    final value = trimmed.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    setState(() {
      _extraInterests.add(_InterestOption(label: trimmed, value: value));
      _selectedInterests.add(value);
      _customInterestController.clear();
      _showCustomInput = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final member = CommunityMember(
      userId: user?.id ?? 'me',
      fullName: user?.fullName ?? 'Member',
      avatarUrl: user?.avatarUrl,
      joinedAt: DateTime.now(),
      interestCategories: _selectedInterests,
    );

    final body = _buildBody(member, user);
    if (kIsWeb) {
      return WebScaffold(
        title: 'Profile',
        selected: WebNavItem.communities,
        onNavSelected: _handleWebNav(context),
        child: body,
        showFooter: false,
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.lightBackground,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'PROFILE',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveAll,
            child: Text(
              _saved ? '✓ Saved' : 'Save',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.secondaryColor,
              ),
            ),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildBody(CommunityMember member, UserModel? user) {
    final isWeb = kIsWeb;
    final padding = isWeb
        ? const EdgeInsets.fromLTRB(20, 16, 20, 28)
        : const EdgeInsets.fromLTRB(16, 12, 16, 28);
    final sectionGap = isWeb ? 14.0 : 12.0;
    if (isWeb) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'PROFILE',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: _saveAll,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.black.withOpacity(0.2)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _saved ? '✓ Saved' : 'Save changes',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _heroCard(),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _summaryCard(member, user)),
                  const SizedBox(width: 12),
                  Expanded(child: _aboutCard()),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _interestsCard(),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _detailsCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _privacyCard()),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _updateProfileButton(),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heroCard(),
          SizedBox(height: sectionGap),
          _summaryCard(member, user),
          SizedBox(height: sectionGap),
          _aboutCard(),
          SizedBox(height: sectionGap),
          _interestsCard(),
          SizedBox(height: sectionGap),
          _detailsCard(),
          SizedBox(height: sectionGap),
          _privacyCard(),
          SizedBox(height: sectionGap + 2),
          _updateProfileButton(),
        ],
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryColor,
            AppTheme.secondaryColor.withOpacity(0.65),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Profile',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Keep your community profile updated.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(CommunityMember member, UserModel? user) {
    final avatar = _avatarBytes ??
        context.watch<UserProvider>().profileImageBytes ??
        _serverAvatarBytes;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.secondaryColor,
                      AppTheme.secondaryColor.withOpacity(0.7),
                    ],
                  ),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: avatar != null
                      ? Image.memory(avatar, fit: BoxFit.cover)
                      : (member.avatarUrl != null &&
                              member.avatarUrl!.trim().isNotEmpty
                          ? Image.network(
                              member.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                LucideIcons.user,
                                color: Colors.white,
                                size: 32,
                              ),
                            )
                          : const Icon(LucideIcons.user,
                              color: Colors.white, size: 32)),
                ),
              ),
              GestureDetector(
                onTap: _pickAvatar,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(LucideIcons.camera,
                      size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.fullName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Gold',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _accountSubtitle(user),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.edit2,
                      size: 14, color: AppTheme.secondaryColor),
                  label: Text(
                    'Edit name',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _pickAvatar,
            icon: const Icon(LucideIcons.edit2,
                size: 16, color: AppTheme.secondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _aboutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              TextField(
                controller: _aboutController,
                maxLines: 3,
                maxLength: 150,
                decoration: InputDecoration(
                  hintText: 'Tell other members a bit about yourself...',
                  filled: true,
                  fillColor: AppTheme.lightBackground,
                  prefixIcon: const Icon(LucideIcons.info, size: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  counterStyle:
                      GoogleFonts.inter(fontSize: 11, color: Colors.black54),
                  contentPadding:
                      const EdgeInsets.fromLTRB(12, 12, 12, 12),
                ),
                style: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${_aboutController.text.length}/150',
                style: GoogleFonts.inter(fontSize: 11, color: Colors.black45),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: _saveAbout,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: _aboutSaved
                          ? Colors.green
                          : AppTheme.secondaryColor),
                  backgroundColor:
                      _aboutSaved ? Colors.green : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _aboutSaved ? '✓ Saved' : 'Save',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        _aboutSaved ? Colors.white : AppTheme.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _interestsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Interests',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              if (_selectedInterests.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _selectedInterests.clear()),
                  child: Text(
                    'Clear all',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._allInterests.map((interest) {
                final isSelected =
                    _selectedInterests.contains(interest.value);
                return GestureDetector(
                  onTap: () => _toggleInterest(interest.value),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? Colors.black : AppTheme.lightBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.black : _cardBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          interest.label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black54,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.x,
                              size: 12, color: Colors.white),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              if (_showCustomInput)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _customInterestController,
                        autofocus: true,
                        onSubmitted: (_) => _addCustomInterest(),
                        decoration: InputDecoration(
                          hintText: 'Type interest',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                                BorderSide(color: AppTheme.secondaryColor),
                          ),
                        ),
                        style: GoogleFonts.inter(fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: _addCustomInterest,
                      icon: const Icon(LucideIcons.check,
                          size: 14, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() {
                        _showCustomInput = false;
                        _customInterestController.clear();
                      }),
                      icon: const Icon(LucideIcons.x,
                          size: 14, color: Colors.black54),
                    ),
                  ],
                )
              else
                TextButton.icon(
                  onPressed: () => setState(() => _showCustomInput = true),
                  icon: const Icon(LucideIcons.plus, size: 14),
                  label: Text(
                    'Add',
                    style: GoogleFonts.inter(fontSize: 11),
                  ),
                ),
            ],
          ),
          if (_selectedInterests.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'No interests selected. Tap to add your interests.',
                style: GoogleFonts.inter(fontSize: 11, color: Colors.black45),
              ),
            ),
        ],
      ),
    );
  }

  Widget _detailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Details',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 0.8,
              ),
            ),
          ),
          _detailRow(
            icon: LucideIcons.mapPin,
            iconBg: const Color(0xFFFAEEDA),
            iconColor: const Color(0xFF854F0B),
            label: 'Location',
            controller: _locationController,
            placeholder: 'Your city, country...',
          ),
          _detailRow(
            icon: LucideIcons.briefcase,
            iconBg: const Color(0xFFE6F1FB),
            iconColor: const Color(0xFF185FA5),
            label: 'Company',
            controller: _companyController,
            placeholder: 'Where do you work?',
          ),
          _detailRow(
            icon: LucideIcons.car,
            iconBg: const Color(0xFFEEEDFE),
            iconColor: const Color(0xFF534AB7),
            label: 'Vehicle',
            controller: _vehicleController,
            placeholder: 'e.g. Porsche 911, BMW M3...',
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required TextEditingController controller,
    required String placeholder,
    bool showDivider = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                top: BorderSide(color: Color(0xFFF2F2F2)),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: placeholder,
                    border: InputBorder.none,
                    isDense: true,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black26,
                    ),
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _privacyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _privacyRow(
            icon: LucideIcons.shield,
            iconBg: const Color(0xFFEAF3DE),
            iconColor: const Color(0xFF3B6D11),
            title: 'Profile visibility',
            subtitle: 'Visible to community members',
            value: _profileVisible,
            onChanged: (v) => setState(() => _profileVisible = v),
          ),
          const SizedBox(height: 12),
          _privacyRow(
            icon: LucideIcons.bell,
            iconBg: const Color(0xFFE6F1FB),
            iconColor: const Color(0xFF185FA5),
            title: 'Show activity status',
            subtitle: 'Let others see when you’re online',
            value: _showActivity,
            onChanged: (v) => setState(() => _showActivity = v),
          ),
        ],
      ),
    );
  }

  Widget _privacyRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: Colors.black,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.black12,
        ),
      ],
    );
  }

  Widget _updateProfileButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveAll,
        style: ElevatedButton.styleFrom(
          backgroundColor: _saved ? Colors.green : Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          _saved ? '✓ Profile Updated' : 'Update Profile',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void Function(WebNavItem) _handleWebNav(BuildContext context) {
    return (item) {
      final route = switch (item) {
        WebNavItem.newsfeed => WebRoutes.newsfeed,
        WebNavItem.events => WebRoutes.events,
        WebNavItem.dining => WebRoutes.dining,
        WebNavItem.bookRoom => WebRoutes.bookRoom,
        WebNavItem.clubHouse => WebRoutes.clubHouse,
        WebNavItem.clubBenefits => WebRoutes.clubBenefits,
        WebNavItem.communities => WebRoutes.communities,
      };
      Navigator.pushReplacementNamed(context, route);
    };
  }
}

class _InterestOption {
  final String label;
  final String value;

  const _InterestOption({required this.label, required this.value});
}
