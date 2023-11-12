// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

// Package imports:
import 'package:provider/provider.dart';

///
/// Интерфейс взаимодействия с хранилищем
///
/// Пример реализации читателя с FlutterSecureStorage
///
/// ```dart
/// final class FlutterSecureStorageReader implements StorageReader {
///   FlutterSecureStorageReader(this.storage);
///
///   FlutterSecureStorage storage;
///
///   @override
///   Future<T?> read<T>({required String key}) {
///     return storage.read(key: key) as Future<T?>;
///   }
/// }
/// ```
///
abstract interface class StorageReader {
  ///
  /// Интерфейс взаимодействия с хранилищем
  ///
  const StorageReader();

  ///
  /// Чтение значения по ключу
  ///
  Future<T?> read<T>({required String key});

  ///
  /// Чтение всех данных
  ///
  Future<Map<String, dynamic>> readAll();
}

///
/// Провайдер читателя, чтобы не "прокидывать" его каждый раз
///
class StorageValueProvider extends StatelessWidget {
  ///
  /// Провайдер читателя
  ///
  /// Пример использования
  ///
  /// ```dart
  /// SecureStorageValueProvider(
  ///   reader: authSecStorageReader,
  ///   child: Column(
  ///     children: <Widget>[
  ///       SecureStorageValue(
  ///         skey: StorageKeys.authSessionKey,
  ///         builder: (BuildContext context, String? value) {
  ///           return SecureStorageView(
  ///             title: 'Session key',
  ///             value: value,
  ///           );
  ///         },
  ///       ),
  ///       SecureStorageValue(
  ///         skey: StorageKeys.authAccessToken,
  ///         builder: (BuildContext context, String? value) {
  ///           return SecureStorageView(
  ///             title: 'Access token',
  ///             value: value,
  ///           );
  ///         },
  ///       ),
  ///     ],
  ///   ),
  /// ),
  /// ```
  ///
  const StorageValueProvider({
    required this.reader,
    required this.child,
    super.key,
  });

  /// Экземпляр читателя
  final StorageReader reader;

  /// Потомок
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Provider<StorageReader>(
      create: (_) => reader,
      child: child,
    );
  }
}

///
/// Получатель данных через [StorageReader]
///
class StorageValue extends StatelessWidget {
  ///
  /// Получатель данных через [StorageReader]
  ///
  /// Для корректной работы необходимо
  /// обернуть данный виджет [StorageValueProvider]
  ///
  /// Для более "простой" версии можно использовать [StorageValue.reader]
  ///
  const StorageValue({
    required this.skey,
    required this.builder,
    super.key,
  }) : reader = null;

  ///
  /// Более простой способ получения данных напрямую через [reader]
  ///
  const StorageValue.reader({
    required this.reader,
    required this.skey,
    required this.builder,
    super.key,
  });

  /// Читатель данных
  final StorageReader? reader;

  /// Ключ, по которому получаем данные
  final String skey;

  /// Построитель интерфейса
  final Widget Function(BuildContext context, String? value) builder;

  @override
  Widget build(BuildContext context) {
    final StorageReader reader = this.reader ?? context.read<StorageReader>();

    return FutureBuilder<String?>(
      future: reader.read<String>(key: skey),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Text('Получение данных...');
        }

        if (snapshot.hasError) {
          return Text(
            'Не удалось получить данные',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          );
        }

        return builder(context, snapshot.data);
      },
    );
  }
}

///
/// Отображение "всех" данных хранилища
///
class ListStorageValue extends StatelessWidget {
  const ListStorageValue({
    required this.itemBuilder,
    super.key,
  }) : reader = null;

  const ListStorageValue.reader({
    required this.reader,
    required this.itemBuilder,
    super.key,
  });

  /// Читатель данных
  final StorageReader? reader;

  /// Построитель данных
  final Widget Function(
    BuildContext context,
    String key,
    dynamic value,
  ) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final StorageReader reader = this.reader ?? context.read<StorageReader>();

    return FutureBuilder<Map<String, dynamic>>(
      future: reader.readAll(),
      builder: (
        BuildContext context,
        AsyncSnapshot<Map<String, dynamic>> snapshot,
      ) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Text('Получение данных...');
        }

        if (snapshot.hasError) {
          return Text(
            'Не удалось получить данные',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          );
        }

        final Iterable<MapEntry<String, dynamic>> entries =
            snapshot.data!.entries;

        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (BuildContext context, int index) {
            final MapEntry<String, dynamic> entry = entries.elementAt(index);

            return itemBuilder(context, entry.key, entry.value);
          },
        );
      },
    );
  }
}

///
/// Стандартный способ отображения данных полученных через [StorageValue]
///
class StorageValueView extends StatelessWidget {
  ///
  /// Стандартный способ отображения данных
  /// полученных через [StorageValue]
  ///
  const StorageValueView({
    required this.title,
    required this.value,
    super.key,
  });

  /// Заголовок
  final String title;

  /// Значение из хранилища
  final String? value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        '$value',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      contentPadding: EdgeInsets.zero,
      trailing: IconButton(
        icon: const Icon(Icons.copy),
        onPressed: () {
          if (value == null) return;

          Clipboard.setData(
            ClipboardData(text: value!),
          );
        },
      ),
    );
  }
}
