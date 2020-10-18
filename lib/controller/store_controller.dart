import 'package:aqueduct/aqueduct.dart';
import '../coupons_backend.dart';
import '../model/metadata.dart';
import '../model/store.dart';
import '../model/vendor.dart';

class StoreController extends ResourceController {
  StoreController(this.context);

  final ManagedContext context;

  @Scope([ 'user'])
  @Operation.get('vendorID')
  Future<Response> getAllStoresByVendorID(@Bind.path('vendorID') int vendorid,
      {@Bind.query('name') String name}) async {
    final storeQuery = Query<Store>(context);
    storeQuery.where((s) => s.vendor.id).equalTo(vendorid);
    if (name != null) {
      storeQuery.where((s) => s.name).contains(name, caseSensitive: false);
    }
    final store = await storeQuery.fetch();
    if (store == null) {
      return Response.notFound();
    }
    return Response.ok(store);
  }

  @Scope(['user'])
  @Operation.get('vendorID', 'id')
  Future<Response> getStoresByIDByVendorID(
      @Bind.path('vendorID') int vendorID, @Bind.path('id') int id) async {
    final storeQuery = Query<Store>(context);
    storeQuery
      ..where((s) => s.vendor.id).equalTo(vendorID)
      ..where((s) => s.id).equalTo(id);
    final store = await storeQuery.fetch();
    if (store == null) {
      return Response.notFound();
    }
    return Response.ok(store);
  }
  
  @Scope(['admin'])
  @Operation.post('vendorID')
  Future<Response> postStoreByVendorID(
      @Bind.path('vendorID') int vendorID) async {
    if (request.body.isEmpty) {
      return Response.badRequest();
    }

    final vendorQuery = Query<Vendor>(context)
      ..where((v) => v.id).equalTo(vendorID);

    final vendor = await vendorQuery.fetchOne();

    if (vendor == null) {
      return Response.badRequest();
    }

    final store = Store()
      ..read(await request.body.decode(), ignore: [
        'id',
      ])
      ..vendor = vendor;

    final query = Query<Store>(context)..values = store;

    final insertedStore = await query.insert();
    final now = DateTime.now().toUtc();
    final accessMetaDataStore = Query<AccessMetaDataStore>(context)
      ..values.changedAt = now
      ..values.createdAt = now
      ..values.store = insertedStore;

    final insertedAccesMetaDataStore = accessMetaDataStore.insert();

    if (insertedStore == null || insertedAccesMetaDataStore == null) {
      return Response.serverError();
    }

    return Response.ok(insertedStore);
  }

  @override
  APIRequestBody documentOperationRequestBody(
      APIDocumentContext context, Operation operation) {
    if (operation.method == "POST") {
      return APIRequestBody.schema(context.schema['Store']);
    }
    return null;
  }

  @override
  Map<String, APIResponse> documentOperationResponses(
      APIDocumentContext context, Operation operation) {
    if (operation.method == 'GET') {
      return {"200": APIResponse.schema("Get store", context.schema['Store'])};
    } else if (operation.method == 'POST') {
      return {"200": APIResponse.schema("Post store", context.schema['Store'])};
    }

    return {"400": APIResponse("Unknown error")};
  }
}
