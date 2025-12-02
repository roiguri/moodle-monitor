import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moodie/services/cache_service.dart';

void main() {
  late CacheService cacheService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cacheService = CacheService();
    await cacheService.clearCache();
  });

  group('CacheService', () {
    test('getKnownTaskIds returns empty list initially', () async {
      expect(await cacheService.getKnownTaskIds(), isEmpty);
    });

    test('saveTaskIds saves and retrieves IDs correctly', () async {
      final ids = ['1', '2', '3'];
      await cacheService.saveTaskIds(ids);
      expect(await cacheService.getKnownTaskIds(), ids);
    });

    test('addKnownTaskIds merges new IDs correctly', () async {
      await cacheService.saveTaskIds(['1', '2']);
      
      await cacheService.addKnownTaskIds(['2', '3', '4']);
      
      final result = await cacheService.getKnownTaskIds();
      expect(result, containsAll(['1', '2', '3', '4']));
      expect(result.length, 4);
    });

    test('clearCache removes all IDs', () async {
      await cacheService.saveTaskIds(['1', '2']);
      await cacheService.clearCache();
      expect(await cacheService.getKnownTaskIds(), isEmpty);
    });
  });
}
