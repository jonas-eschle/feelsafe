import 'package:guardianangela/domain/models/emergency_contact.dart';

/// Abstract interface for emergency contact lookup used by event strategies.
///
/// Only the methods that strategies call are declared here.
abstract interface class ContactServiceProtocol {
  /// All emergency contacts, sorted by [EmergencyContact.sortOrder] ascending.
  ///
  /// Used by [SmsContactStrategy] for `allContacts` / `firstContact`
  /// selection, and by [CallEmergencyStrategy] for the optional pre-call
  /// SMS to emergency contacts.
  List<EmergencyContact> get all;

  /// Returns the contact with the given [id], or `null` if not found.
  ///
  /// Used by [PhoneCallContactStrategy] to resolve the primary contact and
  /// any alternative contacts, and by [SmsContactStrategy] for
  /// `specificIds` selection.
  EmergencyContact? byId(String id);
}
