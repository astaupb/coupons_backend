import 'package:aqueduct/aqueduct.dart';
import '../coupons_backend.dart';
import '../model/coupon.dart';
import '../model/coupon_code.dart';
import '../model/metadata.dart';
import '../model/user.dart';

class CouponCodeController extends ResourceController {
  CouponCodeController(this.context);

  final ManagedContext context;

  @Scope(['coupon'])
  @Operation.get('vendorID', 'couponID')
  Future<Response> getCodeByCouponIDByVendorID(
      @Bind.path('vendorID') int vendorID,
      @Bind.path('couponID') int couponID) async {
    final userID = request.authorization.ownerID.toString();

    final couponRestrictionLevelQuery = Query<Coupon>(context)
      ..where((c) => c.id).equalTo(couponID)
      ..where((c) => c.vendor.id).equalTo(vendorID);

    final couponQuery = await couponRestrictionLevelQuery.fetchOne();

    final couponRestrictionLevel = couponQuery.restrictionLevel;

    if (couponRestrictionLevel == null) {
      return Response.notFound();
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
      final couponCodeQuery = Query<CouponCode>(context)
        ..where((c) => c.coupon.vendor.id).equalTo(vendorID)
        ..where((c) => c.coupon.id).equalTo(couponID)
        ..fetchLimit = 1;

      final couponCode = couponCodeQuery.fetchOne();

      if (couponCode == null) {
        return Response.notFound();
      }

      return Response.ok(couponCode);
    } else if (couponRestrictionLevel == RestrictionLevel.oneuser) {
      final couponCodeUsedQuery = Query<CouponCode>(context)
        ..where((c) => c.coupon.vendor.id).equalTo(vendorID)
        ..where((c) => c.coupon.id).equalTo(couponID)
        ..where((c) => c.redeemedCouponCode).contains(userID)
        ..fetchLimit = 1;

      final couponCodeUsed = couponCodeUsedQuery.fetchOne();

      if (couponCodeUsed == null) {
        final couponCodeQuery = Query<CouponCode>(context)
          ..where((c) => c.coupon.vendor.id).equalTo(vendorID)
          ..where((c) => c.coupon.id).equalTo(couponID)
          ..where((c) => c.redeemed).equalTo(false)
          ..fetchLimit = 1;

        final couponCode = couponCodeQuery.fetchOne();

        return Response.ok(couponCode);
      }

      return Response.notFound();
    }

    /*
    final couponCodeQuery = Query<CouponCode>(context);
    couponCodeQuery
      ..where((c) => c.coupon.vendor.id).equalTo(vendorID)
      ..where((c) => c.coupon.id).equalTo(couponID)
      ..where((c) => c.redeemed).equalTo(false)
      ..fetchLimit = 1;

    final coupon = await couponCodeQuery.fetchOne();

    if (coupon == null) {
      return Response.notFound();
    }
    if (coupon.restrictionLevel == RestrictionLevel.oneuser) {
      final userQuery = Query<User>(context)
        ..where((u) => u.id).equalTo(request.authorization.ownerID);

      final userFetch = await userQuery.fetchOne();

      final redeemedCouponCodeQuery = Query<RedeemedCouponCode>(context)
        ..values.user = userFetch
        ..values.couponCode = coupon;

      final redeemedCouponCode = await redeemedCouponCodeQuery.insert();

      final updateCouponQuery = Query<CouponCode>(context)
        ..where((c) => c.id).equalTo(coupon.id)
        ..values.redeemed = true
        ..values.redeemedCouponCode.add(redeemedCouponCode);

      final updatedCouponQuery = await updateCouponQuery.updateOne();

      if (updatedCouponQuery == null) {
        return Response.serverError();
      }
      userFetch.redeemedCouponCode.add(redeemedCouponCode);

      final updatedUserQuery = Query<User>(context)..values = userFetch;

      final updatedUser = updatedUserQuery.updateOne();

      if (updatedUser == null) {
        return Response.serverError();
      }

      final metadataQuery = Query<MetadataCouponCode>(context)
        ..values.redeemedAt = DateTime.now()
        ..where((m) => m.couponCode.id).equalTo(couponID);
      final updatedMetadata = await metadataQuery.updateOne();
      if (updatedMetadata == null) {
        return Response.badRequest();
      }
    }
    return Response.ok(coupon);
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
        'accessMetaDataCouponCode.redeemedAt',
        'accessMetaDataCouponCode.createdAt',
        'accessMetaDataCouponCode.changedAt',
        'accessMetaDataCouponCode.id'
      ])
      ..coupon = coupon;
    final now = DateTime.now().toUtc();
    final query = Query<CouponCode>(context);
    query.values = couponCode;
    final insertedCouponCode = await query.insert();
    if (insertedCouponCode == null) {
      return Response.badRequest();
    }
    final metadata = Query<MetadataCouponCode>(context)
      ..values.changedAt = now
      ..values.createdAt = now
      ..values.redeemedAt = null
      ..values.couponCode = insertedCouponCode;

    final insertedMetadata = await metadata.insert();
    if (insertedMetadata == null) {
      return Response.badRequest();
    }
    return Response.ok(insertedCouponCode);
  */
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
