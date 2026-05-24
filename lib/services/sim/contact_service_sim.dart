import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/services/protocols/contact_service_protocol.dart';

/// Simulation [ContactServiceProtocol] for tests and simulation isolates.
///
/// Takes a constructor-injected fake contact list; never touches the Drift
/// database. All lookups operate on the injected list.
class SimulationContactService implements ContactServiceProtocol {
  /// Creates a [SimulationContactService] with [contacts] as the fake list.
  ///
  /// [contacts] defaults to an empty list.
  SimulationContactService({List<EmergencyContact>? contacts})
    : _contacts = contacts ?? [];

  final List<EmergencyContact> _contacts;
  late final Map<String, EmergencyContact> _byId = {
    for (final c in _contacts) c.id: c,
  };

  @override
  List<EmergencyContact> get all => List.unmodifiable(
    _contacts..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
  );

  @override
  EmergencyContact? byId(String id) => _byId[id];
}
