import 'package:get/get.dart';
import '../presentation/pages/splash_page.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/baby_management_page.dart';
import '../presentation/pages/assessment_page.dart';
import '../presentation/pages/result_page.dart';
import '../presentation/pages/history_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String babyManagement = '/baby-management';
  static const String assessment = '/assessment';
  static const String result = '/result';
  static const String history = '/history';

  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => SplashPage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: home,
      page: () => HomePage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: babyManagement,
      page: () => BabyManagementPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: assessment,
      page: () => AssessmentPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: result,
      page: () => ResultPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: history,
      page: () => HistoryPage(),
      transition: Transition.rightToLeft,
    ),
  ];
} 