import 'package:coupons_backend/coupons_backend.dart';
import 'package:coupons_backend/model/access_meta_data.dart';
import 'package:coupons_backend/model/coupon.dart';

class CouponCode extends ManagedObject<_CouponCode> implements _CouponCode {
  @override
  void willInsert() {
    accessMetaDataCouponCode.changedAt =
        accessMetaDataCouponCode.createdAt = DateTime.now().toUtc();
    accessMetaDataCouponCode.redeemedAt = DateTime(1700);
  }

  @override
  void willUpdate() {
    accessMetaDataCouponCode.changedAt = DateTime.now().toUtc();
  }
}

class _CouponCode {
  @primaryKey
  int id;

  String code;

  @Relate(#codes, onDelete: DeleteRule.cascade)
  Coupon coupon;

  AccessMetaDataCouponCode accessMetaDataCouponCode;
}
