import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:planno/firebase_options.dart';
import 'core/routing/app_router.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'viewmodels/focus_viewmodel.dart';
import 'viewmodels/stats_viewmodel.dart';
import 'viewmodels/task_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PlannoApp());
}

class PlannoApp extends StatelessWidget {
  const PlannoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskViewModel>(
          create: (context) => TaskViewModel(),
        ),
        ChangeNotifierProvider<FocusViewModel>(
          create: (context) => FocusViewModel(),
        ),
        ChangeNotifierProvider<StatsViewModel>(
          create: (context) => StatsViewModel(
            taskViewModel: Provider.of<TaskViewModel>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Planno',
        theme: ThemeData(
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        routerConfig: router,
      ),
    );
  }
}
