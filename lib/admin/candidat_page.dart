import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CandidatePage extends StatefulWidget {
  @override
  _CandidatePageState createState() => _CandidatePageState();
}

class _CandidatePageState extends State<CandidatePage> {
  String? token;
  List<dynamic> candidateList = [];
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
      fetchData();
    }
    print('tps token: $token');
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/auth/list-candidate'),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          candidateList = responseData['data'];
          loading = false;
        });
        print('test kandidat: $responseData');
      } else {
        // Handle error response
      }
    } catch (e) {
      print('error: $e');
      // Handle and show error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Kandidat',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: candidateList.length,
              itemBuilder: (context, index) {
                return buildCandidateCard(
                  candidateList[index]['name'],
                  candidateList[index]['vision'],
                  candidateList[index]['image'],
                );
              },
            ),
      backgroundColor: Colors.white,
    );
  }

  Widget buildCandidateCard(String name, String vision, String imagePath) {
    return Card(
      elevation: 4.0,
      color: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 80.0,
              height: 80.0,
              child: Image.network(
                'http://localhost:8000/storage/image/$imagePath',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Divider(color: Colors.white),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama: $name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Visi: $vision',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
