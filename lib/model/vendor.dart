import '../coupons_backend.dart';
import '../model/coupon.dart';
import '../model/store.dart';
import 'metadata.dart';

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

  MetadataVendor metadataVendor;
}
