import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ok_image/src/cache/cache_delegate.dart';
import 'package:ok_image/src/cache/default_cache_delegate.dart';
import 'package:ok_image/src/default_error_widget.dart';
import 'package:ok_image/src/request_helper.dart';

class OKImage extends StatefulWidget {
  /// update error widget for global
  static ValueGetter<Widget> buildErrorWidget = () => DefaultErrorWidget();

  /// update loading widget for global
  static ValueGetter<Widget> buildLoadingWidget = () => ProgressWidget();

  /// net image url
  final String url;

  /// like [Image.width]
  final double width;

  /// like [Image.height]
  final double height;

  /// like [Image.fit]
  final BoxFit boxFit;

  /// loading widget
  final Widget loadingWidget;

  /// on load error widget
  final Widget errorWidget;

  /// Number of retries
  final int retry;

  /// timeout for load
  final Duration timeout;

  /// After an error occurs, click on the event
  final Function onErrorTap;

  /// you can use your self cache delegate
  final CacheDelegate cacheDelegate;

  /// When followRedirects occurs, whether to continue accessing or not, and when followRedirects occurs, false is regarded as a failure of accessing.
  final bool followRedirects;

  /// Experimental , Callback when the loading state changes
  final ValueChanged<OnLoadState> onLoadStateChanged;

  const OKImage({
    Key key,
    @required this.url,
    this.width,
    this.height,
    this.loadingWidget,
    this.errorWidget,
    this.retry = 5,
    BoxFit fit,
    this.timeout = const Duration(seconds: 15),
    this.onErrorTap,
    this.cacheDelegate,
    this.followRedirects = false,
    this.onLoadStateChanged,
  })  : boxFit = fit ?? BoxFit.cover,
        super(key: key);

  @override
  _OKImageState createState() => _OKImageState();
}

class _OKImageState extends State<OKImage> {
  Widget get loadingWidget =>
      widget.loadingWidget ?? OKImage.buildLoadingWidget();

  Widget errorWidget(err) => Container(
        width: width,
        height: height,
        child: widget.errorWidget ?? OKImage.buildErrorWidget(),
      );

  double get width => widget.width;

  double get height => widget.height;

  void _onLoadStateChanged(OnLoadState state) {
    widget.onLoadStateChanged?.call(state);
  }

  @override
  void initState() {
    super.initState();
    _onLoadStateChanged(OnLoadState.loadStart);
  }

  @override
  Widget build(BuildContext context) {
    CacheDelegate delegate = widget.cacheDelegate ?? defaultCache;

    if (isDownloaded(widget.url) &&
        (getCacheImageFile(widget.url)?.existsSync() == true)) {
      _onLoadStateChanged(OnLoadState.loadEnd);
      return SizedBox(
        width: width,
        height: height,
        child: Image.file(
          getCacheImageFile(widget.url),
          fit: widget.boxFit,
        ),
      );
    }

    return FutureBuilder<Uint8List>(
      builder: _buildImage,
      future: RequestHelper.requestImage(
        widget.url,
        widget.retry,
        widget.timeout,
        cacheDelegate: delegate,
        followRedirects: widget.followRedirects,
      ),
    );
  }

  Widget _buildImage(BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
    Widget w;
    if (snapshot.hasError) {
      w = errorWidget(snapshot.error);
      w = wrapErrorTap(w);
      _onLoadStateChanged(OnLoadState.loadFail);
    } else if (snapshot.data != null) {
      w = Image.memory(
        snapshot.data,
        fit: widget.boxFit,
      );
      _onLoadStateChanged(OnLoadState.loadEnd);
    } else {
      w = loadingWidget;
      _onLoadStateChanged(OnLoadState.loading);
    }

    return SizedBox(
      width: width,
      height: height,
      child: w,
    );
  }

  Widget wrapErrorTap(Widget child) {
    if (widget.onErrorTap == null) {
      return child;
    }
    return GestureDetector(
      onTap: widget.onErrorTap,
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}

class ProgressWidget extends StatelessWidget {
  final double width;
  final double height;

  const ProgressWidget({
    Key key,
    this.width = 40.0,
    this.height = 40.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget w;
    var platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS) {
      w = CupertinoActivityIndicator();
    } else {
      w = CircularProgressIndicator();
    }

    return Container(
      child: SizedBox(
        child: w,
        width: width,
        height: height,
      ),
    );
  }
}

/// Experimental
enum OnLoadState {
  loadStart,
  loading,
  loadEnd,
  loadFail,
}
