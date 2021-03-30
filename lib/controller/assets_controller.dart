import 'package:coupons_backend/coupons_backend.dart';

class AssetsController extends FileController {
  AssetsController(String pathOfDirectoryToServe) : super(pathOfDirectoryToServe);

  /// adds missing DELETE implementation to [FileController]
  @override
  Future<RequestOrResponse> handle(Request request) async {
    // check for DELETE method and launch custom code accordingly
    if (request.method == 'DELETE' && request.authorization.isAuthorizedForScope('admin')) {
      final filename = request.path.remainingPath;
      final file = File('$assetsFolderPath${Platform.pathSeparator}$filename');

      if (!file.existsSync()) {
        return Response.badRequest();
      }

      await file.delete();

      if (!file.existsSync()) {
        return Response.ok(null);
      } else {
        return Response.badRequest();
      }
    }
    // if method!=DELETE go to parent implementation
    return super.handle(request);
  }
}
