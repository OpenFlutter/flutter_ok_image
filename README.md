# OKImage

Easy to use this library to build a network image widget, you can build different layouts according to the error/load, also set up the image cache delegate.

[![pub package](https://img.shields.io/pub/v/ok_image.svg)](https://pub.dartlang.org/packages/ok_image)
![GitHub](https://img.shields.io/github/license/OpenFlutter/flutter_ok_image.svg)
[![GitHub stars](https://img.shields.io/github/stars/OpenFlutter/flutter_ok_image.svg?style=social&label=Stars)](https://github.com/OpenFlutter/flutter_ok_image)

## use

1. add to your pubspec.yaml

```yaml
ok_image: ^0.1.0+1
```

2. import

```dart
import "package:ok_image/ok_image.dart";
```

3. use

```dart
import "package:ok_image/ok_image.dart";
createWidget(){
  return OKImage(
      url: "https://ws1.sinaimg.cn/large/844036b9ly1fxfo76hzd4j20zk0nc48i.jpg",
      width: 200,
      height: 200,
      timeout: Duration(seconds: 20),
      fit: fit,
    );
}
```

4. params

```markdown
url: image net url
width: width
height: height
fit: show BoxFit
followRedirects: whether image redirection is allowed.
loadingWidget: display on loading
errorWidget: display when image load error / timeout.
retry: retry to load image count.
timeout: timeout duration.
onErrorTap: when loadErrorWidget show ,onTap it.
cacheDelegate: you can use the param to delegate loadImage
```

## about other library

This library uses [http](https://pub.dartlang.org/packages/http) as a framework for network access.  
Using [rxdart](https://pub.dartlang.org/packages/rxdart) processing logic

thanks to open source.
