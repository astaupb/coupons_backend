import 'dart:io';

import 'package:aqueduct/aqueduct.dart';
import '../coupons_backend.dart';

class UploadController extends ResourceController {
  UploadController(this.context) {
    acceptedContentTypes = [
      ContentType('image', 'png'),
      ContentType('image', 'jpeg'),
      ContentType('image', 'tiff'),
      ContentType('image', 'apng'),
      ContentType('image', 'webp'),
      ContentType('image', 'gif'),
      ContentType('image', 'x-mng'),
      ContentType('image', 'x-icon'),
      ContentType('image', '')
    ];
  }
  final ManagedContext context;

  @Operation.post()
  Future<Response> postForm(@Bind.body() File upload) async {
    await upload.create();
    return Response.created(upload.path.toString());
  }
}
