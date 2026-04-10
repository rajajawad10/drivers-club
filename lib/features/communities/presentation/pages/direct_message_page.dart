import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:pitstop/core/app_theme.dart';
import 'package:pitstop/features/communities/data/community_model.dart';
import 'package:pitstop/features/communities/presentation/providers/communities_provider.dart';

class DirectMessagePage extends StatefulWidget {
  final CommunityMember member;

  const DirectMessagePage({super.key, required this.member});

  @override
  State<DirectMessagePage> createState() => _DirectMessagePageState();
}

class _DirectMessagePageState extends State<DirectMessagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.member.avatarUrl != null
                  ? NetworkImage(widget.member.avatarUrl!)
                  : null,
              child: widget.member.avatarUrl == null
                  ? const Icon(LucideIcons.user, size: 16)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.member.fullName,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _DirectMessageBody(
        member: widget.member,
        showHeader: false,
      ),
    );
  }
}

class DirectMessageSheet extends StatelessWidget {
  final CommunityMember member;

  const DirectMessageSheet({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: SizedBox(
        height: height * 0.85,
        child: _DirectMessageBody(
          member: member,
          showHeader: true,
          onClose: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

class _DirectMessageBody extends StatefulWidget {
  final CommunityMember member;
  final bool showHeader;
  final VoidCallback? onClose;

  const _DirectMessageBody({
    required this.member,
    required this.showHeader,
    this.onClose,
  });

  @override
  State<_DirectMessageBody> createState() => _DirectMessageBodyState();
}

class _DirectMessageBodyState extends State<_DirectMessageBody> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunitiesProvider>().loadDirectChat(widget.member.userId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: widget.member.avatarUrl != null
                      ? NetworkImage(widget.member.avatarUrl!)
                      : null,
                  child: widget.member.avatarUrl == null
                      ? const Icon(LucideIcons.user, size: 16)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.member.fullName,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(LucideIcons.x, size: 18),
                ),
              ],
            ),
          ),
        Expanded(
          child: Consumer<CommunitiesProvider>(
            builder: (context, provider, _) {
              final messages = provider.directChatFor(widget.member.userId);
              if (messages.isEmpty) {
                return Center(
                  child: Text(
                    'Start the conversation.',
                    style: GoogleFonts.inter(color: Colors.black),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final showDate = index == 0 ||
                      !_isSameDay(
                          messages[index - 1].createdAt, msg.createdAt);
                  return Column(
                    children: [
                      if (showDate) _dateSeparator(msg.createdAt),
                      _bubble(msg),
                    ],
                  );
                },
              );
            },
          ),
        ),
        _inputBar(),
      ],
    );
  }

  Widget _bubble(DirectChatMessage msg) {
    final isMine = msg.isMine;
    final align = isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final rowAlign = isMine ? MainAxisAlignment.end : MainAxisAlignment.start;
    final bgColor = isMine ? AppTheme.primaryColor : AppTheme.lightSurface;
    final textColor = isMine ? AppTheme.lightSurface : AppTheme.primaryColor;
    return Row(
      mainAxisAlignment: rowAlign,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMine) ...[
          _avatar(widget.member.fullName),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: align,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 320),
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: align,
                  children: [
                    if (!isMine)
                      Text(
                        widget.member.fullName,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: textColor.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (!isMine) const SizedBox(height: 4),
                    Text(
                      msg.message,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(msg.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _inputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.lightSurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(LucideIcons.plus, size: 18),
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Send a message',
                filled: true,
                fillColor: AppTheme.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: AppTheme.lightBackground),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: AppTheme.lightBackground),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isEmpty) return;
              context
                  .read<CommunitiesProvider>()
                  .sendDirectMessage(widget.member.userId, text);
              _controller.clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'SEND',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateSeparator(DateTime date) {
    final label = _relativeDay(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar(String name) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: 14,
      backgroundColor: AppTheme.secondaryColor.withOpacity(0.2),
      child: Text(
        initial,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _relativeDay(DateTime date) {
    final now = DateTime.now();
    final diff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(date.year, date.month, date.day))
        .inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final am = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $am';
  }
}
