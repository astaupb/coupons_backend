import '../coupons_backend.dart';
import 'metadata.dart';
import '../model/coupon.dart';
import '../model/store.dart';

class Vendor extends ManagedObject<_Vendor> implements _Vendor {}

class _Vendor {
  @primaryKey
  int id;

  @Column(unique: true)
  String name;

  @Column(nullable: true)
  Document properties;

  ManagedSet<Coupon> coupons;

  ManagedSet<Store> stores;

  MetadataVendor accessMetaDataVendor;
}
