import 'package:aqueduct/managed_auth.dart';

import 'controller/access_code_controller.dart';
import 'controller/assets_controller.dart';
import 'controller/coupon_code_controller.dart';
import 'controller/coupon_controller.dart';
import 'controller/register_controller.dart';
import 'controller/store_controller.dart';
import 'controller/upload_controller.dart';
import 'controller/vendor_controller.dart';
import 'coupons_backend.dart';
import 'model/access_codes.dart';
import 'model/user.dart';

class CouponConfig extends Configuration {
  @optionalConfiguration
  String adminkey;

  @optionalConfiguration
  String couponkey;

  DatabaseConfiguration database;

  CouponConfig(String path) : super.fromFile(File(path));
}

class CouponsBackendChannel extends ApplicationChannel {
  ManagedContext context;
  AuthServer authServer;
  CouponConfig config;

  @override
  Controller get entryPoint {
    final router = Router();

    router.route('/auth/token').link(() => AuthController(authServer));

    // Route for external registration over OAuth
    // router.route('/auth/code').link(() => AuthRedirectController(authServer));
    router
        .route('/assets/*')
        .link(() => Authorizer.bearer(authServer, scopes: ['admin', 'user']))
        .link(() => AssetsController('assets'));

    router
        .route('/upload')
        .link(() => Authorizer.bearer(authServer, scopes: ['admin']))
        .link(() => UploadController());

    router
        .route('/register')
        .link(() => RegisterController(context, authServer));

    router
        .route('/codes')
        .link(() => Authorizer.bearer(authServer))
        .link(() => AccessCodeController(context));

    router
        .route('/vendor/[:id]')
        .link(() => Authorizer.bearer(authServer))
        .link(() => VendorController(context));

    router
        .route('/vendor/:vendorID/coupon/[:id]')
        .link(() => Authorizer.bearer(authServer))
        .link(() => CouponController(context));

    router
        .route('/vendor/:vendorID/coupon/:couponID/code/[:id]')
        .link(() => Authorizer.bearer(authServer))
        .link(() => CouponCodeController(context));

    router
        .route('/vendor/:vendorID/store/[:id]')
        .link(() => Authorizer.bearer(authServer))
        .link(() => StoreController(context));

    return router;
  }

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
}

class RoleBasedAuthDelegate extends ManagedAuthDelegate<User> {
  RoleBasedAuthDelegate(ManagedContext context, {int tokenLimit = 4})
      : super(context, tokenLimit: tokenLimit);

  @override
  List<AuthScope> getAllowedScopes(covariant User user) {
    if (user.accesscode.role == Role.admin) {
      return [AuthScope('admin'), AuthScope('user'), AuthScope('coupon')];
    } else if (user.accesscode.role == Role.coupon) {
      return [AuthScope('user'), AuthScope('coupon')];
    } else if (user.accesscode.role == Role.user) {
      return [AuthScope('user')];
    } else {
      return [AuthScope('user')];
    }
  }

  @override
  Future<User> getResourceOwner(AuthServer server, String username) async {
    final userQuery = Query<User>(context)
      ..where((u) => u.username).equalTo(username)
      ..returningProperties(
          (x) => [x.id, x.username, x.hashedPassword, x.salt]);

    final user = await userQuery.fetchOne();
    if (user == null) {
      return null;
    }

    final accessCodeQuery = Query<AccessCode>(context)
      ..where((a) => a.user.id).equalTo(user.id);

    final accessCode = await accessCodeQuery.fetchOne();

    user.accesscode = accessCode;

    return user;
  }
}
