import 'dart:convert';
import 'package:mobile_absensi/states/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_absensi/admin/menu.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AspirasiPage extends StatefulWidget {
  @override
  _AspirasiPageState createState() => _AspirasiPageState();
}

class _AspirasiPageState extends State<AspirasiPage> {
  String? token;
  bool loading = false;

  TextEditingController aspirasiController = TextEditingController();
  TextEditingController kelasController = TextEditingController();
  double kepuasan = 0;
  TextEditingController namaController = TextEditingController();

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
      // fetchDataFromApi();
    }
    print('tps token: $token');
  }

  Future<void> _submitData(user_id) async {
    try {
      const String apiUrl = 'http://localhost:8000/api/auth/create-aspirasi';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'name': namaController.text.toString(),
          'kelas': kelasController.text.toString(),
          'aspirasi': aspirasiController.text.toString(),
          'user_id': user_id.toString(),
        },
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('berhasil: $responseData');
        setState(() {
          loading = true;
        });
        await _showDialog('Request Berhasil', 'Aspirasi anda berhasil dikirim');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuAdmin(),
          ),
        );
      } else {
        _showDialog('Request Gagal', 'Gagal mengirimkan feedback');
        setState(() {
          loading = false;
        });
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      _showDialog(
          'Koneksi Gagal', 'Periksa koneksi internet anda, lalu coba lagi');
      setState(() {
        loading = false;
      });
      print('Error: $e');
      // Tambahkan penanganan error sesuai kebutuhan
    }
  }

  Future<void> _showDialog(title, message) async {
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
    final authState = Provider.of<AuthState>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Form Aspirasi',
          style: TextStyle(fontSize: 20),
        ),
      ),
      backgroundColor: Colors.white,
      body: loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Loading...',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // nama
                  TextFormField(
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    controller: namaController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  // alamat
                  TextFormField(
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: 'Kelas',
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    controller: kelasController,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // aspirasi
                  TextFormField(
                    style: const TextStyle(color: Colors.black),
                    controller: aspirasiController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Aspirasi',
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _submitData(authState.userId);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      primary: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
    );
  }
}
