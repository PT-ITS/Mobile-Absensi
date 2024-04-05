import 'package:flutter/material.dart';

class Absensi {
  final String foto;
  final String nama;
  final String jabatan;
  final String hari;
  final String tanggal;
  final String jam;

  Absensi({
    required this.foto,
    required this.nama,
    required this.jabatan,
    required this.hari,
    required this.tanggal,
    required this.jam,
  });
}

class HistoryAbsensiPage extends StatelessWidget {
  final List<Absensi> absensiList = [
    Absensi(
      foto: 'assets/images/employee1.jpg',
      nama: 'John Doe',
      jabatan: 'Manager',
      hari: 'Senin',
      tanggal: '1 Januari 2024',
      jam: '08:00',
    ),
    Absensi(
      foto: 'assets/images/employee2.jpg',
      nama: 'Jane Doe',
      jabatan: 'Staff',
      hari: 'Selasa',
      tanggal: '2 Januari 2024',
      jam: '09:30',
    ),
    // Tambahkan data absensi lainnya sesuai kebutuhan
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History Absensi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
        ),
        child: ListView.builder(
          itemCount: absensiList.length,
          itemBuilder: (context, index) {
            final absensi = absensiList[index];
            return InkWell(
              onTap: () => _showDetailPopup(context, absensi),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(absensi.foto),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            absensi.nama,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(absensi.jabatan),
                          SizedBox(height: 4),
                          Text('${absensi.hari}, ${absensi.tanggal}'),
                        ],
                      ),
                    ),
                    Text(
                      absensi.jam,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDetailPopup(BuildContext context, Absensi absensi) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Detail Absensi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nama: ${absensi.nama}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Jabatan: ${absensi.jabatan}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Hari: ${absensi.hari}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Tanggal: ${absensi.tanggal}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Jam: ${absensi.jam}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Tutup',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
