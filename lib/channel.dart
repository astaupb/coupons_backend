//import 'package:aqueduct/managed_auth.dart';
import 'package:coupons_backend/coupons_backend.dart';
import 'package:coupons_backend/controller/vendor_controller.dart';
import 'package:coupons_backend/controller/coupon_controller.dart';

class CouponsBackendChannel extends ApplicationChannel {
  ManagedContext context;
  AuthServer authServer;

  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final config = CouponConfig(options.configurationFilePath);
    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        config.database.username,
        config.database.password,
        config.database.host,
        config.database.port,
        config.database.databaseName);

    context = ManagedContext(dataModel, persistentStore);

    // final authStorage = ManagedAuthDelegate<User>(context);
    // authServer = AuthServer(authStorage);
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router.route('/vendor/[:id]').link(() => VendorController(context));

    router
        .route('/vendor/:vendorID/coupon/[:id]')
        .link(() => CouponController(context));

    return router;
  }
}

class CouponConfig extends Configuration {
  CouponConfig(String path) : super.fromFile(File(path));

  DatabaseConfiguration database;
}
