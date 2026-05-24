import 'dart:developer';

import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/services/protocols/contact_service_protocol.dart';

/// Production [ContactServiceProtocol] backed by [ContactsRepository].
///
/// The in-memory cache is populated on [start] so that event strategies
/// never hit the database during [executeReal] (spec 05 §ContactService).
///
/// Call [start] once at session start and [stop] at session end.
///
/// **Single constructor location rule:** no `RealContactService()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealContactService implements ContactServiceProtocol {
  /// Creates a [RealContactService] backed by [repository].
  RealContactService({required ContactsRepository repository})
    : _repository = repository;

  final ContactsRepository _repository;

  List<EmergencyContact> _cache = [];
  final Map<String, EmergencyContact> _byId = {};

  @override
  List<EmergencyContact> get all => List.unmodifiable(_cache);

  @override
  EmergencyContact? byId(String id) => _byId[id];

  /// Pre-warms the in-memory cache from the database.
  ///
  /// Must be called before any strategy reads [all] or [byId].
  Future<void> start() async {
    final contacts = await _repository.getAll();
    _cache = contacts;
    _byId
      ..clear()
      ..addEntries(contacts.map((c) => MapEntry(c.id, c)));
    log(
      'start — loaded ${contacts.length} contacts into cache',
      name: 'ContactService',
    );
  }

  /// Clears the in-memory cache.
  ///
  /// Call at session end so stale data is not retained in memory.
  void stop() {
    _cache = [];
    _byId.clear();
    log('stop — cache cleared', name: 'ContactService');
  }
}
