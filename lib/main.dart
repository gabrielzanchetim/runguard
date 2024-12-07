import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:i_love_my_girlfriend/modelservices/services/auth_service.dart';
import 'package:i_love_my_girlfriend/bloc/user_bloc.dart';
import 'package:i_love_my_girlfriend/view/login_screen.dart';
import 'package:i_love_my_girlfriend/view/run_history_screen.dart';
import 'package:i_love_my_girlfriend/view/add_run_screen.dart';
import 'package:i_love_my_girlfriend/view/edit_run_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(),
        ),
        Provider<AuthService>(
          create: (context) => AuthService(),
        ),
        StreamProvider<User?>(
          create: (context) => context.read<AuthService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
        routes: {
          '/addRun': (context) => AddRunScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/editRun') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) {
                return EditRunScreen(
                  runId: args['runId'],
                  runData: args['runData'],
                );
              },
            );
          }
          return null;
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    print("AuthWrapper: User is ${user == null ? 'not ' : ''}signed in");

    if (user == null) {
      return LoginScreen();
    } else {
      return RunHistoryScreen();
    }
  }
}