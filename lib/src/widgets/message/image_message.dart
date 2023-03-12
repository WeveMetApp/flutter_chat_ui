import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../../flutter_chat_ui.dart';
import '../../conditional/conditional.dart';
import '../../util.dart';
import '../state/inherited_chat_theme.dart';
import '../state/inherited_user.dart';

/// A class that represents image message widget. Supports different
/// aspect ratios, renders blurred image as a background which is visible
/// if the image is narrow, renders image in form of a file if aspect
/// ratio is very small or very big.
class ImageMessage extends StatefulWidget {
  /// Creates an image message widget based on [types.ImageMessage].
  const ImageMessage({
    super.key,
    required this.message,
    required this.messageWidth,
    this.nameBuilder,
    required this.showName,
    required this.isOtherUserAnonymous,
  });

  /// [types.ImageMessage].
  final types.ImageMessage message;

  /// Maximum message width.
  final int messageWidth;

  /// This is to allow custom user name builder
  /// By using this we can fetch newest user info based on id
  final Widget Function(String userId)? nameBuilder;

  /// Show user name for the received message. Useful for a group chat.
  final bool showName;

  final bool isOtherUserAnonymous;

  @override
  State<ImageMessage> createState() => _ImageMessageState();
}

/// [ImageMessage] widget state.
class _ImageMessageState extends State<ImageMessage> {
  ImageProvider? _image;
  Size _size = Size.zero;
  ImageStream? _stream;

  @override
  void initState() {
    super.initState();
    _image = Conditional().getProvider(widget.message.uri);
    _size = Size(widget.message.width ?? 0, widget.message.height ?? 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_size.isEmpty) {
      _getImage();
    }
  }

  @override
  void dispose() {
    _stream?.removeListener(ImageStreamListener(_updateImage));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = InheritedUser.of(context).user;

    if (_size.aspectRatio == 0) {
      return Container(
        color: InheritedChatTheme.of(context).theme.secondaryColor,
        height: _size.height,
        width: _size.width,
      );
    } else if (_size.aspectRatio < 0.1 || _size.aspectRatio > 10) {
      return Container(
        color: user.id == widget.message.author.id
            ? InheritedChatTheme.of(context).theme.primaryColor
            : InheritedChatTheme.of(context).theme.secondaryColor,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              margin: EdgeInsets.symmetric(
                vertical: InheritedChatTheme.of(context).theme.messageInsetsVertical,
                horizontal: 0,
              ),
              width: 64,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.showName)
                    widget.nameBuilder?.call(widget.message.author.id) ??
                        UserName(
                          author: widget.message.author,
                          isOtherUserAnonymous: widget.isOtherUserAnonymous,
                        ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image(
                      fit: BoxFit.cover,
                      image: _image!,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Container(
                margin: EdgeInsets.symmetric(
                  vertical: InheritedChatTheme.of(context).theme.messageInsetsVertical,
                  horizontal: 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.showName)
                      widget.nameBuilder?.call(widget.message.author.id) ??
                          UserName(
                            author: widget.message.author,
                            isOtherUserAnonymous: widget.isOtherUserAnonymous,
                          ),
                    Text(
                      widget.message.name,
                      style: user.id == widget.message.author.id
                          ? InheritedChatTheme.of(context).theme.sentMessageBodyTextStyle
                          : InheritedChatTheme.of(context).theme.receivedMessageBodyTextStyle,
                      textWidthBasis: TextWidthBasis.longestLine,
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 4,
                      ),
                      child: Text(
                        formatBytes(widget.message.size.truncate()),
                        style: user.id == widget.message.author.id
                            ? InheritedChatTheme.of(context).theme.sentMessageCaptionTextStyle
                            : InheritedChatTheme.of(context).theme.receivedMessageCaptionTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showName)
            widget.nameBuilder?.call(widget.message.author.id) ??
                UserName(
                  author: widget.message.author,
                  isOtherUserAnonymous: widget.isOtherUserAnonymous,
                ),
          Container(
            margin: EdgeInsets.symmetric(
              vertical: InheritedChatTheme.of(context).theme.messageInsetsVertical,
              horizontal: 0,
            ),
            constraints: BoxConstraints(
              maxWidth: widget.messageWidth.toDouble(),
              minWidth: 170,
            ),
            child: AspectRatio(
              aspectRatio: _size.aspectRatio > 0 ? _size.aspectRatio : 1,
              child: Image(
                fit: BoxFit.contain,
                image: _image!,
              ),
            ),
          ),
        ],
      );
    }
  }

  void _getImage() {
    final oldImageStream = _stream;
    _stream = _image?.resolve(createLocalImageConfiguration(context));
    if (_stream?.key == oldImageStream?.key) {
      return;
    }
    final listener = ImageStreamListener(_updateImage);
    oldImageStream?.removeListener(listener);
    _stream?.addListener(listener);
  }

  void _updateImage(ImageInfo info, bool _) {
    setState(() {
      _size = Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      );
    });
  }
}
