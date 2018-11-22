# OKImage

You can easily use this library to build a network load gallery, you can build different layouts according to the error/load, you can also set up the image cache delegation.

## use

1. add to your pubspec.yaml

```yaml
ok_image: ^0.0.1
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
