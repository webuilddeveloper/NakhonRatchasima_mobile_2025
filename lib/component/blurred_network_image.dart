import 'dart:ui';

import 'package:flutter/material.dart';

/// Blurs the backdrop only when BoxFit.cover would visibly crop the image.
class BlurredNetworkImage extends StatefulWidget {
  const BlurredNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.placeholder,
    this.blurWhenNeeded = true,
    this.overflowThreshold = 0.18,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final bool blurWhenNeeded;
  final double overflowThreshold;

  @override
  State<BlurredNetworkImage> createState() => _BlurredNetworkImageState();
}

class _BlurredNetworkImageState extends State<BlurredNetworkImage> {
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;
  ImageInfo? _imageInfo;
  String? _resolvedUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant BlurredNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _imageInfo = null;
      _resolvedUrl = null;
      _resolveImage();
    }
  }

  void _resolveImage() {
    final imageUrl = widget.imageUrl.trim();
    if (imageUrl.isEmpty || imageUrl == _resolvedUrl) return;

    _removeImageListener();
    _resolvedUrl = imageUrl;
    final stream = NetworkImage(imageUrl).resolve(
      createLocalImageConfiguration(context),
    );
    final listener = ImageStreamListener(
      (info, _) {
        if (mounted) setState(() => _imageInfo = info);
      },
      onError: (_, __) {},
    );
    _imageStream = stream;
    _imageListener = listener;
    stream.addListener(listener);
  }

  void _removeImageListener() {
    final stream = _imageStream;
    final listener = _imageListener;
    if (stream != null && listener != null) {
      stream.removeListener(listener);
    }
    _imageStream = null;
    _imageListener = null;
  }

  @override
  void dispose() {
    _removeImageListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.trim().isEmpty) {
      return _placeholder();
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (!_shouldBlur(constraints)) {
            return Image.network(
              widget.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: ColoredBox(
                  color: Colors.white.withValues(alpha: 0.28),
                ),
              ),
              Image.network(
                widget.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _placeholder(),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _shouldBlur(BoxConstraints constraints) {
    if (!widget.blurWhenNeeded || _imageInfo == null) return false;

    final frameWidth = _finiteSize(widget.width, constraints.maxWidth);
    final frameHeight = _finiteSize(widget.height, constraints.maxHeight);
    if (frameWidth == null || frameHeight == null || frameHeight == 0) {
      return false;
    }

    final imageWidth = _imageInfo!.image.width.toDouble();
    final imageHeight = _imageInfo!.image.height.toDouble();
    if (imageWidth == 0 || imageHeight == 0) return false;

    final imageRatio = imageWidth / imageHeight;
    final frameRatio = frameWidth / frameHeight;
    final ratioDifference = imageRatio > frameRatio
        ? imageRatio / frameRatio - 1
        : frameRatio / imageRatio - 1;
    return ratioDifference > widget.overflowThreshold;
  }

  double? _finiteSize(double? preferred, double constrained) {
    if (preferred != null && preferred.isFinite) return preferred;
    return constrained.isFinite ? constrained : null;
  }

  Widget _placeholder() {
    return widget.placeholder ??
        const ColoredBox(
          color: Color(0xFFF4EEF1),
          child: Center(
            child: Icon(Icons.image_outlined, color: Color(0xFF8D8087)),
          ),
        );
  }
}
