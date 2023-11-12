# diz-core-storage-reader

Simple universal storage reader for debug

## Usage

```dart
import 'package:diz_core_storage_reader/diz_core_storage_reader.dart';
import 'package:flutter/material.dart';

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

///
/// Создаем глобальный экземпляр читателя (для примера)
///
final StorageReader mStorageReader = CustomStorageReader(<String, dynamic>{
  'first': 'first value',
  'second': 'second value',
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          StorageValueProvider(
            reader: mStorageReader,
            child: Column(
              children: <Widget>[
                StorageValue(
                  skey: 'first',
                  builder: (BuildContext context, String? value) {
                    return StorageValueView(
                      title: 'First key',
                      value: value,
                    );
                  },
                ),
                StorageValue(
                  skey: 'second',
                  builder: (BuildContext context, String? value) {
                    return StorageValueView(
                      title: 'Second token',
                      value: value,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```
