import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:seeme_test/features/auth/controller/auth_controller.dart';
import 'package:seeme_test/firebase_options.dart';
import 'package:seeme_test/models/user_model.dart';
import 'package:seeme_test/router.dart';
import 'package:seeme_test/theme/pallete.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  UserModel? userModel;

  Future<void> getData(WidgetRef ref, User data) async {
    userModel = await ref
        .watch(authControllerProvider.notifier)
        .getUserData(data.uid)
        .first;
    ref.read(userProvider.notifier).update((state) => userModel);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(authStateChangeProvider).when(
          data: (data) {
            if (data != null) {
              return FutureBuilder<void>(
                future: getData(ref, data),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const MaterialApp(
                      home: Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    if (userModel != null) {
                      return MaterialApp.router(
                        debugShowCheckedModeBanner: false,
                        title: 'Reddit Tutorial',
                        theme: ref.watch(themeNotifierProvider),
                        routerDelegate: RoutemasterDelegate(
                          routesBuilder: (context) => loggedInRoute,
                        ),
                        routeInformationParser: const RoutemasterParser(),
                      );
                    } else {
                      return MaterialApp.router(
                        debugShowCheckedModeBanner: false,
                        title: 'Reddit Tutorial',
                        theme: ref.watch(themeNotifierProvider),
                        routerDelegate: RoutemasterDelegate(
                          routesBuilder: (context) => loggedOutRoute,
                        ),
                        routeInformationParser: const RoutemasterParser(),
                      );
                    }
                  } else {
                    return MaterialApp.router(
                      debugShowCheckedModeBanner: false,
                      title: 'Reddit Tutorial',
                      theme: ref.watch(themeNotifierProvider),
                      routerDelegate: RoutemasterDelegate(
                        routesBuilder: (context) => loggedOutRoute,
                      ),
                      routeInformationParser: const RoutemasterParser(),
                    );
                  }
                },
              );
            } else {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Reddit Tutorial',
                theme: ref.watch(themeNotifierProvider),
                routerDelegate: RoutemasterDelegate(
                  routesBuilder: (context) => loggedOutRoute,
                ),
                routeInformationParser: const RoutemasterParser(),
              );
            }
          },
          error: (error, stackTrace) {
            print('Error: $error');
            print('StackTrace: $stackTrace');
            return MaterialApp(
              home: Scaffold(
                body: Center(child: Text('Error: $error')),
              ),
            );
          },
          loading: () => const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          ),
        );
  }
}
