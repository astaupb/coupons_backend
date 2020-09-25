import 'package:coupons_backend/coupons_backend.dart';
import 'package:coupons_backend/model/vendor.dart';
import 'package:coupons_backend/model/coupon_code.dart';
import 'package:coupons_backend/model/access_meta_data.dart';

class Coupon extends ManagedObject<_Coupon> implements _Coupon {
  @override
  void willInsert() {
    accessMetaDataCoupon = AccessMetaDataCoupon();
    
  }

  @override
  void willUpdate() {
    accessMetaDataCoupon.changedAt = DateTime.now().toUtc();
  }
}

class _Coupon {
  @primaryKey
  int id;

  String title;

  @Column(nullable: true)
  String description;

  @Relate(#coupons, onDelete: DeleteRule.cascade)
  Vendor vendor;

  ManagedSet<CouponCode> codes;

  AccessMetaDataCoupon accessMetaDataCoupon;
}
