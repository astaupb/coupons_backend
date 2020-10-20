import 'package:aqueduct/aqueduct.dart';
import '../coupons_backend.dart';
import '../model/coupon.dart';
import '../model/coupon_code.dart';
import '../model/metadata.dart';
import '../model/user.dart';

class CouponCodeController extends ResourceController {
  CouponCodeController(this.context);

  final ManagedContext context;

  @Scope(['user'])
  @Operation.get('vendorID', 'couponID')
  Future<Response> getCodeByCouponIDByVendorID(
      @Bind.path('vendorID') int vendorID,
      @Bind.path('couponID') int couponID) async {
    final userID = request.authorization.ownerID;

    final couponRestrictionLevelQuery = Query<Coupon>(context)
      ..where((c) => c.id).equalTo(couponID)
      ..where((c) => c.vendor.id).equalTo(vendorID);

    final couponQuery = await couponRestrictionLevelQuery.fetchOne();

    if (couponQuery == null) {
      return Response.notFound();
    }

    final couponRestrictionLevel = couponQuery.restrictionLevel;

    if (couponRestrictionLevel == null) {
      return Response.serverError();
    }

    if (couponRestrictionLevel == RestrictionLevel.permanent) {
      final couponCodeQuery = Query<CouponCode>(context)
        ..where((c) => c.coupon.vendor.id).equalTo(vendorID)
        ..where((c) => c.coupon.id).equalTo(couponID)
        ..fetchLimit = 1;

      final couponCode = await couponCodeQuery.fetchOne();

      if (couponCode == null) {
        return Response.notFound();
      }
      return Response.ok(couponCode);
    } else if (couponRestrictionLevel == RestrictionLevel.eachuser) {
      final redeemdedCouponCheck = Query<RedeemedCoupon>(context)
        ..where((c) => c.usedBy.id).equalTo(userID)
        ..where((c) => c.coupon.id).equalTo(couponQuery.id);

      final redeemedCoupon = await redeemdedCouponCheck.fetchOne();

      if (redeemedCoupon != null) {
        return Response.notFound();
      }

      final couponCodeQuery = Query<CouponCode>(context)
        ..where((c) => c.coupon.vendor.id).equalTo(vendorID)
        ..where((c) => c.coupon.id).equalTo(couponID)
        ..fetchLimit = 1;

      final couponCode = await couponCodeQuery.fetchOne();

      if (couponCode == null) {
        return Response.notFound();
      }

      final redeemedCouponInsertQuery = Query<RedeemedCoupon>(context)
        ..values.coupon = couponQuery
        ..values.usedBy.id = userID
        ..values.redeemedAt = DateTime.now().toUtc();

      final redeemedCouponInsert = await redeemedCouponInsertQuery.insert();

      if (redeemedCouponInsert == null) {
        return Response.notFound();
      }

      return Response.ok(couponCode);
    } else if (couponRestrictionLevel == RestrictionLevel.oneuser) {
      final redeemdedCouponCheck = Query<RedeemedCoupon>(context)
        ..where((c) => c.usedBy.id).equalTo(userID)
        ..where((c) => c.coupon.id).equalTo(couponQuery.id);

      final redeemedCoupon = await redeemdedCouponCheck.fetchOne();

      if (redeemedCoupon != null) {
        return Response.notFound();
      }

      final couponCodeQuery = Query<CouponCode>(context)
        ..where((c) => c.coupon.vendor.id).equalTo(vendorID)
        ..where((c) => c.coupon.id).equalTo(couponID)
        ..where((c) => c.redeemed).equalTo(false)
        ..fetchLimit = 1;

      final couponCode = await couponCodeQuery.fetchOne();

      if (couponCode == null) {
        return Response.notFound();
      }

      final redeemedInsertQuery = Query<RedeemedCoupon>(context)
        ..values.coupon = couponQuery
        ..values.usedBy.id = userID
        ..values.redeemedAt = DateTime.now().toUtc();

      final redeemedInsert = await redeemedInsertQuery.insert();

      if (redeemedInsert == null) {
        return Response.notFound();
      }

      final updateQuery = Query<CouponCode>(context)
        ..where((c) => c.id).equalTo(couponCode.id)
        ..values.redeemed = true;

      final update = updateQuery.updateOne();

      if (update == null) {
        return Response.serverError();
      }

      return Response.ok(couponCode);
    }

    return Response.notFound();
  }

  @Scope(['admin'])
  @Operation.put('vendorID', 'couponID', 'id')
  Future<Response> putCouponCodeByIDByCouponIDByVendorID(
      @Bind.path('vendorID')
          int vendorID,
      @Bind.path('couponID')
          int couponID,
      @Bind.path('id')
          int id,
      @Bind.body(ignore: ['metadataCouponCode', 'coupon', 'id'])
          CouponCode couponCode) async {
    final updateQuery = Query<CouponCode>(context)
      ..where((c) => c.id).equalTo(id)
      ..where((c) => c.coupon.id).equalTo(couponID)
      ..where((c) => c.coupon.vendor.id).equalTo(vendorID)
      ..values = couponCode;

    final update = updateQuery.updateOne();

    if (update == null) {
      return Response.notFound();
    }

    final now = DateTime.now().toUtc();
    final updateMetadataQuery = Query<MetadataCouponCode>(context)
      ..where((x) => x.couponCode.id).equalTo(couponID)
      ..values.changedAt = now;

    final updateMetadata = updateMetadataQuery.updateOne();
    if (updateMetadata == null) {
      return Response.serverError();
    }
    return Response.ok(update);
  }

  @Scope(['admin'])
  @Operation.delete('vendorID', 'couponID', 'id')
  Future<Response> deleteCouponCodeByIDByCoupon(
      @Bind.path('vendorID') int vendorID,
      @Bind.path('couponID') int couponID,
      @Bind.path('id') int id) async {
    final deleteQuery = Query<CouponCode>(context)
      ..where((c) => c.id).equalTo(id)
      ..where((c) => c.coupon.id).equalTo(couponID)
      ..where((c) => c.coupon.vendor.id).equalTo(vendorID);

    final delete = deleteQuery.delete();

    if (delete == null) {
      return Response.notFound();
    }

    return Response.accepted();
  }

  @Scope(['admin'])
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
      ..read(await request.body.decode(), ignore: [
        'id',
        'redeemed',
        'accessMetaDataCouponCode.redeemedAt',
        'accessMetaDataCouponCode.createdAt',
        'accessMetaDataCouponCode.changedAt',
        'accessMetaDataCouponCode.id'
      ])
      ..coupon = coupon;
    final now = DateTime.now().toUtc();
    final query = Query<CouponCode>(context)..values = couponCode;
    final insertedCouponCode = await query.insert();
    if (insertedCouponCode == null) {
      return Response.badRequest();
    }
    final metadata = Query<MetadataCouponCode>(context)
      ..values.changedAt = now
      ..values.createdAt = now
      ..values.couponCode = insertedCouponCode;

    final insertedMetadata = await metadata.insert();
    if (insertedMetadata == null) {
      return Response.badRequest();
    }
    return Response.ok(insertedCouponCode);
  }

  @override
  APIRequestBody documentOperationRequestBody(
      APIDocumentContext context, Operation operation) {
    if (operation.method == "POST") {
      return APIRequestBody.schema(context.schema['CouponCode']);
    }
    return null;
  }

  @override
  Map<String, APIResponse> documentOperationResponses(
      APIDocumentContext context, Operation operation) {
    if (operation.method == "GET") {
      return {
        "200": APIResponse.schema(
            "Get a coupon code", context.schema["CouponCode"]),
        "404": APIResponse("Could not find any redeemable couponcode!")
      };
    } else if (operation.method == "POST") {
      return {
        "200":
            APIResponse.schema("Add a couponcode", context.schema["CouponCode"])
      };
    }
    return {"400": APIResponse("Unkown error")};
  }
}
