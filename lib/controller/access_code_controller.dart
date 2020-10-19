import 'package:aqueduct/aqueduct.dart';
import 'package:uuid/uuid.dart';
import '../coupons_backend.dart';
import '../model/access_codes.dart';

class AccessCodeController extends ResourceController {
  AccessCodeController(this.context);

  final ManagedContext context;

  @Scope(['admin'])
  @Operation.get()
  Future<Response> getAllAccessCodes({@Bind.query('role') String role}) async {
    final accessCodeQuery = Query<AccessCode>(context);
    if (role != null) {
      accessCodeQuery.where((a) => a.role).contains(role, caseSensitive: false);
    }

    final accessCode = await accessCodeQuery.fetch();

    if (accessCode == null) {
      return Response.notFound();
    }

    return Response.ok(accessCode);
  }

  @Scope(['admin'])
  @Operation.post()
  Future<Response> postAccessCode() async {
    final accessCodePost = Query<AccessCode>(context);
    if (request.body.isEmpty) {
      return Response.notFound();
    }

    final accessCode = AccessCode()
      ..read(await request.body.decode(), ignore: ['id']);

    accessCodePost.values = accessCode;

    if (accessCodePost.values.code == null) {
      final uuid = Uuid();
      accessCodePost.values.code = uuid.v4();
    }

    final accessCodeInserted = await accessCodePost.insert();

    if (accessCodeInserted == null) {
      return Response.serverError();
    }
    return Response.ok(accessCodeInserted);
  }

  @override
  APIRequestBody documentOperationRequestBody(
      APIDocumentContext context, Operation operation) {
    if (operation.method == "POST") {
      return APIRequestBody.schema(context.schema['AccessCode']);
    }
    return null;
  }

  @override
  Map<String, APIResponse> documentOperationResponses(
      APIDocumentContext context, Operation operation) {
    if (operation.method == "GET") {
      if (operation.pathVariables.contains("role")) {
        return {
          "200": APIResponse.schema(
              "Get access codes by role", context.schema['AccessCode'])
        };
      } else {
        return {
          "200": APIResponse.schema(
              "Get all access codes", context.schema['AccessCode'])
        };
      }
    } else if (operation.method == 'POST') {
      return {
        "200":
            APIResponse.schema("Add access codes", context.schema['AccessCode'])
      };
    }
    return {"400": APIResponse("Unknow error")};
  }
}
