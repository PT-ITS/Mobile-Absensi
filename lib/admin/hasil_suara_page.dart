import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HasilSuaraPage extends StatefulWidget {
  const HasilSuaraPage({Key? key}) : super(key: key);

  @override
  _HasilSuaraPageState createState() => _HasilSuaraPageState();
}

class _HasilSuaraPageState extends State<HasilSuaraPage> {
  List<Map<String, dynamic>> hasilSuara = [];
  String? token;
  double persentaseSuaraMasuk = 0.0;

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

  void fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/auth/hasil-suara'),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body)['data'];
        setState(() {
          hasilSuara = List<Map<String, dynamic>>.from(
              responseData['semua_kandidat'].values);
          persentaseSuaraMasuk = responseData['persentase_surat_masuk'];
        });
        print('test hasil: $responseData');
      } else {
        // Handle error response
        print('Error response: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle and show error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Hasil Suara'),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildPieChart(),
              ),
              SizedBox(height: 20),
              _buildLegend(),
              SizedBox(height: 10),
              Text(
                'Persentase Suara Masuk: $persentaseSuaraMasuk%',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    // Build your pie chart here using the data in hasilSuara
    // Example:
    return PieChart(
      PieChartData(
        sections: _generateSections(),
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
        centerSpaceRadius: 40,
      ),
    );
  }

  List<PieChartSectionData> _generateSections() {
    // Generate pie chart sections based on hasilSuara
    return List.generate(
      hasilSuara.length,
      (index) => PieChartSectionData(
        color: _getColor(index),
        value: hasilSuara[index]['jumlah_suara'].toDouble(),
        title: '${hasilSuara[index]['persentase_suara']}%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getColor(int index) {
    // Assign different colors for different candidates
    switch (index % 3) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLegend() {
    // You can build legend items here based on the data in hasilSuara
    // Example:
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: hasilSuara.map((data) {
        return _buildLegendItem(
            _getColor(hasilSuara.indexOf(data)), data['name']);
      }).toList(),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
