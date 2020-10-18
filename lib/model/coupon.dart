import 'package:coupons_backend/coupons_backend.dart';
import 'metadata.dart';
import '../model/coupon_code.dart';
import '../model/vendor.dart';

enum RestrictionLevel {
  // Restriction level describes how often a coupon can be used by each user
  //  "permanent": coupon can be used by each user over and over again
  //  "eachuser": each user can use this couponcode once
  //  "oneuser": one user can use this couponcode once
  permanent,
  eachuser,
  oneuser
}

class Coupon extends ManagedObject<_Coupon> implements _Coupon {}

class _Coupon {
  @primaryKey
  int id;

  String title;

  RestrictionLevel restrictionLevel;

  @Column(nullable: true)
  Document properties;

  @Relate(#coupons, onDelete: DeleteRule.cascade)
  Vendor vendor;

  ManagedSet<CouponCode> codes;

  MetadataCoupon accessMetaDataCoupon;
}
