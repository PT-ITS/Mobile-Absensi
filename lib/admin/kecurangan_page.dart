import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KecuranganPage extends StatefulWidget {
  @override
  _KecuranganPageState createState() => _KecuranganPageState();
}

class _KecuranganPageState extends State<KecuranganPage> {
  late String? token;
  bool loading = false;
  final picker = ImagePicker();
  late TextEditingController lokasiController;
  late TextEditingController deskripsiController;
  File? _imageFile = null;

  @override
  void initState() {
    super.initState();
    lokasiController = TextEditingController();
    deskripsiController = TextEditingController();
    getTokenFromSharedPreferences();
  }

  Future<void> getTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') != null) {
      setState(() {
        token = prefs.getString('token');
      });
    }
    print('Token: $token');
  }

  Future<void> _submitData(user_id) async {
    try {
      const String apiUrl = 'http://localhost:8000/api/auth/create-report';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'lokasi': lokasiController.text,
          'deskripsi': deskripsiController.text,
          'user_id': user_id.toString(),
          'image': _imageFile != null
              ? base64Encode(_imageFile!.readAsBytesSync())
              : '',
        },
      );

      if (response.statusCode == 201) {
        setState(() {
          loading = true;
        });
        await _showDialog(
            'Request Berhasil', 'Laporan kecurangan berhasil dikirim');
        Navigator.pop(context);
      } else {
        _showDialog('Request Gagal', 'Gagal mengirimkan laporan kecurangan');
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

  Future<void> _pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Form Laporan Kecurangan'),
      ),
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Loading...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.camera_alt),
                    label: Text('Pilih Gambar'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.amber,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Lokasi Kecurangan',
                      border: OutlineInputBorder(),
                    ),
                    controller: lokasiController,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Deskripsi Kecurangan',
                      border: OutlineInputBorder(),
                    ),
                    controller: deskripsiController,
                    maxLines: 4,
                  ),
                  SizedBox(height: 20),
                  _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : SizedBox(height: 0),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Ganti dengan id pengguna yang sesuai
                      _submitData('user_id');
                    },
                    child: Text('Kirim Laporan'),
                  ),
                ],
              ),
            ),
    );
  }
}
