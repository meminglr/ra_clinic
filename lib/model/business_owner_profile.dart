class BusinessOwnerProfile {
  final String uid;
  final String firstName;
  final String lastName;
  final String businessName;
  final String phoneNumber;
  final String photoUrl;

  BusinessOwnerProfile({
    required this.uid,
    required this.firstName,
    this.lastName = '',
    this.businessName = '',
    this.phoneNumber = '',
    this.photoUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'businessName': businessName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
    };
  }

  factory BusinessOwnerProfile.fromMap(Map<String, dynamic> map, String uid) {
    return BusinessOwnerProfile(
      uid: uid,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      businessName: map['businessName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
    );
  }

  BusinessOwnerProfile copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? businessName,
    String? phoneNumber,
    String? photoUrl,
  }) {
    return BusinessOwnerProfile(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      businessName: businessName ?? this.businessName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
