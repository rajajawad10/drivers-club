class ApiConstants {
  static const String baseUrl = 'https://api.pitstop.ahdus.de/api/v1';

  // Auth endpoints
  static const String signIn         = '/auth/sign-in';
  static const String signUp         = '/auth/sign-up';
  static const String signOut        = '/auth/sign-out';
  static const String refreshToken   = '/auth/refresh';
  static const String getProfile     = '/auth/profile';
  static const String updateProfile  = '/auth/profile';
  static const String updateAvatar   = '/auth/profile/avatar';
  static const String changePassword = '/auth/change-password';

  // Events endpoints — crmId is dynamic, passed at runtime
  static String getEvents(String crmId) => '/crms/$crmId/events';
  static String getEventById(String crmId, String eventId) =>
      '/crms/$crmId/events/$eventId';

  // Communities endpoints
  static const String communities = '/communities';
  static String communityById(String id) => '/communities/$id';
  static String joinCommunity(String id) => '/communities/$id/join';
  static String leaveCommunity(String id) => '/communities/$id/leave';
  static String communityMembers(String id) => '/communities/$id/members';
  static const String myCommunities = '/communities/my';
  static String notifyCommunity(String id) => '/communities/$id/notify';

  static const Duration timeout = Duration(seconds: 30);
}