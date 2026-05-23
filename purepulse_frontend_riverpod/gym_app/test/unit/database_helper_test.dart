import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/data/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPreferencesDatabase', () {
    test('should insert and query data correctly', () async {
      final db = SharedPreferencesDatabase();
      
      final row = {'id': '1', 'name': 'Item 1'};
      await db.insert('test_table', row);

      final result = await db.query('test_table');
      expect(result.length, 1);
      expect(result.first['name'], 'Item 1');
    });

    test('should delete data correctly', () async {
      final db = SharedPreferencesDatabase();
      
      await db.insert('test_table', {'id': '1', 'name': 'Item 1'});
      await db.insert('test_table', {'id': '2', 'name': 'Item 2'});

      await db.delete('test_table', where: 'id = ?', whereArgs: ['1']);

      final result = await db.query('test_table');
      expect(result.length, 1);
      expect(result.first['id'], '2');
    });

    test('should commit batch operations correctly', () async {
      final db = SharedPreferencesDatabase();
      final batch = db.batch();

      batch.insert('test_table', {'id': '1', 'name': 'Batch 1'});
      batch.insert('test_table', {'id': '2', 'name': 'Batch 2'});
      await batch.commit();

      final result = await db.query('test_table');
      expect(result.length, 2);
    });
  });
}
