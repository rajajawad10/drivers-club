import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pitstop/core/app_theme.dart';
import 'package:pitstop/features/communities/data/community_model.dart';
import 'package:pitstop/features/communities/data/community_repository.dart';
import 'package:pitstop/features/communities/presentation/providers/communities_provider.dart';
import 'package:provider/provider.dart';

class StaffInterestFinderPage extends StatefulWidget {
  const StaffInterestFinderPage({super.key});

  @override
  State<StaffInterestFinderPage> createState() =>
      _StaffInterestFinderPageState();
}

class _StaffInterestFinderPageState extends State<StaffInterestFinderPage> {
  final _repo = CommunityRepository();
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';
  List<_MemberRow> _members = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<CommunitiesProvider>();
      if (provider.allCommunities.isEmpty) {
        await provider.loadAllCommunities();
      }
      _selectedCategory = provider.categories.first;
      await _loadMembers();
    });
  }

  Future<void> _loadMembers() async {
    setState(() => _loading = true);
    final provider = context.read<CommunitiesProvider>();
    final communities = provider.allCommunities;
    final filtered = _selectedCategory == 'All'
        ? communities
        : communities
            .where((c) => c.category == _selectedCategory)
            .toList();
    final result = <_MemberRow>[];
    for (final community in filtered) {
      final members = await _repo.getCommunityMembers(community.id);
      for (final m in members) {
        result.add(_MemberRow(
          member: m,
          communityName: community.name,
          communityCategory: community.category,
          interestCategories: m.interestCategories,
        ));
      }
    }
    setState(() {
      _members = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunitiesProvider>();
    final categories = provider.categories;
    final filteredMembers = _applyMemberSearch(_members);

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Interest Finder',
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Text(
              'Find members interested in:',
              style: GoogleFonts.inter(color: AppTheme.primaryColor),
            ),
          ),
          _categoryChips(categories),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search members...',
                prefixIcon: const Icon(LucideIcons.search),
                filled: true,
                fillColor: AppTheme.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.lightBackground),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(
              '${filteredMembers.length} members interested in $_selectedCategory',
              style: GoogleFonts.inter(
                color: AppTheme.secondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.secondaryColor),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: filteredMembers.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildScoreboard(filteredMembers);
                      }
                      return _memberTile(filteredMembers[index - 1]);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _notifyAll(filteredMembers),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                ),
                child: Text(
                  'NOTIFY ALL (${filteredMembers.length})',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => _exportList(filteredMembers),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryColor),
                ),
                child: Text(
                  'EXPORT LIST',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChips(List<String> categories) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final active = cat == _selectedCategory;
          return GestureDetector(
            onTap: () async {
              setState(() => _selectedCategory = cat);
              await _loadMembers();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppTheme.secondaryColor : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.secondaryColor),
              ),
              child: Text(
                cat,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _memberTile(_MemberRow row) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage:
                row.member.avatarUrl != null ? NetworkImage(row.member.avatarUrl!) : null,
            child: row.member.avatarUrl == null
                ? const Icon(LucideIcons.user, color: AppTheme.primaryColor)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.member.fullName,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  row.communityName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                Text(
                  row.communityCategory,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  'Interests: ${row.interestCategories.isEmpty ? 'None' : row.interestCategories.join(', ')} · Joined: ${_formatRelative(row.member.joinedAt)}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _notifyAll(List<_MemberRow> members) async {
    if (members.isEmpty) return;
    final provider = context.read<CommunitiesProvider>();
    final communities = provider.allCommunities
        .where((c) =>
            _selectedCategory == 'All' || c.category == _selectedCategory)
        .toList();
    if (communities.isEmpty) return;
    await _repo.notifyCommunityMembers(
      communities.first.id,
      'Announcement for ${_selectedCategory.toLowerCase()} members',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.primaryColor,
          content: Text('Notification sent',
              style: GoogleFonts.inter(color: AppTheme.lightSurface)),
        ),
      );
    }
  }

  Future<void> _exportList(List<_MemberRow> members) async {
    if (members.isEmpty) return;
    final buffer = StringBuffer('Name,Community\n');
    for (final m in members) {
      buffer.writeln('${m.member.fullName},${m.communityName}');
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.primaryColor,
          content: Text('Export copied to clipboard',
              style: GoogleFonts.inter(color: AppTheme.lightSurface)),
        ),
      );
    }
  }

  List<_MemberRow> _applyMemberSearch(List<_MemberRow> members) {
    final q = _searchCtrl.text.toLowerCase().trim();
    if (q.isEmpty) return members;
    return members
        .where((m) => m.member.fullName.toLowerCase().contains(q))
        .toList();
  }

  Widget _buildScoreboard(List<_MemberRow> members) {
    if (members.isEmpty) {
      return const SizedBox.shrink();
    }
    final scores = <String, _InterestScore>{};
    final categoryCounts = <String, int>{};
    for (final m in members) {
      final key = m.member.userId;
      final existing = scores[key];
      final cats = existing == null
          ? <String>{...m.interestCategories}
          : {...existing.categories, ...m.interestCategories};
      scores[key] = _InterestScore(
        userId: key,
        fullName: m.member.fullName,
        interestCount: m.interestCategories.length,
        categories: cats,
      );
      for (final c in m.interestCategories) {
        categoryCounts[c] = (categoryCounts[c] ?? 0) + 1;
      }
    }
    final sorted = scores.values.toList()
      ..sort((a, b) => b.interestCount.compareTo(a.interestCount));
    final top = sorted.take(5).toList();
    final topCategories = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interest Scoreboard',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...top.map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.secondaryColor.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Text(
                              '${sorted.indexOf(s) + 1}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.fullName,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: s.categories.take(3).map((c) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.secondaryColor
                                          .withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      c,
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${s.interestCount} interests',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
              Text(
                'Top categories',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: topCategories.take(4).map((e) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${e.key} (${e.value})',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _formatRelative(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
    if (diff.inDays >= 1) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
    if (diff.inHours >= 1) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
    return '${diff.inMinutes} min ago';
  }
}

class _MemberRow {
  final CommunityMember member;
  final String communityName;
  final String communityCategory;
  final List<String> interestCategories;

  _MemberRow({
    required this.member,
    required this.communityName,
    required this.communityCategory,
    required this.interestCategories,
  });
}

class _InterestScore {
  final String userId;
  final String fullName;
  final int interestCount;
  final Set<String> categories;

  _InterestScore({
    required this.userId,
    required this.fullName,
    required this.interestCount,
    required this.categories,
  });
}
