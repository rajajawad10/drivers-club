// Request and response models — field names match exactly with Swagger.

// ── Login Request ──────────────────────────────────────────────────────────
class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() => {
    'email':      email,
    'password':   password,
    'rememberMe': rememberMe,
  };
}

// ── User Model ─────────────────────────────────────────────────────────────
class UserModel {
  final String  id;
  final String  email;
  final String  firstName;
  final String  lastName;
  final String  fullName;
  final bool    isActive;
  final String? organizationId;
  final String? crmId;
  final String? avatarUrl;
  final String? avatarBase64;
  final String? middleName;
  final String? birthday;
  final String? company;
  final String? jobTitle;
  final String? phone;
  final String? mobileNumber;
  final String? country;
  final String? address;
  final String? aptSuite;
  final String? city;
  final String? region;
  final String? postalCode;
  final bool?   emailOptIn;
  final String? customerType;
  final String? customerCategory;
  final String? gender;
  final String? vehicleChoice;
  final String? vinePref;
  final String? customFields;
  final String? houseNumber;
  final String? ort;
  final String? land;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.isActive,
    this.organizationId,
    this.crmId,
    this.avatarUrl,
    this.avatarBase64,
    this.middleName,
    this.birthday,
    this.company,
    this.jobTitle,
    this.phone,
    this.mobileNumber,
    this.country,
    this.address,
    this.aptSuite,
    this.city,
    this.region,
    this.postalCode,
    this.emailOptIn,
    this.customerType,
    this.customerCategory,
    this.gender,
    this.vehicleChoice,
    this.vinePref,
    this.customFields,
    this.houseNumber,
    this.ort,
    this.land,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:             json['id']?.toString()             ?? '',
      email:          json['email']?.toString()          ?? '',
      firstName:      json['firstName']?.toString()      ?? '',
      lastName:       json['lastName']?.toString()       ?? '',
      fullName:       json['fullName']?.toString()
          ?? '${json['firstName']} ${json['lastName']}',
      isActive:       json['isActive'] as bool?          ?? true,
      organizationId: json['organizationId']?.toString(),
      crmId:          json['crmId']?.toString(),
      avatarUrl:      json['avatarUrl']?.toString()
          ?? json['avatar']?.toString()
          ?? json['profileImage']?.toString()
          ?? json['image']?.toString(),
      avatarBase64:   json['avatarBase64']?.toString()
          ?? json['avatar_base64']?.toString(),
      middleName:     json['middleName']?.toString(),
      birthday:       json['birthday']?.toString(),
      company:        json['company']?.toString(),
      jobTitle:       json['jobTitle']?.toString(),
      phone:          json['phone']?.toString(),
      mobileNumber:   json['mobileNumber']?.toString()
          ?? json['mobile']?.toString(),
      country:        json['country']?.toString(),
      address:        json['address']?.toString(),
      aptSuite:       json['aptSuite']?.toString()
          ?? json['apt']?.toString(),
      city:           json['city']?.toString(),
      region:         json['region']?.toString(),
      postalCode:     json['postalCode']?.toString(),
      emailOptIn:     json['emailOptIn'] as bool?,
      customerType:   json['customerType']?.toString(),
      customerCategory: json['customerCategory']?.toString(),
      gender:         json['gender']?.toString(),
      vehicleChoice:  json['vehicleChoice']?.toString(),
      vinePref:       json['vinePref']?.toString(),
      customFields:   json['customFields']?.toString(),
      houseNumber:    json['houseNumber']?.toString(),
      ort:            json['ort']?.toString(),
      land:           json['land']?.toString(),
    );
  }
}

// ── Auth Response ──────────────────────────────────────────────────────────
// Matches exactly: { success, message, data: { user, accessToken, refreshToken } }
class AuthResponse {
  final String    accessToken;
  final String    refreshToken;
  final UserModel user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Response is wrapped in 'data' object
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return AuthResponse(
      accessToken:  data['accessToken']?.toString()  ?? '',
      refreshToken: data['refreshToken']?.toString() ?? '',
      user: UserModel.fromJson(
        data['user'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}