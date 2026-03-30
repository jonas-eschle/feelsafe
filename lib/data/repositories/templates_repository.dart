import 'package:hive/hive.dart';
import '../models/reminder_template.dart';

class TemplatesRepository {
  static const _boxName = 'templates';

  Future<Box<ReminderTemplate>> get _box =>
      Hive.openBox<ReminderTemplate>(_boxName);

  Future<List<ReminderTemplate>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<ReminderTemplate?> getById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  Future<void> save(ReminderTemplate template) async {
    final box = await _box;
    await box.put(template.id, template);
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
