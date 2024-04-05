import 'package:mobile_absensi/admin/history_absen_page.dart';
import 'package:mobile_absensi/admin/kecurangan_page.dart';
import 'package:mobile_absensi/admin/list_aspirasi_page.dart';
import 'package:flutter/material.dart';
import 'package:mobile_absensi/components/easy_access.dart';
import 'package:mobile_absensi/admin/news_update.dart';
import 'package:mobile_absensi/admin/hasil_suara_page.dart';
import 'package:mobile_absensi/admin/video.dart';
import 'package:mobile_absensi/states/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/carousel.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime dateTime = DateTime.now();
  int tabIndex = 0;
  bool show = false;
  List<dynamic> dataKonten = [];
  String? token;
  bool loading = true;
  bool nullResponse = false;

  @override
  void initState() {
    super.initState();
    getTokenFromSharedPreferences();
  }

  Future<void> getTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') != null) {
      setState(() {
        token = prefs.getString('token');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontSize: 20),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // card
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => YourVideoContainer(
                      videoUrl: 'video.mp4',
                    ),
                  ),
                );
              },
              child: Container(
                height: 200,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [Color.fromARGB(255, 58, 58, 58), Colors.blueGrey],
                    stops: [0.2, 0.8],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Text(
                        'Selamat ${dateTime.hour >= 1 && dateTime.hour <= 9 ? 'Pagi' : dateTime.hour > 9 && dateTime.hour < 15 ? 'Siang' : dateTime.hour >= 15 && dateTime.hour <= 19 ? 'Sore' : 'Malam'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 10,
                      right: 10,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        // You can add an icon or image here
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authState.namaUser ?? '',
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            'Backend Developer',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '10013980602',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),
            // menu
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // kandidat
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoryAbsensiPage(),
                          ),
                        );
                      },
                      child: EasyAccess(
                        icon: Icons.history,
                        color: Colors.blue,
                        text: 'Histori',
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HasilSuaraPage(),
                          ),
                        );
                      },
                      child: EasyAccess(
                        icon: Icons.mail,
                        color: Colors.blue,
                        text: 'Izin',
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KecuranganPage(),
                          ),
                        );
                      },
                      child: EasyAccess(
                        icon: Icons.beach_access,
                        color: Colors.blue,
                        text: 'Cuti',
                      ),
                    ),
                    // aspirasi
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListAspirasiPage(),
                          ),
                        );
                      },
                      child: EasyAccess(
                        icon: Icons.monetization_on,
                        color: Colors.blue,
                        text: 'Gaji',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(
              height: 15,
            ),
            // slider
            CarouselSection(),

            const SizedBox(
              height: 15,
            ),
            NewsUpdateSection(),
          ],
        ),
      ),
    );
  }
}
