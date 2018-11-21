import 'dart:typed_data';

import 'package:flutter/material.dart';
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

  const OKImage({
    Key key,
    @required this.url,
    this.width,
    this.height,
    this.loadingWidget,
    this.errorWidget,
    this.retry = 5,
    this.boxFit,
    this.timeout = const Duration(seconds: 15),
  }) : super(key: key);

  @override
  _OKImageState createState() => _OKImageState();
}

class _OKImageState extends State<OKImage> {
  Widget get loadingWidget =>
      widget.loadingWidget ??
      Container(
        width: widget.width,
        height: widget.height,
      );

  Widget errorWidget(err) =>
      widget.errorWidget ??
      Container(
        child: ErrorWidget(err),
      );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      builder: _buildImage,
      future: RequestHelper.requestImage(
        widget.url,
        widget.retry,
        widget.timeout,
      ),
    );
  }

  Widget _buildImage(BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
    if (snapshot.hasError) {
      return errorWidget(snapshot.error);
    }
    if (snapshot.data != null) {
      return Image.memory(snapshot.data);
    }

    return loadingWidget;
  }
}
