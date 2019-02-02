# OKImage

Easy to use this library to build a network image widget, you can build different layouts according to the error/load, also set up the image cache delegate.

[![pub package](https://img.shields.io/pub/v/ok_image.svg)](https://pub.dartlang.org/packages/ok_image)
![GitHub](https://img.shields.io/github/license/OpenFlutter/flutter_ok_image.svg)
[![GitHub stars](https://img.shields.io/github/stars/OpenFlutter/flutter_ok_image.svg?style=social&label=Stars)](https://github.com/OpenFlutter/flutter_ok_image)

## use

1. add to your pubspec.yaml

```yaml
ok_image: ^0.2.3
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

Experimental: Signatures, return values, parameters and other information may be modified in the future.

```md
onLoadStateChanged: will be call on the load state changed.
```

5. global config

edit `OKImage.buildErrorWidget` to config global OKImage errorWidget.

edit `OKImage.buildLoadingWidget` to config global OKImage loading.

## about other library

This library uses [http 0.12.0](https://pub.dartlang.org/packages/http) as a framework for network access.  
Using [rxdart 0.20.0](https://pub.dartlang.org/packages/rxdart) processing logic

using [path_provider 0.4.1](https://pub.dartlang.org/packages/path_provider) to get default catch path.
using [crypto 2.0.6](https://pub.dartlang.org/packages/crypto) to make and check md5.

thanks to open source.

If you are using older versions of these open source libraries, which cause incompatibility, please update your.
If it is incompatible with me, please contact me and I will update the version number when appropriate.
