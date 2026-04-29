import 'package:get/get.dart';
import 'package:lifeos/controllers/auth_controller.dart';
import 'package:lifeos/controllers/profile_controller.dart';
import 'package:lifeos/controllers/task_controller.dart';
import 'package:lifeos/services/auth_service.dart';
import 'package:lifeos/services/profile_service.dart';
import 'package:lifeos/services/secure_storage_service.dart';
import 'package:lifeos/services/ssl_pinning_service.dart';
import 'package:lifeos/services/task_storage_service.dart';
import 'package:lifeos/services/notification_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    if (!Get.isRegistered<NotificationService>()) {
      Get.lazyPut<NotificationService>(() => NotificationService(), fenix: true);
    }
    Get.lazyPut<AuthController>(
      () => AuthController(Get.find<AuthService>()),
      fenix: true,
    );
    Get.lazyPut<ProfileService>(() => ProfileService(), fenix: true);
    Get.lazyPut<SecureStorageService>(
      () => SecureStorageService(),
      fenix: true,
    );
    // Register secure HTTP client provider for API pinning support (optional).
    Get.lazyPut<SecureHttpClientProvider>(
      () => SecureHttpClientProvider(),
      fenix: true,
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<ProfileService>(),
        Get.find<SecureStorageService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<TaskStorageService>(() => TaskStorageService(), fenix: true);
    Get.lazyPut<TaskController>(
      () => TaskController(
        Get.find<TaskStorageService>(),
        Get.find<NotificationService>(),
      ),
      fenix: true,
    );
  }
}
