import 'package:flutter/widgets.dart';

import '../photo_view.dart';
import 'core/photo_view_core.dart';
import 'photo_view_default_widgets.dart';
import 'utils/photo_view_utils.dart';

class ImageWrapper extends StatefulWidget {
  const ImageWrapper({
    Key key,
    @required this.imageProvider,
    @required this.loadingBuilder,
    @required this.backgroundDecoration,
    @required this.gaplessPlayback,
    @required this.heroAttributes,
    @required this.scaleStateChangedCallback,
    @required this.enableRotation,
    @required this.controller,
    @required this.scaleStateController,
    @required this.maxScale,
    @required this.minScale,
    @required this.initialScale,
    @required this.basePosition,
    @required this.scaleStateCycle,
    @required this.onTapUp,
    @required this.onTapDown,
    @required this.outerSize,
    @required this.gestureDetectorBehavior,
    @required this.tightMode,
    @required this.filterQuality,
    @required this.disableGestures,
    @required this.errorBuilder,
  }) : super(key: key);

  final ImageProvider imageProvider;
  final LoadingBuilder loadingBuilder;
  final ImageErrorWidgetBuilder errorBuilder;
  final Decoration backgroundDecoration;
  final bool gaplessPlayback;
  final PhotoViewHeroAttributes heroAttributes;
  final ValueChanged<PhotoViewScaleState> scaleStateChangedCallback;
  final bool enableRotation;
  final dynamic maxScale;
  final dynamic minScale;
  final dynamic initialScale;
  final PhotoViewControllerBase controller;
  final PhotoViewScaleStateController scaleStateController;
  final Alignment basePosition;
  final ScaleStateCycle scaleStateCycle;
  final PhotoViewImageTapUpCallback onTapUp;
  final PhotoViewImageTapDownCallback onTapDown;
  final Size outerSize;
  final HitTestBehavior gestureDetectorBehavior;
  final bool tightMode;
  final FilterQuality filterQuality;
  final bool disableGestures;

  @override
  _ImageWrapperState createState() => _ImageWrapperState();
}

class _ImageWrapperState extends State<ImageWrapper> {
  ImageStreamListener _imageStreamListener;
  ImageStream _imageStream;
  ImageChunkEvent _imageChunkEvent;
  ImageInfo _imageInfo;
  bool _loading = true;
  Size _imageSize;
  Object _lastException;
  StackTrace _stackTrace;

  // retrieve image from the provider
  void _getImage() {
    final ImageStream newStream = widget.imageProvider.resolve(
      const ImageConfiguration(),
    );
    _updateSourceStream(newStream);
  }

  ImageStreamListener _getOrCreateListener() {
    void handleImageChunk(ImageChunkEvent event) {
      assert(widget.loadingBuilder != null);
      setState(() => _imageChunkEvent = event);
    }

    void handleImageFrame(ImageInfo info, bool synchronousCall) {
      final setupCB = () {
        _imageSize = Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        );
        _loading = false;
        _imageInfo = _imageInfo;

        _imageChunkEvent = null;
        _lastException = null;
        _stackTrace = null;
      };
      synchronousCall ? setupCB() : setState(setupCB);
    }

    void handleError(dynamic error, StackTrace stackTrace) {
      setState(() {
        _loading = false;
        _lastException = error;
        _stackTrace = stackTrace;
      });
    }

    _imageStreamListener = ImageStreamListener(
      handleImageFrame,
      onChunk: handleImageChunk,
      onError: handleError,
    );

    return _imageStreamListener;
  }

  void _updateSourceStream(ImageStream newStream) {
    if (_imageStream?.key == newStream.key) {
      return;
    }
    _imageStream?.removeListener(_imageStreamListener);
    _imageStream = newStream;
    _imageStream.addListener(_getOrCreateListener());
  }

  void _stopImageStream() {
    if (_imageStream != null) {
      _imageStream.removeListener(_imageStreamListener);
    }
  }

  @override
  void didUpdateWidget(ImageWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != oldWidget.imageProvider) {
      _getImage();
    }
  }

  @override
  void didChangeDependencies() {
    _getImage();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _stopImageStream();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildLoading(context);
    }

    if (_lastException != null) {
      return _buildError(context);
    }

    final scaleBoundaries = ScaleBoundaries(
      widget.minScale ?? 0.0,
      widget.maxScale ?? double.infinity,
      widget.initialScale ?? PhotoViewComputedScale.contained,
      widget.outerSize,
      _imageSize,
    );

    return PhotoViewCore(
      imageProvider: widget.imageProvider,
      backgroundDecoration: widget.backgroundDecoration,
      gaplessPlayback: widget.gaplessPlayback,
      enableRotation: widget.enableRotation,
      heroAttributes: widget.heroAttributes,
      basePosition: widget.basePosition ?? Alignment.center,
      controller: widget.controller,
      scaleStateController: widget.scaleStateController,
      scaleStateCycle: widget.scaleStateCycle ?? defaultScaleStateCycle,
      scaleBoundaries: scaleBoundaries,
      onTapUp: widget.onTapUp,
      onTapDown: widget.onTapDown,
      gestureDetectorBehavior: widget.gestureDetectorBehavior,
      tightMode: widget.tightMode ?? false,
      filterQuality: widget.filterQuality ?? FilterQuality.none,
      disableGestures: widget.disableGestures ?? false,
    );
  }

  Widget _buildLoading(BuildContext context) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder(context, _imageChunkEvent);
    }

    return PhotoViewDefaultLoading(
      event: _imageChunkEvent,
    );
  }

  Widget _buildError(
    BuildContext context,
  ) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder(context, _lastException, _stackTrace);
    }
    return PhotoViewDefaultError(
      decoration: widget.backgroundDecoration,
    );
  }
}

class CustomChildWrapper extends StatelessWidget {
  const CustomChildWrapper({
    Key key,
    @required this.child,
    @required this.childSize,
    @required this.backgroundDecoration,
    @required this.heroAttributes,
    @required this.scaleStateChangedCallback,
    @required this.enableRotation,
    @required this.controller,
    @required this.scaleStateController,
    @required this.maxScale,
    @required this.minScale,
    @required this.initialScale,
    @required this.basePosition,
    @required this.scaleStateCycle,
    @required this.onTapUp,
    @required this.onTapDown,
    @required this.outerSize,
    @required this.gestureDetectorBehavior,
    @required this.tightMode,
    @required this.filterQuality,
    @required this.disableGestures,
  }) : super(key: key);

  final Widget child;
  final Size childSize;
  final Decoration backgroundDecoration;
  final PhotoViewHeroAttributes heroAttributes;
  final ValueChanged<PhotoViewScaleState> scaleStateChangedCallback;
  final bool enableRotation;

  final PhotoViewControllerBase controller;
  final PhotoViewScaleStateController scaleStateController;

  final dynamic maxScale;
  final dynamic minScale;
  final dynamic initialScale;

  final Alignment basePosition;
  final ScaleStateCycle scaleStateCycle;
  final PhotoViewImageTapUpCallback onTapUp;
  final PhotoViewImageTapDownCallback onTapDown;
  final Size outerSize;
  final HitTestBehavior gestureDetectorBehavior;
  final bool tightMode;
  final FilterQuality filterQuality;
  final bool disableGestures;

  @override
  Widget build(BuildContext context) {
    final scaleBoundaries = ScaleBoundaries(
      minScale ?? 0.0,
      maxScale ?? double.infinity,
      initialScale ?? PhotoViewComputedScale.contained,
      outerSize,
      childSize ?? outerSize,
    );

    return PhotoViewCore.customChild(
      customChild: child,
      backgroundDecoration: backgroundDecoration,
      enableRotation: enableRotation,
      heroAttributes: heroAttributes,
      controller: controller,
      scaleStateController: scaleStateController,
      scaleStateCycle: scaleStateCycle ?? defaultScaleStateCycle,
      basePosition: basePosition ?? Alignment.center,
      scaleBoundaries: scaleBoundaries,
      onTapUp: onTapUp,
      onTapDown: onTapDown,
      gestureDetectorBehavior: gestureDetectorBehavior,
      tightMode: tightMode ?? false,
      filterQuality: filterQuality ?? FilterQuality.none,
      disableGestures: disableGestures ?? false,
    );
  }
}
