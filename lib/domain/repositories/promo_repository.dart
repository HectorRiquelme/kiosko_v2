import '../entities/promo.dart';

abstract class PromoRepository {
  Future<List<Promo>> getAllPromos();
  Future<List<Promo>> getActivePromos();
  Future<Promo?> getPromoById(String id);
  Future<void> insertPromo(Promo promo);
  Future<void> updatePromo(Promo promo);
  Future<void> deletePromo(String id);
  Future<void> togglePromoActive(String id, bool active);
}
