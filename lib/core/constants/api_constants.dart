/// API Constants and Endpoints matching API_DOCUMENTATION.md
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://hakori-service.onrender.com/api';
  static const Duration connectTimeout = Duration(seconds: 25);
  static const Duration receiveTimeout = Duration(seconds: 25);

  // Auth endpoints
  static const String signupInit = '/auth/signup/init';
  static const String signupVerify = '/auth/signup/verify';
  static const String signupComplete = '/auth/signup/complete';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyResetOtp = '/auth/verify-reset-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String authMe = '/auth/me';
  static const String logout = '/auth/logout';

  // User endpoints
  static const String userProfile = '/users/profile';

  // Products & Categories
  static const String products = '/products';
  static const String productCategories = '/products/categories';
  static String productDetail(String id) => '/products/$id';
  static const String categories = '/categories';
  static String categoryDetail(String id) => '/categories/$id';

  // Orders
  static const String orders = '/orders';
  static const String myOrders = '/orders/my-orders';
  static String orderDetail(String id) => '/orders/$id';
  static String cancelOrder(String id) => '/orders/$id/cancel';
  static String verifyPayment(String reference) => '/orders/payment/verify/$reference';

  // Consultations & Concierge
  static const String consultations = '/consultations';
  static String consultationDetail(String id) => '/consultations/$id';

  // Tickets
  static const String tickets = '/tickets';
  static String ticketDetail(String id) => '/tickets/$id';
  static String ticketReply(String id) => '/tickets/$id/reply';

  // Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';

  // System
  static const String health = '/health';
}
