import 'package:aqueduct/aqueduct.dart';
import '../coupons_backend.dart';
import 'coupon.dart';
import 'coupon_code.dart';
import 'store.dart';
import 'vendor.dart';

class MetadataCouponCode extends ManagedObject<_MetadataCouponCode>
    implements _MetadataCouponCode {}

class _MetadataCouponCode extends _Metadata {
  @Relate(#accessMetaDataCouponCode, onDelete: DeleteRule.cascade)
  CouponCode couponCode;

  @Column(indexed: true, nullable: true)
  DateTime redeemedAt;
}

class MetadataCoupon extends ManagedObject<_MetadataCoupon>
    implements _MetadataCoupon {}

class _MetadataCoupon extends _Metadata {
  @Relate(#accessMetaDataCoupon, onDelete: DeleteRule.cascade)
  Coupon coupon;

  @Column(indexed: true)
  DateTime startDate;

  @Column(indexed: true)
  DateTime experationDate;
}

class AccessMetaDataStore extends ManagedObject<MetadataStore>
    implements MetadataStore {}

class MetadataStore extends _Metadata {
  @Relate(#accessMetaDataStore, onDelete: DeleteRule.cascade)
  Store store;
}

class MetadataVendor extends ManagedObject<_MetadataVendor>
    implements _MetadataVendor {}

class _MetadataVendor extends _Metadata {
  @Relate(#accessMetaDataVendor, onDelete: DeleteRule.cascade)
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
