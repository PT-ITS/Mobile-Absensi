import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_absensi/admin/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_absensi/states/auth_state.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  DateTime dateTime = DateTime.now();
  bool _isObscured = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool checkedValue = false;
  bool loading = false;

  Future<void> _simpanToken(String token) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);
      print('token check: ${token}');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/auth/login'),
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        final responseData = json.decode(response.body);
        print('berhasil: $responseData');
        _simpanToken(responseData['access_token']);
        final authState = Provider.of<AuthState>(context, listen: false);

        authState.setAuthData(
          userId: responseData['sub'].toString(),
          namaUser: responseData['name'],
          emailUser: responseData['name'],
          levelUser: responseData['level'].toString(),
          statusUser: responseData['jabatan'],
        );

        // Arahkan ke halaman menu
        if (responseData['level'] == '0') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MenuAdmin(),
            ),
          );
        } else {
          setState(() {
            loading = false;
          });
          _showErrorDialog('Login Gagal', 'Akun anda tidak bisa masuk');
        }

        // if (responseData['status'] == '0') {
        //   setState(() {
        //     loading = false;
        //   });
        //   _showErrorDialog('Login Gagal', 'Akun anda belum di aktivasi');
        // }
      } else {
        print('gagal');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      print('error: $e');
      _showErrorDialog('Login Gagal', 'Periksan koneksi anda lalu coba lagi');
      // showErrorDialog('Periksa koneksi anda lalu coba kembali.');
    }
  }

  void autoSet() {
    _emailController.text = 'bagusuntoro@ptits.com';
    _passwordController.text = '12345';
  }

  @override
  void initState() {
    super.initState();

    autoSet();
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            color: const Color.fromRGBO(5, 6, 8, 0.85),
          ),
          Center(
            child: Image.asset(
              'assets/img/bg.jpg',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
              color: const Color.fromRGBO(255, 255, 255,
                  0.2), // Ganti warna putih untuk efek buram sesuai keinginan
              colorBlendMode: BlendMode.dstATop,
            ),
          ),
          // Layer 3: Konten di atas gambar
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircleAvatar(
                    radius: (52),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset("assets/img/logo-kpu.png"),
                    )),
                SizedBox(
                  height: 20,
                ),
                Card(
                  elevation: 5,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "LOGIN",
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        const SizedBox(height: 40),
                        // Form login
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: 'Username',
                              labelStyle: TextStyle(color: Colors.black),
                              prefixIcon: Icon(Icons.person),
                              filled: true, // Memberi latar belakang pada input
                              fillColor: Colors
                                  .white, // Mengatur warna latar belakang input menjadi putih
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: TextField(
                            controller: _passwordController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: 'Password',
                              labelStyle: TextStyle(color: Colors.black),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isObscured = !_isObscured;
                                  });
                                },
                                icon: Icon(
                                  _isObscured
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                            ),
                            obscureText: _isObscured,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CheckboxListTile(
                          tileColor: Colors.white,
                          title: const Text(
                            "Simpan email & password",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          value: checkedValue,
                          onChanged: (newValue) {
                            setState(() {
                              checkedValue = newValue!;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const SizedBox(
                          height: 20,
                        ),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                loading = true;
                              });
                              _login();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              primary: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(loading ? 'loading...' : 'Login'),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                const Text(
                  'Instinc Technology Solution',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
