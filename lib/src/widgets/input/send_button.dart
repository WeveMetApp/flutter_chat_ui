import 'package:flutter/material.dart';

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
  });

  /// Callback for send button tap event.
  final VoidCallback onPressed;

  final bool showAnonymousSendBtn;

  /// Padding around the button.
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => IconButton(
        padding: EdgeInsets.only(right: 10), // sajad change to all zero if you want to remove the padding
        icon: Image.asset(
          showAnonymousSendBtn ? 'assets/ic_sendbtn_anonym.png' : 'assets/ic_sendbtn_cutom.png',
          package: 'flutter_chat_ui',
        ),
        onPressed: onPressed,
        // padding: padding,
        // splashRadius: 24,
        tooltip: InheritedL10n.of(context).l10n.sendButtonAccessibilityLabel,
      );
}
