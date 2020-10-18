import '../coupons_backend.dart';
import 'user.dart';

class AccessCode extends ManagedObject<_AccessCode> implements _AccessCode {}

class _AccessCode {
  @primaryKey
  int id;

  @Column(unique: true)
  String code;

  Role role;

  @Relate(#accesscode, onDelete:  DeleteRule.cascade)
  User user;
}
