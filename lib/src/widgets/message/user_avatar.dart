import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../models/bubble_rtl_alignment.dart';
import '../../util.dart';
import '../state/inherited_chat_theme.dart';

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
    final color = getUserAvatarNameColor(
      author,
      InheritedChatTheme.of(context).theme.userAvatarNameColors,
    );
    final hasImage = author.imageUrl != null && author.imageUrl!.isNotEmpty;
    // final initials = getUserInitials(author);

    return Container(
      // color: Colors.yellow,
      // margin: bubbleRtlAlignment == BubbleRtlAlignment.left
      //     ? const EdgeInsetsDirectional.only(end: 8)
      //     : const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onAvatarTap?.call(author),
        child: CircleAvatar(
          backgroundColor: hasImage ? InheritedChatTheme.of(context).theme.userAvatarImageBackgroundColor : Colors.transparent,
          backgroundImage: hasImage && isOtherUserAnonymous == false
              ? NetworkImage(
                  author.imageUrl!,
                )
              : null,
          radius: 25,
          child: !hasImage || isOtherUserAnonymous == true
              ? Image.asset(
                  isOtherUserAnonymous == true ? 'assets/images/img_anonymous.png' : 'assets/icons/ic_profile_empty.png',
                  width: 50,
                  height: 50,
                )
              : null,
        ),
      ),
    );
  }
}
