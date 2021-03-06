import 'package:aqueduct/aqueduct.dart';

import '../coupons_backend.dart';
import '../model/metadata.dart';
import '../model/vendor.dart';

class VendorController extends ResourceController {
  final ManagedContext context;

  VendorController(this.context);

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
    final accessMetaDataVendorQuery = Query<VendorMetadata>(context)
      ..values.changedAt = now
      ..values.createdAt = now
      ..values.vendor = insertedVendor;

    final insertedAccessMetaDataVendorQuery = await accessMetaDataVendorQuery.insert();

    if (insertedAccessMetaDataVendorQuery == null) {
      return Response.notFound();
    }
    return Response.ok(insertedVendor);
  }

  @Scope(['admin'])
  @Operation.delete('id')
  Future<Response> deleteVendor(@Bind.path('id') int id) async {
    final deleteQuery = Query<Vendor>(context)..where((v) => v.id).equalTo(id);

    final delete = await deleteQuery.delete();
    if (delete == null) {
      return Response.notFound();
    }

    return Response.ok(delete);
  }

  @override
  APIRequestBody documentOperationRequestBody(APIDocumentContext context, Operation operation) {
    if (operation.method == 'POST') {
      return APIRequestBody.schema(context.schema['Vendor']);
    } else if (operation.method == 'PUT') {
      return APIRequestBody.schema(context.schema['Vendor']);
    }
    return null;
  }

  @override
  Map<String, APIResponse> documentOperationResponses(
      APIDocumentContext context, Operation operation) {
    if (operation.method == 'GET') {
      if (operation.pathVariables.contains('id')) {
        return {'200': APIResponse.schema('Get a vendor by id', context.schema['Vendor'])};
      } else {
        return {'200': APIResponse.schema('All vendor', context.schema['Vendor'])};
      }
    } else if (operation.method == 'POST') {
      return {'200': APIResponse.schema('Add a vendor', context.schema['Vendor'])};
    }
    return {'400': APIResponse('Unkown error')};
  }

  @Scope(['user'])
  @Operation.get()
  Future<Response> getAllVendor({
    @Bind.query('name') String name,
    @Bind.query('slim') String slim,
  }) async {
    final vendorQuery = Query<Vendor>(context);
    if (name != null) {
      vendorQuery.where((v) => v.name).contains(name, caseSensitive: false);
    }
    if (slim == 'true') {
      vendorQuery.returningProperties((Vendor v) => <dynamic>[v.id, v.name, v.properties]);
    }
    final vendors = await vendorQuery.fetch();

    if (slim == 'true') {
      vendors.forEach((Vendor v) {
        if (v.properties?.data != null) {
          (v.properties.data as Map<String, dynamic>).removeWhere(
              (String key, dynamic value) => key == 'image' || key == 'logo' || key == 'product');
        }
      });
    }

    return Response.ok(vendors);
  }

  @Scope(['user'])
  @Operation.get('id')
  Future<Response> getVendorByID(@Bind.path('id') int id) async {
    final vendorQuery = Query<Vendor>(context)..where((v) => v.id).equalTo(id);
    final vendor = await vendorQuery.fetch();
    if (vendor == null) {
      return Response.notFound();
    }
    return Response.ok(vendor);
  }

  @Scope(['admin'])
  @Operation.put('id')
  Future<Response> updateVendor(
      @Bind.path('id') int id, @Bind.body(ignore: ['id', 'metadataVendor']) Vendor vendor) async {
    final updateQuery = Query<Vendor>(context)
      ..where((v) => v.id).equalTo(id)
      ..values = vendor;

    final update = await updateQuery.updateOne();

    if (update == null) {
      return Response.notFound();
    }

    final now = DateTime.now().toUtc();

    final updateMetadataQuery = Query<VendorMetadata>(context)
      ..where((m) => m.vendor.id).equalTo(id)
      ..values.changedAt = now;

    final updateMetadata = updateMetadataQuery.updateOne();
    if (updateMetadata == null) {
      return Response.serverError();
    }
    return Response.ok(update);
  }
}
