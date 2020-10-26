import 'package:aqueduct/aqueduct.dart';
import '../coupons_backend.dart';
import 'coupon.dart';
import 'coupon_code.dart';
import 'store.dart';
import 'vendor.dart';

class CouponCodeMetadata extends ManagedObject<_CouponCodeMetadata>
    implements _CouponCodeMetadata {}

class _CouponCodeMetadata extends _Metadata {
  @Relate(#couponCodeMetadata, onDelete: DeleteRule.cascade)
  CouponCode couponCode;
}

class CouponMetadata extends ManagedObject<_CouponMetadata>
    implements _CouponMetadata {}

class _CouponMetadata extends _Metadata {
  @Relate(#couponMetadata, onDelete: DeleteRule.cascade)
  Coupon coupon;
}

class StoreMetadata extends ManagedObject<_StoreMetadata>
    implements _StoreMetadata {}

class _StoreMetadata extends _Metadata {
  @Relate(#storeMetadata, onDelete: DeleteRule.cascade)
  Store store;
}

class VendorMetadata extends ManagedObject<_VendorMetadata>
    implements _VendorMetadata {}

class _VendorMetadata extends _Metadata {
  @Relate(#vendorMetadata, onDelete: DeleteRule.cascade)
  Vendor vendor;
}

class _Metadata {
  @primaryKey
  @Validate.present(onInsert: false, onUpdate: false)
  int id;

  @Column(indexed: true)
  DateTime createdAt;
  //  String createdBy;

  @Column(indexed: true)
  DateTime changedAt;
  //  String changedBy;
}
