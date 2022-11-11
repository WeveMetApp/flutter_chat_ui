import 'package:flutter/material.dart';
import 'package:flutter_chat_types/src/user.dart';
import 'package:flutter_chat_ui/src/models/chat_send_button_icon.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as SvgProvider;

import '../state/inherited_chat_theme.dart';
import '../state/inherited_l10n.dart';

/// A class that represents send button widget.
class SendButton extends StatelessWidget {
  /// Creates send button widget.
  const SendButton({
    super.key,
    required this.onPressed,
    this.padding = EdgeInsets.zero,
    required this.sendBtn,
    required this.meUser,
  });

  /// Callback for send button tap event.
  final VoidCallback onPressed;

  final User meUser;

  final ChatSendButtonIcon sendBtn;

  /// Padding around the button.
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    Widget? icon;

    switch (sendBtn) {
      case ChatSendButtonIcon.send:
        icon = CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: SvgPicture.asset(
            'assets/ic_sendbtn.svg',
            color: InheritedChatTheme.of(context).theme.inputBackgroundColor,
            width: 25,
            height: 25,
            package: 'flutter_chat_ui',
          ),
        );
        break;
      case ChatSendButtonIcon.anonymous:
        icon = Image(
          width: 40,
          height: 40,
          image: SvgProvider.Svg('assets/images/img_anonymous.svg'),
        );
        break;
      case ChatSendButtonIcon.profile:
        if (meUser.imageUrl?.isEmpty ?? true) {
          icon = Image(
            width: 40,
            height: 40,
            image: SvgProvider.Svg('assets/images/img_profile.svg'),
          );
        } else {
          icon = CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(meUser.imageUrl!),
            backgroundColor: Colors.white,
          );
        }

        break;
    }

    return IconButton(
      padding: EdgeInsets.only(right: 10), // sajad change to all zero if you want to remove the padding
      icon: icon,
      onPressed: onPressed,
      // padding: padding,
      // splashRadius: 24,
      tooltip: InheritedL10n.of(context).l10n.sendButtonAccessibilityLabel,
    );
  }
}
