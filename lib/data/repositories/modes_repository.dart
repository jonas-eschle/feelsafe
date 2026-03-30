import 'package:hive/hive.dart';
import '../models/session_mode.dart';

class ModesRepository {
  static const _boxName = 'modes';

  Future<Box<SessionMode>> get _box =>
      Hive.openBox<SessionMode>(_boxName);

  Future<List<SessionMode>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<SessionMode?> getById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  Future<void> save(SessionMode mode) async {
    final box = await _box;
    await box.put(mode.id, mode);
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<bool> isEmpty() async {
    final box = await _box;
    return box.isEmpty;
  }
}
