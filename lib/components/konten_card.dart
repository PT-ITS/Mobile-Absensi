import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_absensi/admin/menu.dart';
import 'package:mobile_absensi/states/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContentCard extends StatefulWidget {
  final String userId;
  final String id;
  final String name;
  final String kelas;
  final String aspirasi;
  final int likes;

  const ContentCard({
    required this.userId,
    required this.id,
    required this.name,
    required this.kelas,
    required this.aspirasi,
    required this.likes,
  });

  @override
  _ContentCardState createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  late String token;
  late bool loading;
  bool isLikeContent = false;
  Color colors = Colors.red;

  @override
  void initState() {
    super.initState();
    loading = false;
    getTokenFromSharedPreferences();
  }

  Future<void> getTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') != null) {
      setState(() {
        token = prefs.getString('token')!;
      });
    }
  }

  Future<void> sendLike(String level) async {
    try {
      String apiUrl =
          'https://aaa.surabayawebtech.com/api/auth/reaksi-konten/${widget.id}';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'userId': widget.userId, 'reaksi': '1'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuAdmin(),
          ),
        );
      } else {
        setState(() {
          loading = false;
        });
        _showErrorDialog(
            'Gagal', 'Gagal tidak menyukai konten, silahkan coba kembali');
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog('Error Koneksi',
          'Gagal tidak menyukai konten, periksa koneksi internet anda');
    }
  }

  Future<void> isLike() async {
    try {
      final response = await http.post(
        Uri.parse('https://aaa.surabayawebtech.com/api/auth/islike'),
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: {
          'userId': widget.userId.toString(),
          'kontenId': widget.id.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status']) {
          setState(() {
            isLikeContent = true;
          });
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    return Card(
      color: colors,
      margin: const EdgeInsets.all(16.0),
      elevation: 5.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              widget.name,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              widget.kelas,
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              widget.aspirasi,
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      child: Icon(
                        Icons.favorite,
                        color: isLikeContent ? Colors.red : Colors.white,
                      ),
                      onTap: () {
                        if (!loading) {
                          setState(() {
                            loading = true;
                          });
                          sendLike(authState.levelUser.toString());
                        }
                      },
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      widget.likes.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
