/// The user's personal identity and medical information.
///
/// JSON-backed singleton (`user_profile.json`). All fields are nullable
/// free-form strings — not typed lists. See spec 03 §UserProfile.
///
/// Medical fields are included in emergency SMS only when the active step
/// opts in via [SmsContactConfig.includeMedicalInfo].
final class UserProfile {
  /// Creates a [UserProfile] instance.
  ///
  /// All fields are optional.
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

  /// User's display name, substituted into SMS templates.
  final String? name;

  /// User's age in years.
  final int? age;

  /// User's own phone number in E.164 format.
  final String? phoneNumber;

  /// App-internal path to the user's photo.
  final String? photoPath;

  /// Free-form physical description for responders
  /// (e.g., "175cm, brown hair, wearing red").
  final String? physicalDescription;

  /// Free-form blood type (e.g., "O+").
  final String? bloodType;

  /// Free-form allergies (comma-separated or prose).
  final String? allergies;

  /// Free-form medications (comma-separated or prose).
  final String? medications;

  /// Free-form medical conditions.
  final String? medicalConditions;

  /// Free-form emergency instructions for responders.
  final String? emergencyInstructions;

  /// True when any medical field carries content.
  ///
  /// Used by [SessionLogRecorder] to stamp [SessionLog.hadMedicalInfo] at
  /// session start.
  bool get hasMedicalInfo =>
      bloodType != null ||
      allergies != null ||
      medications != null ||
      medicalConditions != null ||
      emergencyInstructions != null;

  /// Returns a copy with the specified fields replaced.
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
    emergencyInstructions: emergencyInstructions ?? this.emergencyInstructions,
  );

  /// Serialises this profile to a JSON map.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (age != null) 'age': age,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
    if (photoPath != null) 'photoPath': photoPath,
    if (physicalDescription != null) 'physicalDescription': physicalDescription,
    if (bloodType != null) 'bloodType': bloodType,
    if (allergies != null) 'allergies': allergies,
    if (medications != null) 'medications': medications,
    if (medicalConditions != null) 'medicalConditions': medicalConditions,
    if (emergencyInstructions != null)
      'emergencyInstructions': emergencyInstructions,
  };

  /// Deserialises a [UserProfile] from [json].
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          name == other.name &&
          age == other.age &&
          phoneNumber == other.phoneNumber &&
          photoPath == other.photoPath &&
          physicalDescription == other.physicalDescription &&
          bloodType == other.bloodType &&
          allergies == other.allergies &&
          medications == other.medications &&
          medicalConditions == other.medicalConditions &&
          emergencyInstructions == other.emergencyInstructions);

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
}
