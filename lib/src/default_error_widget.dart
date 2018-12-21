import 'package:flutter/material.dart';

class DefaultErrorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.error,
      size: 55.0,
      color: Theme.of(context).primaryColor,
    );
  }
}
