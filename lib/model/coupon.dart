import 'package:coupons_backend/coupons_backend.dart';
import 'package:coupons_backend/model/vendor.dart';

class Coupon extends ManagedObject<_Coupon> implements _Coupon {}

class _Coupon {
  @primaryKey
  int id;
  
  String title;
  
  String description;
  
  @Relate(#coupons, onDelete: DeleteRule.cascade)
  Vendor vendor;

  @Column(nullable: true) 
  bool redeemed;
  
  @Column(nullable: true)
  DateTime validUntil;
}
