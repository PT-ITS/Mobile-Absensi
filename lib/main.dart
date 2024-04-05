import 'package:flutter/material.dart';
import 'package:mobile_absensi/states/auth_state.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthState(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              unselectedItemColor: Colors.black,
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0, // remove shadow
            )),
        home: SplashScreen(),
        // home: MenuAdmin(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
