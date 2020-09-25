import 'package:coupons_backend/coupons_backend.dart';
import 'package:coupons_backend/model/access_meta_data.dart';
import 'package:coupons_backend/model/coupon.dart';
import 'package:coupons_backend/model/store.dart';

class Vendor extends ManagedObject<_Vendor> implements _Vendor {}

class _Vendor {
  @primaryKey
  int id;

  @Column(unique: true)
  String name;

  ManagedSet<Coupon> coupons;

  ManagedSet<Store> stores;

  AccessMetaDataVendor accessMetaDataVendor;
}
