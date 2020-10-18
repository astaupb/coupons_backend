import 'dart:async';

import 'package:aqueduct/aqueduct.dart';
import 'package:coupons_backend/coupons_backend.dart';
import 'package:uuid/uuid.dart';
import '../model/access_codes.dart';
import '../model/user.dart';

class RegisterController extends ResourceController {
  RegisterController(this.context, this.authServer);

  final ManagedContext context;
  final AuthServer authServer;

  Uuid uuid = Uuid();

  @Operation.post()
  Future<Response> createUser(@Bind.body() User user) async {
    user.username ??= uuid.v4();
    user.password ??= uuid.v4();

    final fetchRole = Query<AccessCode>(context)
      ..where((a) => a.code).equalTo(user.code)
      ..where((a) => a.user).isNull();

    final recivedRole = await fetchRole.fetchOne();

    if (recivedRole.role == null) {
      return Response.notFound();
    }

    user
      ..salt = AuthUtility.generateRandomSalt()
      ..hashedPassword = authServer.hashPassword(user.password, user.salt);

    final userInsertQuery = await Query(context, values: user).insert();

    if (userInsertQuery == null) {
      return Response.notFound();
    }

    final updatemeta = Query<AccessCode>(context)
      ..where((a) => a.id).equalTo(recivedRole.id)
      ..values.user.id = userInsertQuery.id;

    final updatededMeta = updatemeta.updateOne();
    if (updatededMeta == null) {
      return Response.notFound();
    }

    return Response.ok(userInsertQuery);
  }
}
