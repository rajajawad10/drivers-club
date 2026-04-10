import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:pitstop/core/app_theme.dart';
import 'package:pitstop/core/responsive.dart';
import 'package:pitstop/core/providers/user_provider.dart';
import 'package:pitstop/core/web_routes.dart';
import 'package:pitstop/core/web_utils.dart';
import 'package:pitstop/features/communities/data/community_model.dart';
import 'package:pitstop/features/communities/data/community_repository.dart';
import 'package:pitstop/features/communities/presentation/providers/communities_provider.dart';
import 'package:pitstop/features/communities/presentation/pages/community_chat_view.dart';
import 'package:pitstop/features/communities/presentation/pages/direct_message_page.dart';
import 'package:pitstop/features/communities/presentation/pages/member_profile_page.dart';

class CommunityDetailPage extends StatefulWidget {
  final String communityId;

  const CommunityDetailPage({super.key, required this.communityId});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  final _repo = CommunityRepository();
  final ScrollController _webScrollController = ScrollController();
  final TextEditingController _postController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  String? _postImageUrl;
  bool _isJoining = false;
  CommunityModel? _community;
  int _tabIndex = 0;
  late final List<_FeedPost> _feedPosts;

  @override
  void initState() {
    super.initState();
    _feedPosts = _buildFeedPosts();
  }

  @override
  void dispose() {
    _webScrollController.dispose();
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunitiesProvider>();
    final local = _findCommunityFromProvider(provider);
    if (kIsWeb) {
      return WebScaffold(
        title: 'Community',
        selected: WebNavItem.communities,
        onNavSelected: _handleWebNav(context),
        child: _buildWebBody(context),
        showFooter: false,
      );
    }

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
          'Community',
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FutureBuilder<CommunityModel>(
        future: _community == null
            ? _repo.getCommunityById(widget.communityId)
            : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _community == null &&
              local == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.secondaryColor),
            );
          }
          final data = _community ?? local ?? snapshot.data;
          if (data == null) {
            return Center(
              child: Text(
                'Community not found.',
                style: GoogleFonts.inter(color: Colors.black),
              ),
            );
          }
          return _buildBody(context, data);
        },
      ),
    );
  }

  Widget _buildWebBody(BuildContext context) {
    final provider = context.watch<CommunitiesProvider>();
    final local = _findCommunityFromProvider(provider);
    return FutureBuilder<CommunityModel>(
      future:
          _community == null ? _repo.getCommunityById(widget.communityId) : null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _community == null &&
            local == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.secondaryColor),
          );
        }
        final data = _community ?? local ?? snapshot.data;
        if (data == null) {
          return Center(
            child: Text(
              'Community not found.',
              style: GoogleFonts.inter(color: Colors.black),
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final hPad = constraints.maxWidth < kWebNavDrawerBreakpoint
                ? 12.0
                : 16.0;
            return SingleChildScrollView(
              key: const PageStorageKey('community-detail-scroll'),
              controller: _webScrollController,
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _webHero(data),
                  const SizedBox(height: 16),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                      child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _tabs(),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightSurface,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor
                                          .withOpacity(0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                              child: _webTabBody(data),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              _webStatsCard(data),
                              const SizedBox(height: 12),
                              _webActionsCard(data),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _tabs(),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.lightSurface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: _webTabBody(data),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _webStatsCard(data),
                        const SizedBox(height: 12),
                        _webActionsCard(data),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CommunityModel community) {
    return Column(
      children: [
        _cover(community),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${community.memberCount} members · Since ${_formatMonthYear(community.createdAt)}',
                style: GoogleFonts.inter(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                community.description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 14),
              _tabs(),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(child: _tabBody(community)),
        _joinButton(context, community),
      ],
    );
  }

  Widget _tabs() {
    final items = ['Feed', 'Chat', 'Members'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == _tabIndex;
          return GestureDetector(
            onTap: () => setState(() => _tabIndex = i),
            child: Container(
              margin: EdgeInsets.only(right: i == items.length - 1 ? 0 : 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppTheme.secondaryColor : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.secondaryColor),
              ),
              child: Text(
                items[i],
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _tabBody(CommunityModel community) {
    if (!community.isJoined && _tabIndex != 2) {
      return _lockedContent(community);
    }
    if (_tabIndex == 1) {
      return CommunityChatView(communityId: community.id);
    }
    if (_tabIndex == 2) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _memberSearchField(),
            const SizedBox(height: 12),
            _membersSection(community.id),
          ],
        ),
      );
    }
    return _mobileFeedList();
  }

  Widget _webTabBody(CommunityModel community) {
    if (!community.isJoined && _tabIndex != 2) {
      return _lockedContent(community, isWeb: true);
    }
    if (_tabIndex == 1) {
      return SizedBox(
        height: 520,
        child: CommunityChatView(communityId: community.id),
      );
    }
    if (_tabIndex == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _memberSearchField(),
          const SizedBox(height: 12),
          _webMembersList(community.id),
        ],
      );
    }
    return _webFeedList();
  }

  Widget _webFeedList() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    child: Text(
                      'ME',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: AppTheme.lightBackground),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: AppTheme.lightBackground),
                        ),
                      ),
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                  ),
                ],
              ),
              if (_postImageUrl != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: AppTheme.lightBackground,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: kIsWeb
                          ? Image.network(
                              _postImageUrl!,
                              fit: BoxFit.contain,
                            )
                          : Image.file(
                              File(_postImageUrl!),
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Divider(color: Colors.black12),
              const SizedBox(height: 6),
              Row(
                children: [
                  IconButton(
                    onPressed: _pickPostPhoto,
                    icon: const Icon(LucideIcons.plus, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Photo',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(LucideIcons.smile, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Feeling',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      final text = _postController.text.trim();
                      if (text.isEmpty && _postImageUrl == null) return;
                      setState(() {
                        _feedPosts.insert(
                          0,
                          _FeedPost(
                            name: 'You',
                            time: 'Just now',
                            text: text.isEmpty ? ' ' : text,
                            imageUrl: _postImageUrl,
                            initialLikes: 0,
                            initialComments: const [],
                          ),
                        );
                        _postController.clear();
                        _postImageUrl = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Post',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ..._feedPosts.asMap().entries.map((entry) {
        final post = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black12,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.04),
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
                  _feedPostAuthorAvatar(post),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      post.name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  Text(
                    post.time,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  if (post.name == 'You') ...[
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: () => _removePost(post),
                      icon: const Icon(LucideIcons.trash2, size: 14),
                      color: Colors.black54,
                      tooltip: 'Delete post',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.text,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                ),
              ),
              if (post.imageUrl != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: AppTheme.lightBackground,
                      alignment: Alignment.center,
                      child: Image.network(
                        post.imageUrl!,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: post.isLiked,
                    builder: (context, isLiked, _) {
                      return IconButton(
                        onPressed: () => _toggleLike(post),
                        icon: Icon(
                          LucideIcons.heart,
                          size: 16,
                          color: isLiked
                              ? AppTheme.errorColor
                              : AppTheme.primaryColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  ValueListenableBuilder<int>(
                    valueListenable: post.likeCount,
                    builder: (context, likeCount, _) {
                      return Text(
                        '$likeCount',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.primaryColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () => _openCommentsSheet(post),
                    icon: const Icon(LucideIcons.messageCircle, size: 16),
                  ),
                  const SizedBox(width: 6),
                  ValueListenableBuilder<List<_FeedComment>>(
                    valueListenable: post.comments,
                    builder: (context, comments, _) {
                      return Text(
                        '${comments.length}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.primaryColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
      ],
    );
  }

  Widget _mobileFeedList() {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 96 + safeBottom),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.secondaryColor,
                    child: Text(
                      'ME',
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: AppTheme.lightBackground),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: AppTheme.lightBackground),
                        ),
                      ),
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                  ),
                ],
              ),
              if (_postImageUrl != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: AppTheme.lightBackground,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: kIsWeb
                          ? Image.network(
                              _postImageUrl!,
                              fit: BoxFit.contain,
                            )
                          : Image.file(
                              File(_postImageUrl!),
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Divider(color: Colors.black12, height: 1),
              const SizedBox(height: 6),
              Row(
                children: [
                  IconButton(
                    onPressed: _pickPostPhoto,
                    icon: const Icon(LucideIcons.plus, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Photo',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(LucideIcons.smile, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Feeling',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      final text = _postController.text.trim();
                      if (text.isEmpty && _postImageUrl == null) return;
                      setState(() {
                        _feedPosts.insert(
                          0,
                          _FeedPost(
                            name: 'You',
                            time: 'Just now',
                            text: text.isEmpty ? ' ' : text,
                            imageUrl: _postImageUrl,
                            initialLikes: 0,
                            initialComments: const [],
                          ),
                        );
                        _postController.clear();
                        _postImageUrl = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Post',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ..._feedPosts.asMap().entries.map((entry) {
          final post = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.04),
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
                    _feedPostAuthorAvatar(post),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        post.name,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    Text(
                      post.time,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    if (post.name == 'You') ...[
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: () => _removePost(post),
                        icon: const Icon(LucideIcons.trash2, size: 14),
                        color: Colors.black54,
                        tooltip: 'Delete post',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  post.text,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                  ),
                ),
                if (post.imageUrl != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: AppTheme.lightBackground,
                        alignment: Alignment.center,
                        child: post.imageUrl!.startsWith('http')
                            ? Image.network(
                                post.imageUrl!,
                                fit: BoxFit.contain,
                                gaplessPlayback: true,
                              )
                            : (kIsWeb
                                ? Image.network(
                                    post.imageUrl!,
                                    fit: BoxFit.contain,
                                  )
                                : Image.file(
                                    File(post.imageUrl!),
                                    fit: BoxFit.contain,
                                  )),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: post.isLiked,
                      builder: (context, isLiked, _) {
                        return IconButton(
                          onPressed: () => _toggleLike(post),
                          icon: Icon(
                            LucideIcons.heart,
                            size: 16,
                            color: isLiked
                                ? AppTheme.errorColor
                                : AppTheme.primaryColor,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    ValueListenableBuilder<int>(
                      valueListenable: post.likeCount,
                      builder: (context, likeCount, _) {
                        return Text(
                          '$likeCount',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.primaryColor,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () => _openCommentsSheet(post),
                      icon: const Icon(LucideIcons.messageCircle, size: 16),
                    ),
                    const SizedBox(width: 6),
                    ValueListenableBuilder<List<_FeedComment>>(
                      valueListenable: post.comments,
                      builder: (context, comments, _) {
                        return Text(
                          '${comments.length}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.primaryColor,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  CommunityModel? _findCommunityFromProvider(CommunitiesProvider provider) {
    try {
      return provider.allCommunities
          .firstWhere((c) => c.id == widget.communityId);
    } catch (_) {
      try {
        return provider.myCommunities
            .firstWhere((c) => c.id == widget.communityId);
      } catch (_) {
        return null;
      }
    }
  }

  void _removePost(_FeedPost post) {
    setState(() {
      _feedPosts.remove(post);
    });
  }

  Future<void> _pickPostPhoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (picked == null) return;
    setState(() => _postImageUrl = picked.path);
  }

  Widget _lockedContent(CommunityModel community, {bool isWeb = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.secondaryColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.lock, size: 20, color: Colors.black),
          const SizedBox(height: 8),
          Text(
            'Join this community to access feeds and chat.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: _isJoining ? null : () => _toggleJoin(community),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: _isJoining
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      'Join Community',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleLike(_FeedPost post) {
    final current = post.isLiked.value;
    post.isLiked.value = !current;
    post.likeCount.value = post.likeCount.value + (current ? -1 : 1);
  }

  Future<void> _openCommentsSheet(_FeedPost post) async {
    final controller = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final items = List<_FeedComment>.from(post.comments.value);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.7,
                minChildSize: 0.45,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Comments',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: items.isEmpty
                            ? Center(
                                child: Text(
                                  'No comments yet.',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppTheme.secondaryColor,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: items.length,
                                itemBuilder: (context, i) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      radius: 12,
                                      backgroundColor:
                                          AppTheme.secondaryColor.withOpacity(0.2),
                                      child: Text(
                                        items[i].name.isEmpty
                                            ? '?'
                                            : items[i].name[0].toUpperCase(),
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      items[i].name,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    subtitle: Text(
                                      items[i].text,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: 12,
                          right: 12,
                          bottom:
                              12 + MediaQuery.of(context).viewInsets.bottom,
                          top: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightSurface,
                          border: Border(
                            top: BorderSide(
                              color: AppTheme.primaryColor.withOpacity(0.08),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Write a comment...',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                  filled: true,
                                  fillColor: AppTheme.lightBackground,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppTheme.primaryColor.withOpacity(0.2),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppTheme.primaryColor.withOpacity(0.12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final text = controller.text.trim();
                                if (text.isEmpty) return;
                                setModalState(() {
                                  items.add(_FeedComment(name: 'You', text: text));
                                  controller.clear();
                                });
                                post.comments.value = List.from(items);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryColor,
                                padding: const EdgeInsets.all(10),
                                shape: const CircleBorder(),
                              ),
                              child: const Icon(LucideIcons.send,
                                  color: AppTheme.primaryColor, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  List<_FeedPost> _buildFeedPosts() {
    return [
      _FeedPost(
        name: 'Sara M.',
        authorAvatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop&q=80',
        time: '10:00 AM',
        text:
            'Looking for feedback on last track day highlights. Drop your notes!',
        imageUrl:
            'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?w=1200&q=80',
        initialLikes: 24,
        initialComments: List.generate(
          8,
          (index) => _FeedComment(
            name: 'Member ${index + 1}',
            text: 'Great update! Thanks for sharing.',
          ),
        ),
      ),
      _FeedPost(
        name: 'Bilal R.',
        authorAvatarUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&q=80',
        time: 'Yesterday',
        text:
            'Great session today. Next meetup should be early morning to avoid traffic.',
        initialLikes: 12,
        initialComments: List.generate(
          3,
          (index) => _FeedComment(
            name: 'Member ${index + 1}',
            text: 'Sounds good!',
          ),
        ),
      ),
    ];
  }

  Widget _webMembersList(String communityId) {
    return FutureBuilder<List<CommunityMember>>(
      future: _repo.getCommunityMembers(communityId),
      builder: (context, snapshot) {
        final members = snapshot.data ?? [];
        return Column(
          children: members.map((m) {
            return GestureDetector(
              onTap: () => _openMemberProfile(context, m),
              child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _memberAvatar(m.avatarUrl, m.fullName),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      m.fullName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(LucideIcons.moreVertical, size: 18),
                    onSelected: (value) {
                      if (value == 'message') {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: AppTheme.lightSurface,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16)),
                          ),
                          builder: (_) => DirectMessageSheet(member: m),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'message',
                        child: Text(
                          'Message',
                          style: GoogleFonts.inter(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _feedPlaceholder() {
    return Center(
      child: Text(
        'Community feed will appear here.',
        style: GoogleFonts.inter(color: AppTheme.secondaryColor),
      ),
    );
  }

  Widget _cover(CommunityModel community) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: community.coverImageUrl == null
            ? LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.9),
                  AppTheme.secondaryColor.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        image: community.coverImageUrl != null
            ? DecorationImage(
                image: NetworkImage(community.coverImageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            community.name,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.lightSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _membersSection(String communityId) {
    return FutureBuilder<List<CommunityMember>>(
      future: _repo.getCommunityMembers(communityId),
      builder: (context, snapshot) {
        final members = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Members',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            ...members.take(5).map((m) => _memberRow(m)).toList(),
            if (members.isNotEmpty)
              TextButton(
                onPressed: () {},
                child: Text(
                  'View all ${members.length} members',
                  style: GoogleFonts.inter(color: AppTheme.secondaryColor),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _memberSearchField() {
    return TextField(
      cursorColor: AppTheme.primaryColor,
      style: GoogleFonts.inter(
        fontSize: 12,
        color: AppTheme.primaryColor,
      ),
      decoration: InputDecoration(
        hintText: 'Search members',
        hintStyle: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.black54,
        ),
        prefixIcon: const Icon(LucideIcons.search, color: Colors.black54),
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


  Widget _memberRow(CommunityMember member) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _memberAvatar(member.avatarUrl, member.fullName),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _openMemberProfile(context, member),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    'Joined ${_formatRelative(member.joinedAt)}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreVertical,
                color: Colors.black),
            onSelected: (value) {
              if (value == 'message') {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppTheme.lightSurface,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (_) => DirectMessageSheet(member: member),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'message',
                child: Text(
                  'Message',
                  style: GoogleFonts.inter(color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _joinButton(BuildContext context, CommunityModel community) {
    final joined = community.isJoined;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + safeBottom),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _isJoining ? null : () => _toggleJoin(community),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                joined ? AppTheme.lightSurface : AppTheme.secondaryColor,
            side: BorderSide(
              color: joined ? AppTheme.errorColor : AppTheme.secondaryColor,
            ),
          ),
          child: _isJoining
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.secondaryColor,
                  ),
                )
              : Text(
                  joined ? 'Leave Community' : 'Join Community',
                  style: GoogleFonts.inter(
                    color: joined ? AppTheme.errorColor : AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _webHero(CommunityModel community) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (community.coverImageUrl != null)
              Image.network(community.coverImageUrl!, fit: BoxFit.cover)
            else
              Container(color: AppTheme.secondaryColor.withOpacity(0.2)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    community.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${community.memberCount} members · ${community.category}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white70,
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

  Widget _webStatsCard(CommunityModel community) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Stats',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          _statRow('Members', '${community.memberCount}'),
          _statRow('Category', community.category),
          _statRow('Activity', community.lastActivity ?? '—'),
        ],
      ),
    );
  }

  Widget _webActionsCard(CommunityModel community) {
    final joined = community.isJoined;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _isJoining ? null : () => _toggleJoin(community),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: joined ? AppTheme.errorColor : AppTheme.secondaryColor,
              ),
            ),
            child: Text(
              joined ? 'Leave Community' : 'Join Community',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: joined ? AppTheme.errorColor : AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => setState(() => _tabIndex = 1),
            child: Text(
              'Open Chat',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.secondaryColor,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleJoin(CommunityModel community) async {
    setState(() => _isJoining = true);
    final provider = context.read<CommunitiesProvider>();
    if (community.isJoined) {
      await provider.leaveCommunity(community.id);
    } else {
      await provider.joinCommunity(community.id);
    }
    if (mounted) {
      setState(() {
        _isJoining = false;
        _community = community.copyWith(isJoined: !community.isJoined);
      });
    }
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

  String _formatMonthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
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

  Widget _memberAvatar(String? url, String name, {double radius = 18}) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final dim = radius * 2;
    final fontSize = radius < 16 ? 11.0 : 12.0;
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppTheme.secondaryColor.withOpacity(0.2),
        child: Text(
          initial,
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryColor,
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.secondaryColor.withOpacity(0.2),
      child: ClipOval(
        child: Image.network(
          url,
          width: dim,
          height: dim,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Text(
            initial,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _feedPostAuthorAvatar(_FeedPost post) {
    if (post.name == 'You') {
      return Consumer<UserProvider>(
        builder: (context, user, _) {
          final img = user.profileImageProvider;
          if (img != null) {
            return CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.secondaryColor.withOpacity(0.2),
              backgroundImage: img,
            );
          }
          return _memberAvatar(null, 'You', radius: 14);
        },
      );
    }
    return _memberAvatar(post.authorAvatarUrl, post.name, radius: 14);
  }

  void _openMemberProfile(BuildContext context, CommunityMember member) {
    if (kIsWeb) {
      showDialog(
        context: context,
        barrierColor: Colors.black26,
        builder: (_) => MemberProfileDrawer(member: member),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => MemberProfileSheet(member: member),
    );
  }

}

class _FeedComment {
  final String name;
  final String text;

  _FeedComment({required this.name, required this.text});
}

class _FeedPost {
  final String name;
  final String? authorAvatarUrl;
  final String time;
  final String text;
  final String? imageUrl;
  final ValueNotifier<int> likeCount;
  final ValueNotifier<bool> isLiked;
  final ValueNotifier<List<_FeedComment>> comments;

  _FeedPost({
    required this.name,
    this.authorAvatarUrl,
    required this.time,
    required this.text,
    this.imageUrl,
    required int initialLikes,
    required List<_FeedComment> initialComments,
  })  : likeCount = ValueNotifier<int>(initialLikes),
        isLiked = ValueNotifier<bool>(false),
        comments = ValueNotifier<List<_FeedComment>>(initialComments);
}
