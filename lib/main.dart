import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_supabase_zegocloud_chat_app/screens/HomeScreen.dart';
import 'package:flutter_supabase_zegocloud_chat_app/screens/RecentChatScreen.dart';
import 'package:flutter_supabase_zegocloud_chat_app/screens/auth/LoginScreen.dart';
import 'package:flutter_supabase_zegocloud_chat_app/services/UiProvider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPA_BASE_URL'] ?? "",
    anonKey: dotenv.env['SUPA_BASE_ANON_KEY'] ?? "",
  );

  // ✅ Initialize ZEGOCLOUD ZIMKit
  ZIMKit().init(
    // Replace with your ZEGOCLOUD appID
    // Convert to int,
    appID: int.parse(dotenv.env['ZEGOCLOUD_APP_ID'] ?? '0'),
    appSign: dotenv.env['ZEGOCLOUD_APP_SIGN'] ?? "", // Replace with your appSign
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context)=>UiProvider()..init(),
      child: Consumer<UiProvider>(
        builder: (context, UiProvider notifier, child) {
          return MaterialApp(

            debugShowCheckedModeBanner: false,

            // title: 'Dark Theme',
            //By default theme setting, you can also set system
            // when your mobile theme is dark the app also become dark

            themeMode: notifier.isDark ? ThemeMode.dark : ThemeMode.light,

            //Our custom theme applied
            darkTheme: notifier.isDark ? notifier.darkTheme : notifier.lightTheme,

            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),

            home: LoginScreen(title: 'Login'),

          );
        },
      ),
    );
  }
}