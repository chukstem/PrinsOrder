import 'package:flutter/widgets.dart';
import '../screens/complete_profile/complete_profile_screen.dart';
import '../screens/forgot_password/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/notifications/notifications_page.dart';
import '../screens/otp/otp_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/sign_in/sign_in_screen.dart';
import '../screens/splash/splash.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/splash/welcome.dart';

import 'screens/sign_up/sign_up_screen.dart';

final Map<String, WidgetBuilder> routes = {
  Splash.routeName: (context) => Splash(),
  SplashScreen.routeName: (context) => SplashScreen(),
  SignInScreen.routeName: (context) => SignInScreen(),
  ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen(),
  SignUpScreen.routeName: (context) => SignUpScreen(),
  CompleteProfileScreen.routeName: (context) => CompleteProfileScreen(),
  OtpScreen.routeName: (context) => OtpScreen(),
  HomeScreen.routeName: (context) => HomeScreen(),
  ProfileScreen.routeName: (context) => ProfileScreen(),
  WelcomeScreen.routeName: (context) => WelcomeScreen(),
  Notifications.routeName: (context) => Notifications(),
};
