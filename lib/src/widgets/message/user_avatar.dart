import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../models/bubble_rtl_alignment.dart';

/// Renders user's avatar or initials next to a message.
class UserAvatar extends StatelessWidget {
  /// Creates user avatar.
  const UserAvatar({
    super.key,
    required this.author,
    this.bubbleRtlAlignment,
    this.onAvatarTap,
    required this.isOtherUserAnonymous,
  });
  final bool isOtherUserAnonymous;

  /// Author to show image and name initials from.
  final types.User author;

  /// See [Message.bubbleRtlAlignment].
  final BubbleRtlAlignment? bubbleRtlAlignment;

  /// Called when user taps on an avatar.
  final void Function(types.User)? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = Colors.transparent;
    final hasImage = author.imageUrl != null && author.imageUrl!.isNotEmpty;

    if (isOtherUserAnonymous) {
      return Container(
        child: GestureDetector(
          onTap: () => onAvatarTap?.call(author),
          child: CircleAvatar(
            backgroundColor: bgColor,
            backgroundImage: AssetImage('assets/images/img_anonymous.png'),
            radius: 25,
          ),
        ),
      );
    } else if (!hasImage) {
      return Container(
        child: GestureDetector(
          onTap: () => onAvatarTap?.call(author),
          child: CircleAvatar(
            backgroundColor: bgColor,
            backgroundImage: AssetImage('assets/images/img_profile.png'),
            radius: 25,
          ),
        ),
      );
    }

    return Container(
      child: GestureDetector(
        onTap: () => onAvatarTap?.call(author),
        child: CircleAvatar(
          backgroundColor: bgColor,
          backgroundImage: NetworkImage(author.imageUrl!),
          radius: 25,
        ),
      ),
    );
  }
}
