import '../coupons_backend.dart';
import 'metadata.dart';
import '../model/coupon.dart';
import '../model/user.dart';


class CouponCode extends ManagedObject<_CouponCode> implements _CouponCode {}

class _CouponCode {
  @primaryKey
  int id;

  String code;

  @Column(defaultValue: "false")
  bool redeemed;

  ManagedSet<RedeemedCouponCode> redeemedCouponCode;
  @Relate(#codes, onDelete: DeleteRule.cascade)
  Coupon coupon;

  MetadataCouponCode accessMetaDataCouponCode;
}

class RedeemedCouponCode extends ManagedObject<_RedeemedCouponCode>
 implements _RedeemedCouponCode {}

class _RedeemedCouponCode {
  @primaryKey
  int id;

  @Relate(#redeemedCouponCode)
  CouponCode couponCode;

  @Relate(#redeemedCouponCode)
  User user;
}
