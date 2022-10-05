import 'package:flutter/material.dart';
import 'package:flutter_chat_types/src/user.dart';
import 'package:flutter_chat_ui/src/models/chat_send_button_icon.dart';

import '../state/inherited_chat_theme.dart';
import '../state/inherited_l10n.dart';

/// A class that represents send button widget.
class SendButton extends StatelessWidget {
  /// Creates send button widget.
  const SendButton({
    super.key,
    required this.onPressed,
    this.padding = EdgeInsets.zero,
    this.showAnonymousSendBtn = false,
    required this.sendBtn,
    required this.meUser,
  });

  /// Callback for send button tap event.
  final VoidCallback onPressed;

  final bool showAnonymousSendBtn;

  final User meUser;

  final ChatSendButtonIcon sendBtn;

  /// Padding around the button.
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    Widget? icon;

    switch (sendBtn) {
      case ChatSendButtonIcon.send:
        icon = Image.asset(
          'assets/ic_sendbtn_cutom.png',
          package: 'flutter_chat_ui',
        );
        break;
      case ChatSendButtonIcon.anonymous:
        icon = Image.asset(
          'assets/ic_sendbtn_anonym.png',
          package: 'flutter_chat_ui',
        );
        break;
      case ChatSendButtonIcon.profile:
        icon = Image(
          width: 40,
          height: 40,
          image: AssetImage('assets/images/img_profile_filled.png'),
        );
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
