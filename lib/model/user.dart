import 'package:aqueduct/aqueduct.dart';
import 'package:aqueduct/managed_auth.dart';

import '../coupons_backend.dart';
import '../model/access_codes.dart';
import '../model/coupon.dart';


enum Role { user, admin, coupon }

class User extends ManagedObject<_User>
    implements _User, ManagedAuthResourceOwner<_User> {
  @Serialize(input: true, output: false)
  String password;

  @Serialize(input: true, output: false)
  String code;
}

class _User extends ResourceOwnerTableDefinition {
  AccessCode accesscode;

  @Column(nullable: true)
  Document properties;

  ManagedSet<RedeemedCoupon> redeemedCoupon;
}
