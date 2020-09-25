import 'package:aqueduct/aqueduct.dart';
import 'package:coupons_backend/coupons_backend.dart';
import 'package:coupons_backend/model/coupon.dart';
import 'package:coupons_backend/model/coupon_code.dart';

class CouponCodeController extends ResourceController {
  CouponCodeController(this.context);

  final ManagedContext context;

/**
* @Operation.get('vendorID', 'couponID')
*  Future<Response> getCodeByCouponIDByVendorID(
*      @Bind.path('vendorID') int vendorID,
*      @Bind.path('couponID') int couponID) async {
*    final couponCodeQuery = Query<CouponCode>(context);
*    couponCodeQuery
*      ..where((c) => c.coupon.vendor.id).equalTo(vendorID)
*      ..where((c) => c.coupon.id).equalTo(couponID)
*      ..where((c) => c.redeemed).notEqualTo(true);
*
*    final coupon = await couponCodeQuery.fetchOne();
*    if (coupon == null) {
*      return Response.notFound();
*    }
*    couponCodeQuery
*      ..values.reserved = true
*      ..where((c) => c.id).equalTo(couponID);
*
*    final updatedCoupon = await couponCodeQuery.updateOne();
*
*    if (updatedCoupon == null) {
*      return Response.badRequest();
*    }
*
*    return Response.ok(updatedCoupon);
*  }
*  **/
  @Operation.post('vendorID', 'couponID')
  Future<Response> postCouponCodeByCouponIDByVendorID(
      @Bind.path('vendorID') int vendorID,
      @Bind.path('couponID') int couponID) async {
    if (request.body.isEmpty) {
      return Response.badRequest();
    }

    final couponQuery = Query<Coupon>(context)
      ..where((c) => c.id).equalTo(couponID)
      ..where((c) => c.vendor.id).equalTo(vendorID);

    final coupon = await couponQuery.fetchOne();

    if (coupon == null) {
      return Response.badRequest();
    }

    final couponCode = CouponCode()
      ..read(await request.body.decode(),
          ignore: [
            'id',
            'accessMetaDataCouponCode.redeemedAt',
            'accessMetaDataCouponCode.createdAt',
            'accessMetaDataCouponCode.changedAt',
            'accessMetaDataCouponCode.id'])
      ..coupon = coupon;

    final query = Query<CouponCode>(context)..values = couponCode;

    final insertedCodeCoupon = await query.insert();
    if (insertedCodeCoupon == null) {
      return Response.badRequest();
    }
    return Response.ok(insertedCodeCoupon);
  }
}
