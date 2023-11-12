import 'package:diz_core_storage_reader/diz_core_storage_reader.dart';
import 'package:test/test.dart';

///
/// Пример реализации интерфейса [StorageReader]
///
final class CustomStorageReader implements StorageReader {
  CustomStorageReader(this.storage);

  ///
  /// Для примера будем хранить данные просто в [Map]
  ///
  final Map<String, dynamic> storage;

  @override
  Future<T?> read<T>({required String key}) async => storage[key];

  @override
  Future<Map<String, dynamic>> readAll() async => storage;
}

void main() {
  group('A group of tests', () {
    late StorageReader mStorageReader;

    setUp(() {
      mStorageReader = CustomStorageReader(<String, dynamic>{
        'first': 'first value',
        'second': 'second value',
      });
    });

    test('Test read', () async {
      final String? value = await mStorageReader.read<String>(key: 'first');

      expect(value, equals('first value'));
    });
  });
}
