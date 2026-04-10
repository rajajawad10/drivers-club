import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:pitstop/core/app_theme.dart';
import 'package:pitstop/core/storage/secure_storage.dart';
import 'package:pitstop/core/responsive.dart';
import 'package:pitstop/core/web_routes.dart';
import 'package:pitstop/core/web_utils.dart';
import 'package:pitstop/features/auth/presentation/providers/auth_provider.dart';
import 'package:pitstop/features/communities/data/community_model.dart';
import 'package:pitstop/features/communities/presentation/providers/communities_provider.dart';
import 'package:pitstop/features/communities/presentation/pages/community_detail_page.dart';
import 'package:pitstop/features/communities/presentation/pages/staff_interest_finder_page.dart';
import 'package:pitstop/features/communities/presentation/pages/community_profile_page.dart';

class CommunitiesPage extends StatefulWidget {
  const CommunitiesPage({super.key});

  @override
  State<CommunitiesPage> createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage> {
  final _searchCtrl = TextEditingController();
  final Set<String> _joining = {};
  List<String> _selectedInterests = [];
  static const _fallbackInterests = [
    'Racing',
    'Dining',
    'Events',
    'Sports',
    'Travel',
    'Wine',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<CommunitiesProvider>();
      await provider.loadAllCommunities();
      await provider.loadMyCommunities();
      await _loadInterestTags();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            _tabs(),
            if (kIsWeb)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.72,
                child: _tabBody(),
              )
            else
              Expanded(child: _tabBody()),
          ],
        ),
      ),
    );

    if (kIsWeb) {
      return WebScaffold(
        title: 'Communities',
        selected: WebNavItem.communities,
        onNavSelected: _handleWebNav,
        onProfileTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CommunityProfilePage()),
        ),
        child: Material(
          color: Colors.transparent,
          child: content,
        ),
        showFooter: false,
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: content,
    );
  }

  Widget _header(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = (auth.currentUser?.role ?? '').toLowerCase();
    final isStaff = role == 'staff' || role == 'admin';
    if (kIsWeb) {
      return const SizedBox.shrink();
    }
    final canPop = Navigator.of(context).canPop();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
      child: Row(
        children: [
          if (canPop)
            IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          Expanded(
            child: Text(
              'COMMUNITIES',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          if (isStaff)
            HoverCursor(
              child: IconButton(
                tooltip: 'Staff Interest Finder',
                icon: const Icon(LucideIcons.shield, color: Colors.black),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StaffInterestFinderPage()),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(LucideIcons.user, color: Colors.black),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CommunityProfilePage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return TabBar(
      labelColor: Colors.black,
      unselectedLabelColor: Colors.black,
      indicatorColor: AppTheme.secondaryColor,
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
      tabs: const [
        Tab(text: 'Explore'),
        Tab(text: 'My Communities'),
      ],
    );
  }

  Widget _tabBody() {
    return TabBarView(
      children: [
        _communityList(isMyTab: false),
        _communityList(isMyTab: true),
      ],
    );
  }

  Widget _communityList({required bool isMyTab}) {
    return Consumer<CommunitiesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.secondaryColor),
          );
        }

        if (provider.error != null && provider.error!.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppTheme.errorColor,
                content: Text(provider.error!,
                    style: GoogleFonts.inter(color: AppTheme.lightSurface)),
              ),
            );
          });
        }

        final list = isMyTab
            ? provider.myCommunities.where((c) => c.isJoined).toList()
            : provider.allCommunities;

        if (list.isEmpty) {
          return _emptyState(isMyTab);
        }

        if (kIsWeb) {
          return _webCommunityList(provider, list, isMyTab);
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _searchBar(provider)),
            if (!isMyTab) ...[
              SliverToBoxAdapter(child: _interestModule(provider)),
              SliverToBoxAdapter(child: _interestFilter(provider)),
              SliverToBoxAdapter(child: _categories(provider)),
            ],
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final community = list[index];
                    return _CommunityCard(
                      community: community,
                      isLoading: _joining.contains(community.id),
                      showActivityDot:
                          isMyTab && _isRecentActivity(community.lastActivity),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CommunityDetailPage(communityId: community.id),
                        ),
                      ),
                      onJoinToggle: () => _toggleJoin(provider, community),
                    );
                  },
                  childCount: list.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _searchBar(CommunitiesProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: provider.setSearchQuery,
        cursorColor: Colors.black,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Search communities...',
          hintStyle: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.black54,
          ),
          prefixIcon: const Icon(LucideIcons.search, color: Colors.black54),
          filled: true,
          fillColor: AppTheme.lightSurface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.lightBackground),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.lightBackground),
          ),
        ),
      ),
    );
  }

  Widget _interestFilter(CommunitiesProvider provider) {
    final options = provider.categories.where((c) => c != 'All').toList();
    final selected = _selectedInterests.isNotEmpty
        ? _selectedInterests
        : provider.selectedInterests;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: GestureDetector(
        onTap: () async {
          final updated =
              await _showInterestPicker(context, options, selected);
          if (updated != null) {
            setState(() => _selectedInterests = updated);
            provider.setSelectedInterests(updated);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.secondaryColor),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.filter, size: 16, color: Colors.black),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selected.isEmpty
                      ? 'Filter by interests'
                      : selected.join(', '),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (selected.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() => _selectedInterests = []);
                    provider.clearSelectedInterests();
                  },
                  child: const Icon(LucideIcons.x, size: 16, color: Colors.black),
                ),
              const SizedBox(width: 6),
              const Icon(LucideIcons.chevronDown, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categories(CommunitiesProvider provider) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = provider.categories[index];
          final active = provider.selectedCategory == category;
          return GestureDetector(
            onTap: () => provider.setCategory(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppTheme.secondaryColor : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.secondaryColor),
              ),
              child: Text(
                category,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _loadInterestTags() async {
    final tags = await SecureStorage.getInterestTags();
    if (!mounted) return;
    setState(() => _selectedInterests = tags);
  }

  Widget _emptyState(bool isMyTab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.users, size: 48, color: AppTheme.secondaryColor),
          const SizedBox(height: 12),
          Text(
            isMyTab
                ? "You haven't joined any communities yet. Explore and join ones that interest you!"
                : 'No communities found.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.black),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleJoin(
      CommunitiesProvider provider, CommunityModel community) async {
    setState(() => _joining.add(community.id));
    if (community.isJoined) {
      await provider.leaveCommunity(community.id);
    } else {
      await provider.joinCommunity(community.id);
    }
    if (mounted) {
      setState(() => _joining.remove(community.id));
    }
  }

  bool _isRecentActivity(String? lastActivity) {
    if (lastActivity == null) return false;
    return lastActivity.contains('hour') || lastActivity.contains('min');
  }

  int _webCommunityGridColumns(double width) {
    if (width >= 1100) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  Widget _interestModule(CommunitiesProvider provider) {
    final options = provider.categories.where((c) => c != 'All').toList();
    final list = options.isEmpty ? _fallbackInterests : options;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.secondaryColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                      isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Interests',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Use interests to personalize community results.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HoverCursor(
                      child: OutlinedButton(
                        onPressed: () async {
                          final selected = await _showInterestPicker(
                              context, list, _selectedInterests);
                          if (selected == null) return;
                          await SecureStorage.saveInterestTags(selected);
                          await SecureStorage.setInterestOnboarded(true);
                          if (mounted) {
                            setState(() => _selectedInterests = selected);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.secondaryColor),
                        ),
                        child: Text(
                          _selectedInterests.isEmpty ? 'ADD' : 'EDIT',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_selectedInterests.isEmpty)
                  Text(
                    'No interests selected yet.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.secondaryColor,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedInterests.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tag,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 6),
                            HoverCursor(
                              child: GestureDetector(
                                onTap: () async {
                                  final updated = [..._selectedInterests]
                                    ..remove(tag);
                                  await SecureStorage.saveInterestTags(updated);
                                  if (mounted) {
                                    setState(
                                        () => _selectedInterests = updated);
                                  }
                                },
                                child: const Icon(
                                  LucideIcons.x,
                                  size: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _webCommunityList(
    CommunitiesProvider provider,
    List<CommunityModel> list,
    bool isMyTab,
  ) {
    final totalMembers =
        list.fold<int>(0, (sum, c) => sum + c.memberCount);
    final activeDiscussions = list.length * 12;
    if (isMyTab) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final crossAxisCount = _webCommunityGridColumns(w);
          final hPad = w < kWebNavDrawerBreakpoint ? 12.0 : 16.0;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _webSearchBar(provider),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final community = list[index];
                    return _WebCommunityCard(
                      community: community,
                      isLoading: _joining.contains(community.id),
                      showActivityDot:
                          isMyTab && _isRecentActivity(community.lastActivity),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CommunityDetailPage(communityId: community.id),
                        ),
                      ),
                      onJoinToggle: () => _toggleJoin(provider, community),
                      formatCount: _formatCount,
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final wide = w >= 900;
        final crossAxisCount = _webCommunityGridColumns(w);
        final hPad = w < kWebNavDrawerBreakpoint ? 12.0 : 16.0;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _webHeroBanner(),
              const SizedBox(height: 16),
              _interestModule(provider),
              const SizedBox(height: 12),
              if (wide)
                Row(
                  children: [
                    Expanded(child: _webSearchBar(provider)),
                    const SizedBox(width: 12),
                    _webCategoryDropdown(provider),
                  ],
                )
              else ...[
                _webSearchBar(provider),
                const SizedBox(height: 12),
                _webCategoryDropdown(provider),
              ],
              const SizedBox(height: 12),
              _webCategoryChips(provider),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.6,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final community = list[index];
                  return _WebCommunityCard(
                    community: community,
                    isLoading: _joining.contains(community.id),
                    showActivityDot:
                        isMyTab && _isRecentActivity(community.lastActivity),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CommunityDetailPage(communityId: community.id),
                      ),
                    ),
                    onJoinToggle: () => _toggleJoin(provider, community),
                    formatCount: _formatCount,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _webHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, AppTheme.secondaryColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover Your Community',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Join thousands of like‑minded individuals, share knowledge, and grow together.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.lightSurface.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _webSearchBar(CommunitiesProvider provider) {
    return TextField(
      controller: _searchCtrl,
      onChanged: provider.setSearchQuery,
      decoration: InputDecoration(
        hintText: 'Search communities...',
        prefixIcon: const Icon(LucideIcons.search),
        filled: true,
        fillColor: AppTheme.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.lightBackground),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.lightBackground),
        ),
      ),
    );
  }

  Widget _webCategoryDropdown(CommunitiesProvider provider) {
    return PopupMenuButton<String>(
      onSelected: provider.setCategory,
      itemBuilder: (context) => provider.categories
          .map((c) => PopupMenuItem<String>(
                value: c,
                child: Text(c, style: GoogleFonts.inter()),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.lightBackground),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.filter, size: 16),
            const SizedBox(width: 8),
            Text(
              provider.selectedCategory,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(LucideIcons.chevronDown, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _webCategoryChips(CommunitiesProvider provider) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: provider.categories.map((category) {
        final active = provider.selectedCategory == category;
        return GestureDetector(
          onTap: () => provider.setCategory(category),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: active ? AppTheme.secondaryColor : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.secondaryColor),
            ),
            child: Text(
              category,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.black),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCount(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }

  Future<List<String>?> _showInterestPicker(
    BuildContext context,
    List<String> options,
    List<String> selected,
  ) async {
    final temp = [...selected];
    return showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: AppTheme.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select interests',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final item = options[index];
                        final checked = temp.contains(item);
                        return CheckboxListTile(
                          value: checked,
                          activeColor: AppTheme.secondaryColor,
                          title: Text(
                            item,
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          ),
                          onChanged: (v) {
                            setModalState(() {
                              if (v == true) {
                                temp.add(item);
                              } else {
                                temp.remove(item);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, temp),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                        ),
                        child: Text(
                          'DONE',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  void _handleWebNav(WebNavItem item) {
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
  }
}

class _CommunityCard extends StatelessWidget {
  final CommunityModel community;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onJoinToggle;
  final bool showActivityDot;

  const _CommunityCard({
    required this.community,
    required this.isLoading,
    required this.onTap,
    required this.onJoinToggle,
    required this.showActivityDot,
  });

  @override
  Widget build(BuildContext context) {
    final joined = community.isJoined;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _categoryIcon(community),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          community.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (showActivityDot)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                        color: AppTheme.errorColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${community.memberCount} members · ${community.category}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    community.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if ((community.lastActivity ?? '').isNotEmpty)
                    Text(
                      'Active ${community.lastActivity}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : onJoinToggle,
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            joined ? Colors.black : AppTheme.lightSurface,
                        side: BorderSide(color: AppTheme.secondaryColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.secondaryColor,
                              ),
                            )
                          : Text(
                              joined ? '✓ Joined' : 'Join',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: joined ? Colors.white : Colors.black,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryIcon(CommunityModel community) {
    final icon = _iconForCategory(community.category);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.black, size: 22),
    );
  }

  IconData _iconForCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('golf')) return LucideIcons.trophy;
    if (c.contains('dining') || c.contains('wine')) return LucideIcons.utensils;
    if (c.contains('race') || c.contains('track')) return LucideIcons.flag;
    if (c.contains('car')) return LucideIcons.car;
    if (c.contains('sports')) return LucideIcons.trophy;
    return LucideIcons.users;
  }
}

class _WebCommunityCard extends StatelessWidget {
  final CommunityModel community;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onJoinToggle;
  final bool showActivityDot;
  final String Function(int) formatCount;

  const _WebCommunityCard({
    required this.community,
    required this.isLoading,
    required this.onTap,
    required this.onJoinToggle,
    required this.showActivityDot,
    required this.formatCount,
  });

  @override
  Widget build(BuildContext context) {
    final joined = community.isJoined;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    community.coverImageUrl == null
                        ? Container(
                            color: AppTheme.secondaryColor.withOpacity(0.2),
                          )
                        : Image.network(
                            community.coverImageUrl!,
                            fit: BoxFit.cover,
                          ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          community.category,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    if (showActivityDot)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.lightSurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Trending',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    community.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    community.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(LucideIcons.users, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        formatCount(community.memberCount),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(LucideIcons.messageCircle, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        formatCount(community.memberCount ~/ 5 + 20),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: isLoading ? null : onJoinToggle,
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              joined ? Colors.black : AppTheme.lightSurface,
                          side: BorderSide(color: AppTheme.secondaryColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.secondaryColor,
                                ),
                              )
                            : Text(
                                joined ? 'Joined' : 'Join',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      joined ? Colors.white : Colors.black,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
