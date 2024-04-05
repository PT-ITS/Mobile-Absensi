import 'dart:convert';
import 'package:mobile_absensi/admin/menu.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mobile_absensi/states/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SuratSuaraPage extends StatefulWidget {
  @override
  _SuratSuaraPageState createState() => _SuratSuaraPageState();
}

class _SuratSuaraPageState extends State<SuratSuaraPage> {
  List<dynamic> candidateList = [];
  List<dynamic> timeVote = [];
  late DateTime startTime;
  late DateTime endTime;
  String? token;
  bool loading = true;

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
      // Dekode token dan tampilkan payload
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
      print('Payload token: $decodedToken');

      // panggal fungsi yang dibutuhkan
      // checkTimeVote();
      // voterIsVoted(decodedToken['id']);
      fetchDataSuratSuara(decodedToken['id']);
    }
  }

  Future<void> fetchDataSuratSuara(id) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/auth/surat-suara/${id}'),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          startTime =
              DateTime.parse(responseData['data']['timeVote'][0]['start_time']);
          endTime =
              DateTime.parse(responseData['data']['timeVote'][0]['end_time']);
          candidateList = responseData['data']['dataCandidates'];
          loading = false;
        });
        print('start time: $startTime');
        print('start time: $startTime');
        print('candidate list: $candidateList');

        final currentDate = DateTime.now();
        if (currentDate.isAfter(startTime) && currentDate.isBefore(endTime)) {
          print('aman');
        } else {
          String startTimes = startTime.toString().substring(0, 15);
          String endTimes = endTime.toString().substring(0, 15);
          _showDialogTime('Waktu Pemilihan',
              'Pemilihan dimulai pada $startTimes dan berakhir pada $endTimes');
        }

        if (responseData['data']['statusVote'] == '1') {
          _showDialogTime(
              'Sudah Memilih', 'Anda sudah menggunkan hak suara sebelumnya!!');
        }
      } else {
        // Handle error response
      }
    } catch (e) {
      print('error: $e');
      // Handle and show error message
    }
  }

  Future<void> voteCandidate(String candidateId, String userId) async {
    try {
      const String apiUrl = 'http://localhost:8000/api/auth/input-suara';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'user_id': userId,
          'candidate_id': candidateId,
        },
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('berhasil: $responseData');
        setState(() {
          loading = true;
        });
        await _showDialog('Request Berhasil', 'Suara berhasil disimpan');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuAdmin(),
          ),
        );
      } else {
        _showDialog('Request Gagal', 'Suara gagal disimpan');
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

  Future<void> _showDialogTime(title, message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuAdmin(),
                ),
              );
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
          'Surat Suara',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                for (var candidate in candidateList)
                  buildCandidateCard(candidate, authState.userId),
              ],
            ),
      backgroundColor: Colors.white,
    );
  }

  Widget buildCandidateCard(candidate, userId) {
    return Card(
      elevation: 4.0,
      color: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Konfirmasi Pilihan"),
                content: Text(
                    "Apakah Anda yakin ingin memilih pasangan ${candidate['name']}? Setelah Anda konfirmasi, suara Anda akan dikirim dan tidak dapat dibuka kembali."),
                actions: [
                  TextButton(
                    onPressed: () {
                      voteCandidate(candidate['_id'], userId!);
                      Navigator.of(context).pop();
                    },
                    child: Text("Yakin"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Batal"),
                  ),
                ],
              );
            },
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 80.0,
                    height: 80.0,
                    child: Image.network(
                      'http://localhost:8000/public/storage/image/${candidate["image"]}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calon Ketua',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        candidate['name'].split(' & ')[0],
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      const Text(
                        'Calon Wakil',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        candidate['name'].split(' & ')[1],
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Visi: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    candidate['vision'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
