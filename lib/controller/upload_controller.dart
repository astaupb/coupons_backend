import 'package:aqueduct/aqueduct.dart';
import 'package:mime/mime.dart';
import '../coupons_backend.dart';

class UploadController extends ResourceController {
  UploadController() {
    acceptedContentTypes = [ContentType('multipart', 'form-data')];
  }

  @Operation.post()
  Future<Response> postForm() async {
    final boundary = request.raw.headers.contentType.parameters['boundary'];
    final transformer = MimeMultipartTransformer(boundary);
    final bodyBytes = await request.body.decode<List<int>>();

    final bodyStream = Stream.fromIterable([bodyBytes]);
    final parts = await transformer.bind(bodyStream).toList();

    for (var part in parts) {
      
    }
  }
}
