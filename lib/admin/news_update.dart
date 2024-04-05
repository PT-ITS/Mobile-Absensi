import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Tambahkan import untuk http

class NewsUpdateSection extends StatefulWidget {
  @override
  _NewsUpdateSectionState createState() => _NewsUpdateSectionState();
}

class _NewsUpdateSectionState extends State<NewsUpdateSection> {
  List<dynamic> dataInformasi = [];
  bool loading = true;
  bool nullResponse = false;
  late String token;

  @override
  void initState() {
    super.initState();
    getTokenFromSharedPreferences();
  }

  Future<void> getTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') != null) {
      setState(() {
        token = prefs.getString('token')!;
      });
      getDataKontens();
    }
    print('tps token: $token');
  }

  Future<void> getDataKontens() async {
    try {
      const String apiUrl = 'http://localhost:8000/api/auth/list-berita';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final length = responseData['data'].length;
        setState(() {
          loading = false;
          dataInformasi = responseData['data'];
          if (length != 0) {
            nullResponse = false;
          } else {
            nullResponse = true;
          }
        });
        print('test data Informasi: $dataInformasi');
      } else {
        setState(() {
          loading = false;
        });
        // Handle error response
        print('Failed to load data from the API');
        _showErrorDialog('Request Gagal',
            'Tidak dapat menampilkan data konten, silahkan dicoba kembali');
      }
    } catch (e) {
      // Handle exception
      print('Error Api: $e');
      setState(() {
        loading = false;
      });
      _showErrorDialog(
          'Masalah Koneksi', 'Periksa koneksi anda, lalu coba kembali');
    }
  }

  Future<void> _showErrorDialog(title, message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Informasi Terkini',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 16),
          if (dataInformasi.isNotEmpty)
            ...dataInformasi.map((info) => NewsCard(
                  title: info['judul'],
                  content: info['deskripsi'],
                  date: info['created_at'] ?? 'Tanggal Tidak Tersedia',
                ))
          else
            Text('Tidak ada informasi yang ditemukan'),
        ],
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final String title;
  final String content;
  final String date;

  const NewsCard({
    required this.title,
    required this.content,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Tanggal: $date',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
