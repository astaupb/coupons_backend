import 'package:aqueduct/managed_auth.dart';
import 'package:coupons_backend/model/access_codes.dart';
import 'controller/coupon_code_controller.dart';
import 'controller/coupon_controller.dart';
import 'controller/register_controller.dart';
import 'controller/store_controller.dart';
import 'controller/vendor_controller.dart';
import 'coupons_backend.dart';
import 'model/user.dart';

class CouponsBackendChannel extends ApplicationChannel {
  ManagedContext context;
  AuthServer authServer;
  CouponConfig config;

  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    // Set to false in production!
    Controller.includeErrorDetailsInServerErrorResponses = true;
    final config = CouponConfig(options.configurationFilePath);
    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        config.database.username,
        config.database.password,
        config.database.host,
        config.database.port,
        config.database.databaseName);

    context = ManagedContext(dataModel, persistentStore);
    final delegate = RoleBasedAuthDelegate(context);
    authServer = AuthServer(delegate);
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router.route('/auth/token').link(() => AuthController(authServer));

    // Route for external registration over OAuth
    // router.route('/auth/code').link(() => AuthRedirectController(authServer));

    router
        .route('/register')
        .link(() => RegisterController(context, authServer));

    router
        .route('/codes[/:id]')
        .link(() => Authorizer.bearer(authServer, scopes: ['admin']))
        .link(() => ManagedObjectController<AccessCode>(context));

    router
        .route('/vendor[/:id]')
        .link(() => Authorizer.bearer(authServer))
        .link(() => VendorController(context));

    router
        .route('/vendor/:vendorID/coupon/[:id]')
        .link(() => Authorizer.bearer(authServer))
        .link(() => CouponController(context));

    router
        .route('/vendor/:vendorID/coupon/:couponID/code')
        .link(() => Authorizer.bearer(authServer))
        .link(() => CouponCodeController(context));

    router
        .route('/vendor/:vendorID/store/[:id]')
        .link(() => Authorizer.bearer(authServer))
        .link(() => StoreController(context));

    return router;
  }
}

class CouponConfig extends Configuration {
  CouponConfig(String path) : super.fromFile(File(path));

  @optionalConfiguration
  String adminkey;

  @optionalConfiguration
  String couponkey;
  DatabaseConfiguration database;
}

class RoleBasedAuthDelegate extends ManagedAuthDelegate<User> {
  RoleBasedAuthDelegate(ManagedContext context, {int tokenLimit: 4})
      : super(context, tokenLimit: tokenLimit);

  @override
  Future<User> getResourceOwner(AuthServer server, String username) async {
    final query = Query<User>(context)
      ..where((u) => u.username).equalTo(username)
      ..returningProperties(
          (x) => [x.id, x.username, x.hashedPassword, x.salt]);

    final user = await query.fetchOne();
    if (user == null) {
      return null;
    }

    final metaquery = Query<AccessCode>(context)
      ..where((a) => a.user.id).equalTo(user.id);

    final meta = await metaquery.fetchOne();

    user.accesscode = meta;

    return user;
  }

  @override
  List<AuthScope> getAllowedScopes(covariant User user) {
    if (user.accesscode.role == Role.admin) {
      return [AuthScope('admin'), AuthScope('user'), AuthScope('coupon')];
    } else if (user.accesscode.role == Role.couponUser) {
      return [AuthScope('user'), AuthScope('coupon')];
    } else if (user.accesscode.role == Role.user) {
      return [AuthScope('user')];
    } else {
      return [AuthScope('user')];
    }
  }
}
