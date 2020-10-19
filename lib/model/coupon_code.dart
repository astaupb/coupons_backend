import '../coupons_backend.dart';
import 'coupon.dart';
import 'metadata.dart';

class CouponCode extends ManagedObject<_CouponCode> implements _CouponCode {}

class _CouponCode {
  @primaryKey
  int id;

  String code;

  @Column(defaultValue: "false")
  bool redeemed;

  @Relate(#codes, onDelete: DeleteRule.cascade)
  Coupon coupon;

  MetadataCouponCode metadataCouponCode;
}
