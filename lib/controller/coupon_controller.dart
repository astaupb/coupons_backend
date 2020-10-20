import 'package:aqueduct/aqueduct.dart';
import '../coupons_backend.dart';
import '../model/metadata.dart';
import '../model/coupon.dart';
import '../model/vendor.dart';

class CouponController extends ResourceController {
  CouponController(this.context);

  final ManagedContext context;

  @Scope(['user'])
  @Operation.get('vendorID')
  Future<Response> getAllCouponByVendorID(
      @requiredBinding @Bind.path('vendorID') int vendorID) async {
    final couponQuery = Query<Coupon>(context);
    couponQuery.where((c) => c.vendor.id).equalTo(vendorID);
    final coupons = await couponQuery.fetch();
    if (coupons == null || coupons.isEmpty) {
      return Response.notFound();
    }

    return Response.ok(coupons);
  }

  @Scope(['user'])
  @Operation.get('vendorID', 'id')
  Future<Response> getCouponByIDByVendorID(
      @Bind.path('vendorID') int vendorID, @Bind.path('id') int id) async {
    final couponQuery = Query<Coupon>(context);
    couponQuery
      ..where((c) => c.vendor.id).equalTo(vendorID)
      ..where((c) => c.id).equalTo(id);
    final coupon = await couponQuery.fetchOne();
    if (coupon == null) {
      return Response.notFound();
    }

    return Response.ok(coupon);
  }

  @Scope(['admin'])
  @Operation.put('vendorID', 'id')
  Future<Response> updateCouponByIDByVendorID(
      @Bind.path('vendorID')
          int vendorID,
      @Bind.path('id')
          int id,
      @Bind.body(ignore: ['id', 'vendor', 'codes', 'usedBy', 'metadataCoupon'])
          Coupon coupon) async {
    final updateQuery = Query<Coupon>(context)
      ..where((c) => c.id).equalTo(id)
      ..where((c) => c.vendor.id).equalTo(vendorID)
      ..values = coupon;

    final update = await updateQuery.updateOne();

    if (update == null) {
      return Response.notFound();
    }

    final now = DateTime.now().toUtc();
    final updateMetadata = Query<MetadataCoupon>(context)
      ..where((x) => x.coupon.id).equalTo(id)
      ..values.changedAt = now;

    if (updateMetadata == null) {
      return Response.serverError();
    }
    return Response.ok(update);
  }

  @Scope(['admin'])
  @Operation.delete('vendorID', 'id')
  Future<Response> deleteCouponByIDByVendorID(
      @Bind.path('vendorID') int vendorID, @Bind.path('id') int id) async {
    final deleteCouponQuery = Query<Coupon>(context)
      ..where((c) => c.id).equalTo(id)
      ..where((c) => c.vendor.id).equalTo(vendorID);

    final deleteCoupon = await deleteCouponQuery.delete();

    if (deleteCoupon == null) {
      return Response.notFound();
    }

    return Response.accepted();
  }

  @Scope(['admin'])
  @Operation.post('vendorID')
  Future<Response> insertCouponByIDByVendorID(
      @Bind.path('vendorID') int vendorID) async {
    if (request.body.isEmpty) {
      return Response.badRequest();
    }

    final now = DateTime.now();

    final vendorQuery = Query<Vendor>(context)
      ..where((v) => v.id).equalTo(vendorID);

    final vendor = await vendorQuery.fetchOne();
    if (vendor == null) {
      return Response.badRequest();
    }
    final coupon = Coupon()
      ..read(await request.body.decode(), ignore: ['id', 'vendor'])
      ..vendor = vendor;

    final query = Query<Coupon>(context)..values = coupon;

    final insertedCoupon = await query.insert();
    if (insertedCoupon == null) {
      return Response.serverError();
    }
    final metadata = Query<MetadataCoupon>(context)
      ..values.changedAt = now
      ..values.createdAt = now
      ..values.coupon = insertedCoupon;

    final insertedMetadata = metadata.insert();
    if (insertedMetadata == null) {
      return Response.serverError();
    }

    return Response.ok(insertedCoupon);
  }

  @override
  APIRequestBody documentOperationRequestBody(
      APIDocumentContext context, Operation operation) {
    if (operation.method == "POST" || operation.method == "PUT") {
      return APIRequestBody.schema(context.schema['Coupon']);
    }
    return null;
  }

  @override
  Map<String, APIResponse> documentOperationResponses(
      APIDocumentContext context, Operation operation) {
    if (operation.method == "GET") {
      return {
        "200": APIResponse.schema("Get coupon", context.schema["Coupon"])
      };
    } else if (operation.method == "POST") {
      return {
        "200": APIResponse.schema("Add a coupon", context.schema["Coupon"])
      };
    } else if (operation.method == 'PUT') {
      return {
        "200": APIResponse.schema("Update a coupon", context.schema["Coupon"])
      };
    } else if (operation.method == 'DELETE') {
      return {"202": APIResponse("accepted")};
    }
    return {"400": APIResponse("Unkown error")};
  }
}
