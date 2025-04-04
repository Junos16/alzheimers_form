import 'package:flutter/material.dart';
import 'home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  //WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env").catchError((error) {
    print("Error loading .env file: $error");
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Alzheimer's Disease Form",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
