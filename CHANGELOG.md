# CHANGELOG

## [0.4.0]

**Breaking change**:
Params `errorWidget` change type to `ErrorWidgetBuilder`.

fix:

- Download error bug.

## [0.3.1] upgrade dependencies version

- path_provider
- rx_dart
- http

## [0.3.0] upgrade path_provider

**breaking change**
because path_provider migrate from android support to androidX, so your other plugin also need be migrated.
upgrade rxdart

## [0.2.3] add remove cache

ImageCache.removeCache(String url);

## [0.2.2] request

add a parameter to delete the cache whose last access time exceeds duration

add onImageLoadState callback

## [0.2.1] un-ext image load error

Fix: Unextended images cannot be loaded

## [0.2.0]

global error and loading widget

add a clear cache method

upgrade rxdart version

fix bug for downloading

## [0.1.1] fix load bug

fix error bug

## [0.1.0] update request and cache

Now the same URL will share a download, waiting for the download to complete and return together.

### +1

update readme

## [0.0.3] add cache delegate

add a default cache delegate to cache image

## [0.0.2] ADD LICENSE

use MIT

## [0.0.1] first version
