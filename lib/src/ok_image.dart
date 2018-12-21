import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ok_image/src/cache/cache_delegate.dart';
import 'package:ok_image/src/cache/default_cache_delegate.dart';
import 'package:ok_image/src/default_error_widget.dart';
import 'package:ok_image/src/request_helper.dart';

class OKImage extends StatefulWidget {
  final String url;
  final double width;
  final double height;
  final BoxFit boxFit;
  final Widget loadingWidget;
  final Widget errorWidget;
  final int retry;
  final Duration timeout;
  final Function onErrorTap;
  final CacheDelegate cacheDelegate;
  final bool followRedirects;

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
  })  : boxFit = fit ?? BoxFit.cover,
        super(key: key);

  @override
  _OKImageState createState() => _OKImageState();
}

class _OKImageState extends State<OKImage> {
  Widget get loadingWidget => widget.loadingWidget ?? ProgressWidget();

  Widget errorWidget(err) =>
      widget.errorWidget ??
      Container(
        width: width,
        height: height,
        color: Colors.grey.withOpacity(0.6),
        child: DefaultErrorWidget(),
      );

  double get width => widget.width;

  double get height => widget.height;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CacheDelegate delegate = widget.cacheDelegate ?? defaultCache;

    if (isDownload(widget.url)) {
      return SizedBox(
        width: width,
        height: height,
        child: Image.memory(
          getImageBytes(widget.url),
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
    } else if (snapshot.data != null) {
      w = Image.memory(
        snapshot.data,
        fit: widget.boxFit,
      );
    } else {
      w = loadingWidget;
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
