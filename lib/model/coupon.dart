import '../coupons_backend.dart';
import '../model/coupon_code.dart';
import '../model/user.dart';
import '../model/vendor.dart';
import 'metadata.dart';

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

  ManagedSet<RedeemedCoupon> usedBy;

  ManagedSet<CouponCode> codes;

  MetadataCoupon metadataCoupon;
}

class RedeemedCoupon extends ManagedObject<_RedeemedCoupon>
    implements _RedeemedCoupon {}

class _RedeemedCoupon {
  @primaryKey
  int id;

  DateTime redeemedAt;

  @Relate(#usedBy)
  Coupon coupon;

  @Relate(#redeemedCoupon)
  User usedBy;
}
