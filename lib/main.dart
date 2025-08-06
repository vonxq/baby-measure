import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'app/routes.dart';
import 'presentation/providers/baby_provider.dart';
import 'presentation/providers/assessment_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化路由
  Get.config(
    defaultTransition: Transition.fade,
    defaultDuration: Duration(milliseconds: 300),
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BabyProvider()),
        ChangeNotifierProvider(create: (_) => AssessmentProvider()),
      ],
      child: GetMaterialApp(
        title: '儿童发育评估',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue[600],
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'PingFang SC',
        ),
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.pages,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
} 