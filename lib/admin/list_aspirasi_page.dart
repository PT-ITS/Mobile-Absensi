import 'dart:convert';
import 'package:mobile_absensi/admin/aspirasi_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_absensi/components/konten_card.dart';
import 'package:mobile_absensi/states/auth_state.dart';

class ListAspirasiPage extends StatefulWidget {
  @override
  _ListAspirasiPageState createState() => _ListAspirasiPageState();
}

class _ListAspirasiPageState extends State<ListAspirasiPage> {
  late String token;
  List<dynamic> dataAspirasi = [];
  List<dynamic> dataResponse = [];
  bool loading = true;
  bool nullResponse = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getTokenFromSharedPreferences();
  }

  Future<void> getTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    if (token.isNotEmpty) {
      getDataAspirasi();
    }
  }

  Future<void> getDataAspirasi() async {
    try {
      const String apiUrl = 'http://localhost:8000/api/auth/list-aspirasi';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          loading = false;
          dataAspirasi = responseData['data'];
          dataResponse = responseData['data'];
          nullResponse = dataAspirasi.isEmpty;
        });
      } else {
        setState(() {
          loading = false;
        });
        _showErrorDialog('Request Gagal',
            'Tidak dapat menampilkan data aspirasi, silahkan dicoba kembali');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      _showErrorDialog(
          'Masalah Koneksi', 'Periksa koneksi anda, lalu coba kembali');
    }
  }

  void _showErrorDialog(title, message) {
    showDialog(
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
    final authState = Provider.of<AuthState>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Search aspirasi',
            labelStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              // Filtering data based on the 'aspirasi' field
              dataAspirasi = dataResponse
                  .where((item) => item['aspirasi']
                      .toLowerCase()
                      .contains(value.toLowerCase()))
                  .toList();
            });
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : nullResponse
              ? Center(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Belum ada aspirasi',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: dataAspirasi.length,
                  itemBuilder: (context, index) {
                    return ContentCard(
                      userId: authState.userId!,
                      id: dataAspirasi[index]['_id'],
                      name: dataAspirasi[index]['name'],
                      kelas: dataAspirasi[index]['kelas'],
                      aspirasi: dataAspirasi[index]['aspirasi'],
                      likes: dataAspirasi[index]['jumlah_like'],
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AspirasiPage(),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red, // Sesuaikan warna dengan tema Anda
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
