/// `UserProfile` — user identity + medical information injected
/// into distress messages when a step requests it.
library;

/// User's personal and medical profile.
final class UserProfile {
  /// Creates a user profile.
  ///
  /// [name] — user's display name; optional.
  /// [age] — age in years; optional.
  /// [phoneNumber] — user's own phone number; optional.
  /// [photoPath] — file system path to a profile photo; null if none.
  /// [physicalDescription] — free-form description (hair, height, etc.);
  ///   optional.
  /// [bloodType] — e.g., "O+"; optional.
  /// [allergies] — free-form allergies text; optional.
  /// [medications] — free-form medications text; optional.
  /// [medicalConditions] — free-form conditions text; optional.
  /// [emergencyInstructions] — free-form instructions; optional.
  const UserProfile({
    this.name,
    this.age,
    this.phoneNumber,
    this.photoPath,
    this.physicalDescription,
    this.bloodType,
    this.allergies,
    this.medications,
    this.medicalConditions,
    this.emergencyInstructions,
  });

  /// Deserializes a `UserProfile` from JSON.
  factory UserProfile.fromJson(Map<String, Object?> json) => UserProfile(
    name: json['name'] as String?,
    age: (json['age'] as num?)?.toInt(),
    phoneNumber: json['phoneNumber'] as String?,
    photoPath: json['photoPath'] as String?,
    physicalDescription: json['physicalDescription'] as String?,
    bloodType: json['bloodType'] as String?,
    allergies: json['allergies'] as String?,
    medications: json['medications'] as String?,
    medicalConditions: json['medicalConditions'] as String?,
    emergencyInstructions: json['emergencyInstructions'] as String?,
  );

  /// User's display name. Defaults to null.
  final String? name;

  /// User's age in years. Defaults to null.
  final int? age;

  /// User's own phone number. Defaults to null.
  final String? phoneNumber;

  /// File system path to a profile photo. Defaults to null.
  final String? photoPath;

  /// Free-form physical description (hair color, height, etc.).
  /// Defaults to null.
  final String? physicalDescription;

  /// User's blood type. Defaults to null.
  final String? bloodType;

  /// Free-form allergies text. Defaults to null.
  final String? allergies;

  /// Free-form medications text. Defaults to null.
  final String? medications;

  /// Free-form medical conditions text. Defaults to null.
  final String? medicalConditions;

  /// Free-form emergency instructions. Defaults to null.
  final String? emergencyInstructions;

  /// True iff any medical field carries information. Used when
  /// deciding whether to stamp `SessionLog.hadMedicalInfo`.
  bool get hasMedicalInfo =>
      bloodType != null ||
      (allergies?.trim().isNotEmpty ?? false) ||
      (medications?.trim().isNotEmpty ?? false) ||
      (medicalConditions?.trim().isNotEmpty ?? false) ||
      (emergencyInstructions?.trim().isNotEmpty ?? false);

  /// Returns a new profile with the given fields replaced.
  UserProfile copyWith({
    String? name,
    int? age,
    String? phoneNumber,
    String? photoPath,
    String? physicalDescription,
    String? bloodType,
    String? allergies,
    String? medications,
    String? medicalConditions,
    String? emergencyInstructions,
  }) => UserProfile(
    name: name ?? this.name,
    age: age ?? this.age,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    photoPath: photoPath ?? this.photoPath,
    physicalDescription: physicalDescription ?? this.physicalDescription,
    bloodType: bloodType ?? this.bloodType,
    allergies: allergies ?? this.allergies,
    medications: medications ?? this.medications,
    medicalConditions: medicalConditions ?? this.medicalConditions,
    emergencyInstructions:
        emergencyInstructions ?? this.emergencyInstructions,
  );

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
    'name': name,
    'age': age,
    'phoneNumber': phoneNumber,
    'photoPath': photoPath,
    'physicalDescription': physicalDescription,
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
        other.phoneNumber == phoneNumber &&
        other.photoPath == photoPath &&
        other.physicalDescription == physicalDescription &&
        other.bloodType == bloodType &&
        other.allergies == allergies &&
        other.medications == medications &&
        other.medicalConditions == medicalConditions &&
        other.emergencyInstructions == emergencyInstructions;
  }

  @override
  int get hashCode => Object.hash(
    name,
    age,
    phoneNumber,
    photoPath,
    physicalDescription,
    bloodType,
    allergies,
    medications,
    medicalConditions,
    emergencyInstructions,
  );

  @override
  String toString() => 'UserProfile(name: $name)';
}
