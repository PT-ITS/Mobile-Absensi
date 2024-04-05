import 'package:flutter/material.dart';
import 'package:mobile_absensi/login_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
      // _getPreference();
    });
  }

  Widget _buildIconWithText(path, Color backgroundColor, String text) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Image.asset(
            path,
            width: 50,
            height: 50,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 150),
            Image.asset(
              'assets/img/logo-kpu.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildIconWithText('assets/img/screen/emergency.png',
                    Colors.blue, 'Emergency'),
                _buildIconWithText(
                    'assets/img/screen/gps.png', Colors.green, 'Detection'),
                _buildIconWithText('assets/img/screen/location.png',
                    Colors.orange, 'Realtime'),
                _buildIconWithText(
                    'assets/img/screen/phone.png', Colors.purple, 'Secure'),
              ],
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            const Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text('Instinc Technology Solution'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
