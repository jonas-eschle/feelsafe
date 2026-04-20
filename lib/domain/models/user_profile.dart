/// `UserProfile` — user identity + medical information injected
/// into distress messages when a step requests it.
library;

/// User's personal and medical profile.
final class UserProfile {
  /// Creates a user profile.
  ///
  /// [name] — user's display name; optional.
  /// [age] — age in years; optional.
  /// [bloodType] — e.g., "O+"; optional.
  /// [allergies] — list of allergies; defaults to empty.
  /// [medications] — list of medications; defaults to empty.
  /// [medicalConditions] — list of conditions; defaults to empty.
  /// [emergencyInstructions] — free-form instructions; optional.
  const UserProfile({
    this.name,
    this.age,
    this.bloodType,
    this.allergies = const [],
    this.medications = const [],
    this.medicalConditions = const [],
    this.emergencyInstructions,
  });

  /// Deserializes a `UserProfile` from JSON.
  factory UserProfile.fromJson(Map<String, Object?> json) => UserProfile(
    name: json['name'] as String?,
    age: (json['age'] as num?)?.toInt(),
    bloodType: json['bloodType'] as String?,
    allergies: _stringList(json['allergies']),
    medications: _stringList(json['medications']),
    medicalConditions: _stringList(json['medicalConditions']),
    emergencyInstructions: json['emergencyInstructions'] as String?,
  );

  /// User's display name. Defaults to null.
  final String? name;

  /// User's age in years. Defaults to null.
  final int? age;

  /// User's blood type. Defaults to null.
  final String? bloodType;

  /// Allergies. Defaults to empty.
  final List<String> allergies;

  /// Medications. Defaults to empty.
  final List<String> medications;

  /// Medical conditions. Defaults to empty.
  final List<String> medicalConditions;

  /// Free-form emergency instructions. Defaults to null.
  final String? emergencyInstructions;

  /// True iff any medical field carries information. Used when
  /// deciding whether to stamp `SessionLog.hadMedicalInfo`.
  bool get hasMedicalInfo =>
      bloodType != null ||
      allergies.isNotEmpty ||
      medications.isNotEmpty ||
      medicalConditions.isNotEmpty ||
      (emergencyInstructions != null &&
          emergencyInstructions!.trim().isNotEmpty);

  /// Returns a new profile with the given fields replaced.
  UserProfile copyWith({
    String? name,
    int? age,
    String? bloodType,
    List<String>? allergies,
    List<String>? medications,
    List<String>? medicalConditions,
    String? emergencyInstructions,
  }) => UserProfile(
    name: name ?? this.name,
    age: age ?? this.age,
    bloodType: bloodType ?? this.bloodType,
    allergies: allergies ?? this.allergies,
    medications: medications ?? this.medications,
    medicalConditions: medicalConditions ?? this.medicalConditions,
    emergencyInstructions: emergencyInstructions ?? this.emergencyInstructions,
  );

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
    'name': name,
    'age': age,
    'bloodType': bloodType,
    'allergies': allergies,
    'medications': medications,
    'medicalConditions': medicalConditions,
    'emergencyInstructions': emergencyInstructions,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UserProfile) return false;
    return other.name == name &&
        other.age == age &&
        other.bloodType == bloodType &&
        _listEquals(other.allergies, allergies) &&
        _listEquals(other.medications, medications) &&
        _listEquals(other.medicalConditions, medicalConditions) &&
        other.emergencyInstructions == emergencyInstructions;
  }

  @override
  int get hashCode => Object.hash(
    name,
    age,
    bloodType,
    Object.hashAll(allergies),
    Object.hashAll(medications),
    Object.hashAll(medicalConditions),
    emergencyInstructions,
  );

  @override
  String toString() => 'UserProfile(name: $name)';
}

List<String> _stringList(Object? raw) {
  if (raw is List) {
    return List<String>.unmodifiable(raw.map((e) => e as String));
  }
  return const [];
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
