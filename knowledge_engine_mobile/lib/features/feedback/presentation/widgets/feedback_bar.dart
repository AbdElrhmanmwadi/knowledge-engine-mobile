import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../l10n/l10n.dart';

/// A 👍/👎 feedback control rendered under an assistant answer.
///
/// Optimistic by design: the parent updates [rating] immediately when
/// [onSubmit] is called, and reverts it if the request fails. On 👎 a small
/// optional comment box is revealed so the user can explain what went wrong.
class FeedbackBar extends StatefulWidget {
  const FeedbackBar({
    super.key,
    required this.rating,
    required this.isSubmitting,
    required this.onSubmit,
    this.errorMessage,
    this.compact = false,
  });

  /// Currently selected rating: `1` (👍), `-1` (👎), or `null` (none yet).
  final int? rating;
  final bool isSubmitting;

  /// Submit a rating; [comment] is only sent from the 👎 comment box.
  final void Function(int rating, {String? comment}) onSubmit;

  final String? errorMessage;

  /// Slightly tighter layout for dense surfaces like chat bubbles.
  final bool compact;

  @override
  State<FeedbackBar> createState() => _FeedbackBarState();
}

class _FeedbackBarState extends State<FeedbackBar> {
  final TextEditingController _commentController = TextEditingController();
  bool _showComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _rate(int rating) {
    widget.onSubmit(rating);
    // Reveal the comment box on 👎 so the user can optionally elaborate.
    setState(() => _showComment = rating == -1);
  }

  void _sendComment() {
    final comment = _commentController.text.trim();
    widget.onSubmit(-1, comment: comment.isEmpty ? null : comment);
    setState(() => _showComment = false);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ??
        scheme.onSurface;
    final rated = widget.rating != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (!widget.compact) ...[
              Flexible(
                child: Text(
                  rated
                      ? context.l10n.feedbackThanks
                      : context.l10n.feedbackPrompt,
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
            ],
            _RateButton(
              icon: Icons.thumb_up_outlined,
              selectedIcon: Icons.thumb_up_rounded,
              label: context.l10n.feedbackHelpful,
              color: scheme.primary,
              selected: widget.rating == 1,
              enabled: !widget.isSubmitting,
              onTap: () => _rate(1),
            ),
            SizedBox(width: 8.w),
            _RateButton(
              icon: Icons.thumb_down_outlined,
              selectedIcon: Icons.thumb_down_rounded,
              label: context.l10n.feedbackNotHelpful,
              color: scheme.error,
              selected: widget.rating == -1,
              enabled: !widget.isSubmitting,
              onTap: () => _rate(-1),
            ),
            if (widget.isSubmitting) ...[
              SizedBox(width: 10.w),
              SizedBox(
                width: 12.r,
                height: 12.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.primary,
                ),
              ),
            ],
          ],
        ),
        if (_showComment) ...[
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  enabled: !widget.isSubmitting,
                  minLines: 1,
                  maxLines: 3,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 13.sp,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendComment(),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: context.l10n.feedbackCommentHint,
                    hintStyle: TextStyle(color: mutedColor, fontSize: 12.sp),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                          color: scheme.onSurface.withValues(alpha: 0.12)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                          color: scheme.onSurface.withValues(alpha: 0.12)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: scheme.primary),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              TextButton(
                onPressed: widget.isSubmitting ? null : _sendComment,
                child: Text(context.l10n.feedbackSend),
              ),
            ],
          ),
        ],
        if (widget.errorMessage != null) ...[
          SizedBox(height: 8.h),
          Text(
            widget.errorMessage!,
            style: TextStyle(color: scheme.error, fontSize: 11.sp),
          ),
        ],
      ],
    );
  }
}

class _RateButton extends StatelessWidget {
  const _RateButton({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.color,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color color;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final alpha = selected ? 0.16 : 0.08;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: alpha),
            borderRadius: BorderRadius.circular(9.r),
            border: Border.all(
              color: color.withValues(alpha: selected ? 0.5 : 0.2),
            ),
          ),
          child: Icon(
            selected ? selectedIcon : icon,
            color: color,
            size: 15.r,
          ),
        ),
      ),
    );
  }
}
