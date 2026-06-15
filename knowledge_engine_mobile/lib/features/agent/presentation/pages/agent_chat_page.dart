import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/models/agent_chat_response.dart';
import '../../../../l10n/l10n.dart';
import '../providers/agent_notifier.dart';
import '../providers/agent_provider.dart';

/// Agent Chat — conversational RAG with session memory and history.
class AgentChatPage extends ConsumerStatefulWidget {
  const AgentChatPage({super.key, required this.projectId});

  final int projectId;

  @override
  ConsumerState<AgentChatPage> createState() => _AgentChatPageState();
}

class _AgentChatPageState extends ConsumerState<AgentChatPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  AgentNotifier get _notifier =>
      ref.read(agentNotifierProvider(widget.projectId).notifier);

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _notifier.updateInput(text);
    _inputController.clear();
    await _notifier.sendMessage();
    _scrollToBottom();
  }

  void _stop() {
    _notifier.cancelStreaming();
  }

  void _startNewChat() {
    _notifier.cancelStreaming();
    _notifier.startNewConversation();
    _inputController.clear();
  }

  Future<void> _openHistory() async {
    // Refresh the list each time the sheet opens.
    _notifier.loadSessions();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => _SessionHistorySheet(
        projectId: widget.projectId,
        onOpen: (sessionId) async {
          Navigator.of(context).pop();
          await _notifier.openSession(sessionId);
          _scrollToBottom();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agentStateProvider(widget.projectId));

    ref.listen(agentStateProvider(widget.projectId), (previous, next) {
      final countChanged =
          next.messages.length != (previous?.messages.length ?? 0);
      final lastChanged = next.messages.isNotEmpty &&
          (previous == null ||
              previous.messages.isEmpty ||
              previous.messages.last.content != next.messages.last.content);
      if (countChanged || lastChanged) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.agentTitle,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              context.l10n.agentSubtitle,
              style: TextStyle(
                fontSize: 11.sp,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: context.l10n.agentHistory,
            icon: const Icon(Icons.history_rounded),
            onPressed: _openHistory,
          ),
          IconButton(
            tooltip: context.l10n.agentNewChat,
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: _startNewChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.hasMessages
                ? _MessageList(
                    state: state,
                    controller: _scrollController,
                  )
                : const _EmptyState(),
          ),
          if (state.errorMessage != null)
            _ErrorBanner(message: state.errorMessage!),
          _InputBar(
            controller: _inputController,
            isSending: state.isSending,
            onSend: _send,
            onStop: _stop,
          ),
        ],
      ),
    );
  }
}

// ── Message list ─────────────────────────────────────────────────────────────
class _MessageList extends StatelessWidget {
  const _MessageList({required this.state, required this.controller});

  final AgentState state;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        return _MessageBubble(message: state.messages[index]);
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    // Assistant bubble that hasn't received any tokens yet → show a thinking
    // indicator in place of empty text.
    if (!isUser && message.isStreaming && message.content.isEmpty) {
      return const _TypingBubble();
    }

    final scheme = Theme.of(context).colorScheme;
    final bg = isUser
        ? scheme.primary
        : (message.isError
            ? scheme.error.withValues(alpha: 0.12)
            : Theme.of(context).cardColor);
    final fg = isUser
        ? scheme.onPrimary
        : (message.isError
            ? scheme.error
            : Theme.of(context).textTheme.bodyLarge?.color);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        constraints: BoxConstraints(maxWidth: 0.82.sw),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isUser ? 16.r : 4.r),
            bottomRight: Radius.circular(isUser ? 4.r : 16.r),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: scheme.onSurface.withValues(alpha: 0.08),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: fg,
                fontSize: 14.sp,
                height: 1.4,
              ),
            ),
            if (message.sources.isNotEmpty) _SourcesBlock(sources: message.sources),
          ],
        ),
      ),
    );
  }
}

class _SourcesBlock extends StatelessWidget {
  const _SourcesBlock({required this.sources});

  final List<AgentSource> sources;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.only(bottom: 4.h),
          dense: true,
          visualDensity: VisualDensity.compact,
          title: Text(
            '${context.l10n.agentSources} · ${sources.length}',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: color,
            ),
          ),
          children: sources
              .map(
                (source) => Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 6.h),
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: color.withValues(alpha: 0.18)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.text,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.35,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        source.score.toStringAsFixed(3),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14.w,
              height: 14.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10.w),
            Text(
              context.l10n.agentThinking,
              style: TextStyle(
                fontSize: 13.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Icon(Icons.auto_awesome_rounded, color: color, size: 30.w),
            ),
            SizedBox(height: 18.h),
            Text(
              context.l10n.agentEmptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              context.l10n.agentEmptyBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.5,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Input bar ────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.onStop,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: scheme.onSurface.withValues(alpha: 0.08)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: isSending ? null : (_) => onSend(),
                decoration: InputDecoration(
                  hintText: context.l10n.agentInputHint,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide(
                      color: scheme.onSurface.withValues(alpha: 0.12),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide(
                      color: scheme.onSurface.withValues(alpha: 0.12),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide(color: scheme.primary),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            _SendButton(
              isSending: isSending,
              onSend: onSend,
              onStop: onStop,
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.isSending,
    required this.onSend,
    required this.onStop,
  });

  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 48.w,
      height: 48.w,
      child: Material(
        color: isSending ? scheme.error : scheme.primary,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isSending ? onStop : onSend,
          child: Center(
            child: Icon(
              isSending ? Icons.stop_rounded : Icons.arrow_upward_rounded,
              color: scheme.onPrimary,
              size: 22.w,
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      color: scheme.error.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: scheme.error, size: 18.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.error, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Session history sheet ────────────────────────────────────────────────────
class _SessionHistorySheet extends ConsumerWidget {
  const _SessionHistorySheet({
    required this.projectId,
    required this.onOpen,
  });

  final int projectId;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(agentStateProvider(projectId));
    final notifier = ref.read(agentNotifierProvider(projectId).notifier);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 8.h),
              child: Row(
                children: [
                  Text(
                    context.l10n.agentHistory,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Spacer(),
                  if (state.isLoadingSessions)
                    SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _SessionList(
                state: state,
                scrollController: scrollController,
                onOpen: onOpen,
                onDelete: notifier.deleteSession,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList({
    required this.state,
    required this.scrollController,
    required this.onOpen,
    required this.onDelete,
  });

  final AgentState state;
  final ScrollController scrollController;
  final ValueChanged<int> onOpen;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    if (!state.isLoadingSessions && state.sessions.isEmpty) {
      return Center(
        child: Text(
          state.sessionsError ?? context.l10n.agentNoSessions,
          style: TextStyle(
            fontSize: 13.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: state.sessions.length,
      separatorBuilder: (_, _) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final session = state.sessions[index];
        final isActive = session.sessionId == state.sessionId;
        final title = session.title.trim().isEmpty
            ? context.l10n.agentUntitledSession
            : session.title;
        final scheme = Theme.of(context).colorScheme;
        return Material(
          color: isActive
              ? scheme.primary.withValues(alpha: 0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () => onOpen(session.sessionId),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18.w,
                    color: isActive
                        ? scheme.primary
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.agentDeleteSession,
                    icon: Icon(Icons.delete_outline_rounded,
                        size: 18.w, color: scheme.error),
                    onPressed: () => onDelete(session.sessionId),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
