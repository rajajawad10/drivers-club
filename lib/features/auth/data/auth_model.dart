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

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.isActive,
    this.organizationId,
    this.crmId,
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