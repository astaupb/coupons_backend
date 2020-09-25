import 'package:aqueduct/aqueduct.dart';
import 'package:coupons_backend/coupons_backend.dart';
import 'package:coupons_backend/model/access_meta_data.dart';
import 'package:coupons_backend/model/vendor.dart';

class VendorController extends ResourceController {
  VendorController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getAllVendor({@Bind.query('name') String name}) async {
    final vendorQuery = Query<Vendor>(context);
    if (name != null) {
      vendorQuery.where((v) => v.name).contains(name, caseSensitive: false);
    }
    final vendors = await vendorQuery.fetch();

    return Response.ok(vendors);
  }

  @Operation.get('id')
  Future<Response> getVenodorByID(@Bind.path('id') int id) async {
    final vendorQuery = Query<Vendor>(context)..where((v) => v.id).equalTo(id);
    final vendor = await vendorQuery.fetchOne();
    if (vendor == null) {
      return Response.notFound();
    }
    return Response.ok(vendor);
  }

  @Operation.post()
  Future<Response> createVendor() async {
    if (request.body.isEmpty) {
      return Response.badRequest();
    }
    final vendor = Vendor()
      ..read(await request.body.decode(), ignore: ['id']);
    if (vendor.name == null) {
      return Response.badRequest();
    }

    final vendorQuery = Query<Vendor>(context)..values = vendor;

    final insertedVendor = await vendorQuery.insert();

    final accessMetaDataVendorQuery = Query<AccessMetaDataVendor>(context)
      ..values.changedAt = DateTime.now().toUtc()
      ..values.createdAt = DateTime.now().toUtc()
      ..values.vendor = insertedVendor;

    final insertedAccessMetaDataVendorQuery =
        await accessMetaDataVendorQuery.insert();

    return Response.ok([insertedVendor, insertedAccessMetaDataVendorQuery]);
  }
}
