import 'package:aqueduct/aqueduct.dart';
import '../coupons_backend.dart';
import '../model/metadata.dart';
import '../model/vendor.dart';

class VendorController extends ResourceController {
  VendorController(this.context);

  final ManagedContext context;

  @Scope(['user'])
  @Operation.get()
  Future<Response> getAllVendor({@Bind.query('name') String name}) async {
    final vendorQuery = Query<Vendor>(context);
    if (name != null) {
      vendorQuery.where((v) => v.name).contains(name, caseSensitive: false);
    }
    final vendors = await vendorQuery.fetch();

    return Response.ok(vendors);
  }

  @Scope(['user'])
  @Operation.get('id')
  Future<Response> getVenodorByID(@Bind.path('id') int id) async {
    final vendorQuery = Query<Vendor>(context)..where((v) => v.id).equalTo(id);
    final vendor = await vendorQuery.fetchOne();
    if (vendor == null) {
      return Response.notFound();
    }
    return Response.ok(vendor);
  }

  @Scope(['admin'])
  @Operation.post()
  Future<Response> createVendor() async {
    if (request.body.isEmpty) {
      return Response.badRequest();
    }
    final vendor = Vendor()..read(await request.body.decode(), ignore: ['id']);
    if (vendor.name == null) {
      return Response.badRequest();
    }

    final vendorQuery = Query<Vendor>(context)..values = vendor;

    final insertedVendor = await vendorQuery.insert();

    final now = DateTime.now().toUtc();
    final accessMetaDataVendorQuery = Query<MetadataVendor>(context)
      ..values.changedAt = now
      ..values.createdAt = now
      ..values.vendor = insertedVendor;

    final insertedAccessMetaDataVendorQuery =
        await accessMetaDataVendorQuery.insert();

    if (insertedAccessMetaDataVendorQuery == null) {
      return Response.notFound();
    }
    return Response.ok(insertedVendor);
  }

  @override
  APIRequestBody documentOperationRequestBody(
      APIDocumentContext context, Operation operation) {
    if (operation.method == "POST") {
      return APIRequestBody.schema(context.schema['Vendor']);
    }
    return null;
  }

  @override
  Map<String, APIResponse> documentOperationResponses(
      APIDocumentContext context, Operation operation) {
    if (operation.method == "GET") {
      if (operation.pathVariables.contains("id")) {
        return {
          "200":
              APIResponse.schema("Get a vendor by id", context.schema['Vendor'])
        };
      } else {
        return {
          "200": APIResponse.schema("All vendor", context.schema['Vendor'])
        };
      }
    } else if (operation.method == "POST") {
      return {
        "200": APIResponse.schema("Add a vendor", context.schema['Vendor'])
      };
    }
    return {"400": APIResponse("Unknown error")};
  }
}
