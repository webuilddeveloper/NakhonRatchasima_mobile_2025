import 'dart:io';
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

  ImageProvider _getImageProvider(String url) {
    if (url.startsWith('assets/')) {
      return AssetImage(url);
    } else if (url.startsWith('/') || url.startsWith('file://')) {
      final path = url.replaceFirst('file://', '');
      return FileImage(File(path));
    }
    return NetworkImage(url);
  }

  Widget _renderImage(String url, {BoxFit fit = BoxFit.cover, double? width, double? height}) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else if (url.startsWith('/') || url.startsWith('file://')) {
      final path = url.replaceFirst('file://', '');
      return Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  void _resolveImage() {
    final imageUrl = widget.imageUrl.trim();
    if (imageUrl.isEmpty || imageUrl == _resolvedUrl) return;

    _removeImageListener();
    _resolvedUrl = imageUrl;
    final stream = _getImageProvider(imageUrl).resolve(
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
            return _renderImage(
              widget.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              _renderImage(
                widget.imageUrl,
                fit: BoxFit.cover,
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: ColoredBox(
                  color: Colors.white.withValues(alpha: 0.28),
                ),
              ),
              _renderImage(
                widget.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
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
