import 'dart:io';

import 'package:aqueduct/aqueduct.dart';
import 'package:mime/mime.dart';

import '../coupons_backend.dart';

const Map<List<int>, String> supportedTypes = <List<int>, String>{
  [0xFF, 0xD8]: 'image/jpeg',
  [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]: 'image/png',
  [0x47, 0x49, 0x46, 0x38]: 'image/gif',
  [0x42, 0x4D]: 'image/bmp',
};

class UploadController extends ResourceController {
  UploadController() {
    mimeChecker = MimeTypeResolver();
    supportedTypes.forEach(mimeChecker.addMagicNumber);
    acceptedContentTypes = supportedTypes.values
        .map((String e) => ContentType(e.split('/').first, e.split('/').last))
        .toList();
  }

  MimeTypeResolver mimeChecker;

  @Operation.get()
  Future<Response> getFiles() async {
    final assetsDir = Directory('assets');
    final files = <String>[];
    await assetsDir
        .list(recursive: true, followLinks: false)
        .listen((FileSystemEntity entity) {
      files.add(entity.path.split(Platform.pathSeparator).last);
    }).asFuture();

    files.sort();

    return Response.ok(files.toString());
  }

  @Operation.post()
  Future<Response> postFile() async {
    const assetsFolderPath = 'assets';
    var filename = '${DateTime.now().millisecondsSinceEpoch}';
    final newFilePath = '$assetsFolderPath${Platform.pathSeparator}$filename';

    // read response and write to file
    final bodyBytes = await request.body.decode<List<int>>();
    final contentType = request.raw.headers['Content-Type'].single;
    var file = await File(newFilePath).writeAsBytes(bodyBytes);

    final mimeType =
        mimeChecker.lookup(file.path, headerBytes: bodyBytes.take(8).toList());

    // check mimetype and append suffix to filename
    if (contentType == null || mimeType != contentType) {
      await file.delete();
      return Response.badRequest(
          body: 'content-type not given or inconsistent with file');
    }

    try {
      filename += '.${acceptedContentTypes.singleWhere((ContentType type) {
            print('${type.mimeType} == $contentType');
            return type.mimeType == contentType;
          }).mimeType.split('/').last}';
    } catch (e) {
      await file.delete();
      return Response.badRequest(body: e.toString());
    }

    file = await file
        .rename('$assetsFolderPath${Platform.pathSeparator}$filename');

    // return name if file was successfully renamed
    if (file.existsSync()) {
      return Response.ok(filename);
    } else {
      await file.delete();
      return Response.noContent();
    }
  }
}
