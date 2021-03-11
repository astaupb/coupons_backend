import 'dart:io';

import 'package:aqueduct/aqueduct.dart';
import '../coupons_backend.dart';

class UploadController extends ResourceController {
  UploadController() {
    acceptedContentTypes = [ContentType("image", "png")];
  }

  @Operation.get()
  Future<Response> getFiles() async {
    final assetsDir = Directory('assets');
    final files = [];
    assetsDir
        .list(recursive: true, followLinks: false)
        .listen((FileSystemEntity entity) {
      files.add(entity.path.split('/').last);
    });

    return Response.ok(files.toString());
  }

  @Operation.post()
  Future<Response> postPng() async {
    final bodyBytes = await request.body.decode<List<int>>();
    final filename = '${DateTime.now().millisecondsSinceEpoch.toString()}.png';
    final file = await File('assets/${filename}').writeAsBytes(bodyBytes);
    if (file.existsSync()) {
      return Response.ok(filename);
    } else {
      return Response.noContent();
    }
  }
}
