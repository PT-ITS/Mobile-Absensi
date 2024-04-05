import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mobile_absensi/admin/menu.dart';
// import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:location/location.dart' as location_package;
import 'package:flutter/services.dart';

import '../components/loadingComponent.dart';
import '../components/mapView.dart';
import '../location/location_service.dart';
import '../location/user_location.dart';
// import '../states/auth_state.dart';
// import 'absen_state.dart';

class AbsenPage extends StatefulWidget {
  @override
  _AbsenPageState createState() => _AbsenPageState();
}

class _AbsenPageState extends State<AbsenPage> {
  location_package.Location location = location_package.Location();
  LocationService locationService = LocationService();
  String? selectedCondition = 'semangat';
  final descriptionController = TextEditingController();
  File? imageFile = null;
  double? distanceToKantor;
  String? koordinatUser;
  String? alamatLengkap;
  DateTime? dateTime;
  bool isLoading = false;
  bool valid = false;
  bool fake = false;
  bool devOpt = false;
  late Timer timer;
  static const platform = MethodChannel('developer_mode');
  bool devMod = false;

  @override
  void dispose() {
    locationService.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fakeGpsDetection();
    isDeveloperModeEnabled();
  }

  Future<void> isDeveloperModeEnabled() async {
    try {
      final bool result = await platform.invokeMethod('isDeveloperModeEnabled');
      if (result) {
        _showErrorDialog('Fake GPS Detection',
            'Garamina mobile tidak mengizinkan anda menghidupkan opsi developer!!!');
      }
      setState(() {
        devMod = result;
      });
    } on PlatformException catch (e) {
      print("Error: '${e.message}'.");
    }
  }

  Future<void> fakeGpsDetection() async {
    if (await location.hasPermission() !=
        location_package.PermissionStatus.granted) {
      print("Izin lokasi tidak diberikan. Mungkin menggunakan fake GPS.");
      return;
    }

    double lastLat = 0.0;
    double lastLon = 0.0;
    location.onLocationChanged.listen((locationData) {
      if (lastLat != 0.0 && lastLon != 0.0) {
        handleLocationUpdate(lastLat, lastLon, locationData);
      }
      lastLat = locationData.latitude ?? 0.0;
      lastLon = locationData.longitude ?? 0.0;
    });
    print("Tidak terdeteksi adanya fake GPS.");
  }

  void handleLocationUpdate(double lastLat, double lastLon,
      location_package.LocationData locationData) {
    double distance = calculateDistance(lastLat, lastLon,
        locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
    if (distance > 1.0) {
      setState(() {
        fake = true;
      });
      print("Perpindahan lokasi mencurigakan. Mungkin menggunakan fake GPS.");
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const int earthRadius = 6371; // Radius dalam km
    final latDistance = (lat2 - lat1).abs();
    final lonDistance = (lon2 - lon1).abs();
    final distance = sqrt(pow(latDistance, 2) + pow(lonDistance, 2)) *
        (earthRadius * pi / 180);
    return distance;
  }

  Future<void> getAddress(latitude, longitude) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      final Placemark placemark = placemarks[0];
      final String alamat = placemark.street ?? '';
      final String kota = placemark.locality ?? '';
      final String provinsi = placemark.administrativeArea ?? '';
      alamatLengkap = '$alamat, $kota, $provinsi';

      setState(() {});
    } catch (e) {
      print('Kesalahan saat mengambil alamat: $e');
    }
  }

  Future<void> updateStatusEmergency(idPeg, checkStatus, checkShiftM) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://ptgaram.com/api/status_absen_emergency/insert_status_absen'),
        headers: {
          'APIKEY': '8deca313c70c6195eba4208b8dc6d56b',
        },
        body: {
          'idPeg': idPeg.toString(),
          'checkStatus': checkStatus.toString(),
          'checkShiftM': checkShiftM.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    // final authState = Provider.of<AuthState>(context);
    // final absenState = Provider.of<AbsenState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Absen'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // buildUserGuide(context),
              // buildInformationCenter(context),
            ],
          ),
        ],
      ),
      body: isLoading == true
          ? LoadingComponent()
          : SingleChildScrollView(
              child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  StreamBuilder<UserLocation>(
                    stream: locationService.locationStream,
                    builder: (_, snapshot) {
                      if (snapshot.hasData) {
                        final userLocation = snapshot.data!;
                        koordinatUser =
                            '${userLocation.latitude},${userLocation.longitude}';
                        final kantorLocation = '7827348732843284';
                        final kantorCoordinates = LatLng(
                          double.parse(kantorLocation.split(',')[0]),
                          double.parse(kantorLocation.split(',')[1]),
                        );

                        final lat1 = userLocation.latitude;
                        final lon1 = userLocation.longitude;
                        final lat2 = kantorCoordinates.latitude;
                        final lon2 = kantorCoordinates.longitude;
                        distanceToKantor =
                            calculateDistance(lat1, lon1, lat2, lon2);
                        getAddress(
                            userLocation.latitude, userLocation.longitude);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            if (devMod)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  'Garamina Mobile melarang anda mengaktifkan developer mode!!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            if (fake)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  'Anda menggunakan fake GPS!!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red[900],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                "Anda belum bisa absen!",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            MapsView(
                              kantorCoordinates: kantorCoordinates,
                              userLocation: userLocation,
                            )
                          ],
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  imageFile != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (imageFile != null)
                              Image.file(
                                imageFile!,
                                height: 200,
                                width: 150,
                                fit: BoxFit.cover,
                              ),
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _getImageFromCamera();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              primary: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.camera),
                            label: const Text(
                              'Ambil gambar',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Deskripsi:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan deskripsi pekerjaan',
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Kondisi Saat Ini:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        children: <Widget>[
                          _buildConditionBox('Semangat😎', 'semangat'),
                          _buildConditionBox('Sedih😭', 'sedih'),
                          _buildConditionBox('Gembira😆', 'gembira'),
                          _buildConditionBox('Tertekan😥', 'tertekan'),
                          _buildConditionBox('Nyaman😊', 'nyaman'),
                          _buildConditionBox('Boring😶', 'boring'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          primary: Colors.blue),
                      child: Text(
                        'Masuk',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
    );
  }

  void _getImageFromCamera() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        valid = true;
      });
    }
  }

  void _saveAbsenData(
    status,
    empId,
    note,
    foto,
    shift,
    condition,
    nama,
    checkStatusPegawai,
    checkStatusSPPD,
    checkStatusDetasering,
    checkShiftM,
  ) async {
    fakeGpsDetection();

    if (fake == true || devMod == true) {
      _showErrorDialog('Fake GPS Detection',
          'Maaf, Anda tidak dapat melakukan absen karena perangkat Anda terdeteksi menggunakan Fake GPS.');
      return;
    }

    if (!valid || descriptionController.text.isEmpty) {
      _showErrorDialog('Data Tidak Lengkap',
          'Maaf, Anda tidak dapat melakukan absen karena anda belum melengkapi data.');
      return;
    }

    if (distanceToKantor! <= 0.05 ||
        checkStatusPegawai == 'true' ||
        checkStatusSPPD == 'true' ||
        checkStatusDetasering == 'true') {
      _accessAPI(
          status, empId.toString(), note, condition, foto, nama, checkShiftM);
    } else {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Anda berada di luar kantor!!',
          'Maaf, Anda tidak dapat melakukan absen karena lokasi Anda di luar jangkauan.');
    }
  }

  void _accessAPI(
      status, empId, note, condition, foto, nama, checkShiftM) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime dateTime = DateTime.now();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://garamina.com/fintech2/integrasi/android/insert_absen/login'),
    );

    request.headers['APIKEY'] = '8deca313c70c6195eba4208b8dc6d56b';
    request.fields['status'] = checkShiftM == true
        ? 'out_morning'
        : status == '0-0'
            ? 'in'
            : 'out';
    request.fields['empId'] = empId;
    request.fields['shift'] = 'A';
    request.fields['note'] = note.text;
    request.fields['koordinat'] = koordinatUser!;
    request.fields['datetime'] = dateTime.toIso8601String();
    request.fields['emoticon'] = condition;
    request.fields['jarak'] = '0.0';
    request.fields['alamat'] = alamatLengkap ?? '';

    final currentTime = TimeOfDay.fromDateTime(dateTime);
    const targetTime = TimeOfDay(hour: 18, minute: 0);

    if (currentTime.hour > targetTime.hour ||
        (currentTime.hour == targetTime.hour &&
            currentTime.minute > targetTime.minute)) {
      if (status == '0-0') {
        await prefs.setString('checkShiftM', 'true');
        print("out_morning");
      }
    }

    final image = img.decodeImage(File(foto.path).readAsBytesSync());
    const desiredWidth = 400;
    const desiredHeight = 300;
    final resizedImage =
        img.copyResize(image!, width: desiredWidth, height: desiredHeight);
    final compressedFile = File(foto.path)
      ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 60));
    final mimeTypeData =
        lookupMimeType(compressedFile.path, headerBytes: [0xFF, 0xD8]);
    final file = await http.MultipartFile.fromPath('foto', compressedFile.path,
        contentType: MediaType.parse(mimeTypeData!));

    request.files.add(file);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final parsedData = json.decode(responseData);
      print(parsedData);

      if (parsedData['status'] == true) {
        _showSuccessDialog(
            nama,
            status,
            condition,
            koordinatUser!,
            alamatLengkap!,
            parsedData['tanggal'],
            parsedData['waktu'],
            parsedData['foto'],
            parsedData['judul'],
            parsedData['slogan']);
        if (status == '0-0') {
          updateStatusEmergency(empId, 'A-', checkShiftM);
        } else if (status == 'A-') {
          updateStatusEmergency(empId, 'A-A', checkShiftM);
        }
        setState(() {
          imageFile = null;
          descriptionController.clear();
          selectedCondition = 'Semangat';
        });
      } else {
        throw Exception('Gagal: ${parsedData['msg']}');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception(
          'Gagal: Terjadi kesalahan saat melakukan absen. Silakan coba lagi.');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MenuAdmin(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
    setState(() {
      isLoading = false;
      imageFile = null;
      descriptionController.clear();
      selectedCondition = 'Semangat';
    });
  }

  void _showSuccessDialog(String nama, String status, String condition,
      String koordinat, String alamat, tanggal, waktu, foto, judul, slogan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$judul'),
          content: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (foto != null)
                    Image.network(
                      'https://garamina.com/erp/assets/upload/$foto',
                      width: 200,
                      height: 200,
                    )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text('Nama: $nama'),
                  Text('Absen: ${status == '0-0' ? 'Masuk' : 'Pulang'}'),
                  Text('Tanggal: ${tanggal.toString()}'),
                  Text('Jam: ${waktu.toString()}'),
                  Text('Kondisi: $condition'),
                  Text('Alamat: $alamat'),
                  Text('Slogan: $slogan'),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MenuAdmin(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildConditionBox(String condition, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCondition = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedCondition == value ? Colors.blue : Colors.grey,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          condition,
          style: TextStyle(
            fontSize: 16,
            color: selectedCondition == value ? Colors.blue : Colors.black,
          ),
        ),
      ),
    );
  }
}
