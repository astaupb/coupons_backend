import 'package:aqueduct/aqueduct.dart';
import 'package:coupons_backend/coupons_backend.dart';
import 'package:coupons_backend/model/coupon.dart';
import 'package:coupons_backend/model/vendor.dart';

class CouponController extends ResourceController {
  CouponController(this.context);

  final ManagedContext context;

  @Operation.get('vendorID')
  Future<Response> getAllCouponByVendorID(
      @Bind.path('vendorID') int vendorID) async {
    final couponQuery = Query<Coupon>(context);
    couponQuery.where((c) => c.vendor.id).equalTo(vendorID);
    final coupons = await couponQuery.fetch();
    if (coupons == null || coupons.isEmpty) {
      return Response.notFound();
    }

    return Response.ok(coupons);
  }

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

  @Operation.post('vendorID')
  Future<Response> insertCouponByVendorID(
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
    final coupon = Coupon()
      ..read(await request.body.decode(), ignore: [
        'id',
        'vendor'
        ])
      ..vendor = vendor;

    final query = Query<Coupon>(context)..values = coupon;

    final insertedCoupon = await query.insert();
    if (insertedCoupon == null) {
      return Response.badRequest();
    }
    return Response.ok(insertedCoupon);
  }
}
