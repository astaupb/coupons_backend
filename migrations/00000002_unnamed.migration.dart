import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration2 extends Migration { 
  @override
  Future upgrade() async {
   		database.alterColumn("_Vendor", "address", (c) {c.isNullable = true;});
		database.alterColumn("_Vendor", "logo", (c) {c.isNullable = true;});
		database.alterColumn("_Vendor", "image", (c) {c.isNullable = true;});
		database.alterColumn("_Coupon", "redeemed", (c) {c.isNullable = true;});
		database.alterColumn("_Coupon", "validUntil", (c) {c.isNullable = true;});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    