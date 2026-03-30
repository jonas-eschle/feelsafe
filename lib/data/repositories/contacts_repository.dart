import 'package:hive/hive.dart';
import '../models/emergency_contact.dart';

class ContactsRepository {
  static const _boxName = 'contacts';

  Future<Box<EmergencyContact>> get _box =>
      Hive.openBox<EmergencyContact>(_boxName);

  Future<List<EmergencyContact>> getAll() async {
    final box = await _box;
    final contacts = box.values.toList();
    contacts.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return contacts;
  }

  Future<EmergencyContact?> getById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  Future<void> save(EmergencyContact contact) async {
    final box = await _box;
    await box.put(contact.id, contact);
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<void> deleteAll() async {
    final box = await _box;
    await box.clear();
  }
}
