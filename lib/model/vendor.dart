import 'package:coupons_backend/coupons_backend.dart';
import 'package:coupons_backend/model/coupon.dart';

class Vendor extends ManagedObject<_Vendor> implements _Vendor {}

class _Vendor {
  @primaryKey
  int id;

  @Column(unique: true)
  String name;

  @Column(nullable: true)
  String address;
  
  @Column(nullable: true)
  String logo;

  @Column(nullable: true)
  String image;

  ManagedSet<Coupon> coupons;
}
