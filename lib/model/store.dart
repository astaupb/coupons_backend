import '../coupons_backend.dart';
import '../model/vendor.dart';
import 'metadata.dart';

class Store extends ManagedObject<_Store> implements _Store {}

class _Store {
  @primaryKey
  int id;

  @Relate(#stores)
  Vendor vendor;

  String name;

  @Column(nullable: true)
  Document properties;

  MetadataStore metadataStore;
}
