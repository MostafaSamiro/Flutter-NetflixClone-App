import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'Presentition/Views/AuthScreens/SplashWrapper.dart';
import 'Provider/AuthProvider.dart';
import 'Provider/LocaliztionProvider.dart';
import 'Provider/ThemeProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthFireBase()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
      ],
      child: Sizer(
        builder: (context, orientation, screenType) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: Consumer2<ThemeProvider,LocalizationProvider>(
              builder: (context, themeProvider, localizationProvider,child) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  themeMode: themeProvider.themeMode,
                  theme: ThemeProvider.lightTheme,
                  darkTheme: ThemeProvider.darkTheme,
                  locale: localizationProvider.locale,

                  home: AnimatedSplashScreen(
                    splash: "assets/Netflix Logo Animation.gif",
                    splashIconSize: 5000,
                    centered: true,
                    backgroundColor: Colors.black,
                    duration: 3200,
                    nextScreen: SplashNavigationWrapper(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
