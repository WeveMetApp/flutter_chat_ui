import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_link_previewer/flutter_link_previewer.dart' show LinkPreview, regexEmail, regexLink;
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/emoji_enlargement_behavior.dart';
import '../../models/pattern_style.dart';
import '../../util.dart';
import '../state/inherited_chat_theme.dart';
import '../state/inherited_user.dart';
import 'user_name.dart';

/// A class that represents text message widget with optional link preview.
class TextMessage extends StatelessWidget {
  /// Creates a text message widget from a [types.TextMessage] class.
  const TextMessage({
    super.key,
    required this.emojiEnlargementBehavior,
    required this.hideBackgroundOnEmojiMessages,
    required this.isTextMessageTextSelectable,
    required this.message,
    required this.messageWidth,
    this.nameBuilder,
    this.onPreviewDataFetched,
    this.options = const TextMessageOptions(),
    required this.showName,
    required this.usePreviewData,
    this.userAgent,
    required this.showBubbleNip,
    required this.isOtherUserAnonymous,
  });

  /// See [Message.emojiEnlargementBehavior].
  final EmojiEnlargementBehavior emojiEnlargementBehavior;

  /// See [Message.hideBackgroundOnEmojiMessages].
  final bool hideBackgroundOnEmojiMessages;

  /// Whether user can tap and hold to select a text content.
  final bool isTextMessageTextSelectable;

  /// [types.TextMessage].
  final types.TextMessage message;

  /// Maximum message width.
  final int messageWidth;

  /// This is to allow custom user name builder
  /// By using this we can fetch newest user info based on id
  final Widget Function(String userId)? nameBuilder;

  /// See [LinkPreview.onPreviewDataFetched].
  final void Function(types.TextMessage, types.PreviewData)? onPreviewDataFetched;

  /// Customisation options for the [TextMessage].
  final TextMessageOptions options;

  /// Show user name for the received message. Useful for a group chat.
  final bool showName;

  /// Enables link (URL) preview.
  final bool usePreviewData;

  /// User agent to fetch preview data with.
  final String? userAgent;

  /// If true, bubble will have a nip
  final bool showBubbleNip;

  final bool isOtherUserAnonymous;

  @override
  Widget build(BuildContext context) {
    final enlargeEmojis = emojiEnlargementBehavior != EmojiEnlargementBehavior.never &&
        isConsistsOfEmojis(emojiEnlargementBehavior, message);
    final theme = InheritedChatTheme.of(context).theme;
    final user = InheritedUser.of(context).user;
    final width = messageWidth.toDouble();

    if (usePreviewData && onPreviewDataFetched != null) {
      final urlRegexp = RegExp(regexLink, caseSensitive: false);
      final matches = urlRegexp.allMatches(message.text);

      if (matches.isNotEmpty) {
        return _linkPreview(user, width, context, width);
      }
    }

    return Container(
      child: _textWidgetBuilder(user, context, enlargeEmojis, width),
    );
  }

  Widget _linkPreview(
    types.User user,
    double width,
    BuildContext context,
    double messageWidth,
  ) {
    final isSender = user.id == message.author.id;
    final linkDescriptionTextStyle = isSender
        ? InheritedChatTheme.of(context).theme.sentMessageLinkDescriptionTextStyle
        : InheritedChatTheme.of(context).theme.receivedMessageLinkDescriptionTextStyle;
    final linkTitleTextStyle = isSender
        ? InheritedChatTheme.of(context).theme.sentMessageLinkTitleTextStyle
        : InheritedChatTheme.of(context).theme.receivedMessageLinkTitleTextStyle;
    final borderRadius = BorderRadius.circular(10.0);
    final margin = isSender ? EdgeInsets.only(top: 5.0, right: 10.0) : EdgeInsets.only(left: 10.0, top: 5.0);
    final padding = EdgeInsets.all(10.0);

    return LinkPreview(
      borderRadius: borderRadius,
      color: isSender ? Colors.black : const Color(0xffE8E8E8),
      enableAnimation: true,
      isSender: isSender,
      margin: margin,
      metadataTextStyle: linkDescriptionTextStyle,
      metadataTitleStyle: linkTitleTextStyle,
      onLinkPressed: options.onLinkPressed,
      onPreviewDataFetched: _onPreviewDataFetched,
      openOnPreviewImageTap: options.openOnPreviewImageTap,
      openOnPreviewTitleTap: options.openOnPreviewTitleTap,
      padding: padding,
      previewData: message.previewData,
      text: message.text,
      textWidget: _textWidgetBuilder(user, context, false, messageWidth),
      userAgent: userAgent,
      width: width,
    );
  }

  void _onPreviewDataFetched(types.PreviewData previewData) {
    if (message.previewData == null) {
      onPreviewDataFetched?.call(message, previewData);
    }
  }

  Widget _textWidgetBuilder(
    types.User user,
    BuildContext context,
    bool enlargeEmojis,
    double messageWidth,
  ) {
    final isSender = user.id == message.author.id;
    final theme = InheritedChatTheme.of(context).theme;
    final bodyLinkTextStyle = isSender
        ? InheritedChatTheme.of(context).theme.sentMessageBodyLinkTextStyle
        : InheritedChatTheme.of(context).theme.receivedMessageBodyLinkTextStyle;
    final bodyTextStyle = isSender ? theme.sentMessageBodyTextStyle : theme.receivedMessageBodyTextStyle;
    final boldTextStyle = isSender ? theme.sentMessageBodyBoldTextStyle : theme.receivedMessageBodyBoldTextStyle;
    final codeTextStyle = isSender ? theme.sentMessageBodyCodeTextStyle : theme.receivedMessageBodyCodeTextStyle;
    final emojiTextStyle = isSender ? theme.sentEmojiMessageTextStyle : theme.receivedEmojiMessageTextStyle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showName)
          nameBuilder?.call(message.author.id) ??
              UserName(
                author: message.author,
                isOtherUserAnonymous: isOtherUserAnonymous,
              ),
        if (enlargeEmojis)
          if (isTextMessageTextSelectable)
            SelectableText(message.text, style: emojiTextStyle)
          else
            Text(message.text, style: emojiTextStyle)
        else
          FittedBox(
            child: BubbleSpecialOne(
              color: isSender ? Colors.black : const Color(0xffE8E8E8),
              isSender: isSender,
              width: messageWidth,
              tail: true,
              text: ParsedText(
                parse: [
                  MatchText(
                    onTap: (mail) async {
                      final url = Uri(scheme: 'mailto', path: mail);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    pattern: regexEmail,
                    style: bodyLinkTextStyle ?? bodyTextStyle.copyWith(decoration: TextDecoration.underline),
                  ),
                  MatchText(
                    onTap: (urlText) async {
                      final protocolIdentifierRegex = RegExp(
                        r'^((http|ftp|https):\/\/)',
                        caseSensitive: false,
                      );
                      if (!urlText.startsWith(protocolIdentifierRegex)) {
                        urlText = 'https://$urlText';
                      }
                      if (options.onLinkPressed != null) {
                        options.onLinkPressed!(urlText);
                      } else {
                        final url = Uri.tryParse(urlText);
                        if (url != null && await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      }
                    },
                    pattern: regexLink,
                    style: bodyLinkTextStyle ?? bodyTextStyle.copyWith(decoration: TextDecoration.underline),
                  ),
                  MatchText(
                    pattern: PatternStyle.bold.pattern,
                    style: boldTextStyle ?? bodyTextStyle.merge(PatternStyle.bold.textStyle),
                    renderText: ({required String str, required String pattern}) => {
                      'display': str.replaceAll(
                        PatternStyle.bold.from,
                        PatternStyle.bold.replace,
                      ),
                    },
                  ),
                  MatchText(
                    pattern: PatternStyle.italic.pattern,
                    style: bodyTextStyle.merge(PatternStyle.italic.textStyle),
                    renderText: ({required String str, required String pattern}) => {
                      'display': str.replaceAll(
                        PatternStyle.italic.from,
                        PatternStyle.italic.replace,
                      ),
                    },
                  ),
                  MatchText(
                    pattern: PatternStyle.lineThrough.pattern,
                    style: bodyTextStyle.merge(PatternStyle.lineThrough.textStyle),
                    renderText: ({required String str, required String pattern}) => {
                      'display': str.replaceAll(
                        PatternStyle.lineThrough.from,
                        PatternStyle.lineThrough.replace,
                      ),
                    },
                  ),
                  MatchText(
                    pattern: PatternStyle.code.pattern,
                    style: codeTextStyle ?? bodyTextStyle.merge(PatternStyle.code.textStyle),
                    renderText: ({required String str, required String pattern}) => {
                      'display': str.replaceAll(
                        PatternStyle.code.from,
                        PatternStyle.code.replace,
                      ),
                    },
                  ),
                ],
                regexOptions: const RegexOptions(multiLine: true, dotAll: true),
                selectable: isTextMessageTextSelectable,
                style: bodyTextStyle,
                text: message.text,
                textWidthBasis: TextWidthBasis.longestLine,
              ),
            ),
          ),
      ],
    );
  }
}

@immutable
class TextMessageOptions {
  const TextMessageOptions({
    this.onLinkPressed,
    this.openOnPreviewImageTap = false,
    this.openOnPreviewTitleTap = false,
  });

  /// Custom link press handler.
  final void Function(String)? onLinkPressed;

  /// See [LinkPreview.openOnPreviewImageTap].
  final bool openOnPreviewImageTap;

  /// See [LinkPreview.openOnPreviewTitleTap].
  final bool openOnPreviewTitleTap;
}
