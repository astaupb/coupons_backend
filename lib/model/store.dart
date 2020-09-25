import 'package:coupons_backend/coupons_backend.dart';
import 'package:coupons_backend/model/vendor.dart';
import 'package:coupons_backend/model/access_meta_data.dart';

class Store extends ManagedObject<_Store> implements _Store {}

class _Store {
  @primaryKey
  int id;

  @Relate(#stores)
  Vendor vendor;

  String name;

  @Column(nullable: true)
  String street;

  @Column(nullable: true)
  String streetNumber;

  @Column(nullable: true)
  String city;

  @Column(nullable: true)
  int postcode;

  @Column(nullable: true)
  String tel;

  @Column(nullable: true)
  String url;

  AccessMetaDataStore accessMetaDataStore;
}
