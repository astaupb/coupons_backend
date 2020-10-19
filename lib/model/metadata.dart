import 'package:aqueduct/aqueduct.dart';
import '../coupons_backend.dart';
import 'coupon.dart';
import 'coupon_code.dart';
import 'store.dart';
import 'vendor.dart';

class MetadataCouponCode extends ManagedObject<_MetadataCouponCode>
    implements _MetadataCouponCode {}

class _MetadataCouponCode extends _Metadata {
  @Relate(#metadataCouponCode, onDelete: DeleteRule.cascade)
  CouponCode couponCode;
}

class MetadataCoupon extends ManagedObject<_MetadataCoupon>
    implements _MetadataCoupon {}

class _MetadataCoupon extends _Metadata {
  @Relate(#metadataCoupon, onDelete: DeleteRule.cascade)
  Coupon coupon;

  @Column(indexed: true)
  DateTime startDate;

  @Column(indexed: true)
  DateTime expirationDate;
}

class MetadataStore extends ManagedObject<StoreMetadata>
    implements StoreMetadata {}

class StoreMetadata extends _Metadata {
  @Relate(#metadataStore, onDelete: DeleteRule.cascade)
  Store store;
}

class MetadataVendor extends ManagedObject<_MetadataVendor>
    implements _MetadataVendor {}

class _MetadataVendor extends _Metadata {
  @Relate(#metadataVendor, onDelete: DeleteRule.cascade)
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
