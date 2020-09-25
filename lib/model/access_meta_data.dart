import 'package:aqueduct/aqueduct.dart';
import 'package:coupons_backend/coupons_backend.dart';
import 'package:coupons_backend/model/coupon.dart';
import 'package:coupons_backend/model/coupon_code.dart';
import 'package:coupons_backend/model/vendor.dart';
import 'package:coupons_backend/model/store.dart';

class AccessMetaDataCouponCode extends ManagedObject<_AccessMetaDataCouponCode>
    implements _AccessMetaDataCouponCode {}

class _AccessMetaDataCouponCode extends _AccessMetaData {
  @Relate(#accessMetaDataCouponCode)
  CouponCode couponCode;

  @Column(indexed: true)
  DateTime issued;

  @Column(indexed: true)
  DateTime redeemedAt;
}

class AccessMetaDataCoupon extends ManagedObject<_AccessMetaDataCoupon>
    implements _AccessMetaDataCoupon {}

class _AccessMetaDataCoupon extends _AccessMetaData {
  @Relate(#accessMetaDataCoupon)
  Coupon coupon;

  @Column(indexed: true)
  DateTime startDate;

  @Column(indexed: true)
  DateTime experationDate;
}

class AccessMetaDataStore extends ManagedObject<_AccessMetaDataStore>
    implements _AccessMetaDataStore {}

class _AccessMetaDataStore extends _AccessMetaData {
  @Relate(#accessMetaDataStore)
  Store store;
}

class AccessMetaDataVendor extends ManagedObject<_AccessMetaDataVendor>
    implements _AccessMetaDataVendor {}

class _AccessMetaDataVendor extends _AccessMetaData {
  @Relate(#accessMetaDataVendor)
  Vendor vendor;
}

class _AccessMetaData {
  @primaryKey
  int id;

  @Column(indexed: true)
  DateTime createdAt;
  //  String createdBy;

  @Column(indexed: true)
  DateTime changedAt;
  //  String changedBy;
}
