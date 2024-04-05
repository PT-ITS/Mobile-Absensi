import 'package:flutter/material.dart';
import 'package:mobile_absensi/states/auth_state.dart';
import 'package:provider/provider.dart';

class ProfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text(
            'Profil',
            style: TextStyle(fontSize: 20),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bagian pertama
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          NetworkImage('https://via.placeholder.com/150'),
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bagus Untoro',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        SizedBox(height: 10),
                        Text(
                          authState.levelUser == '0' ? 'User' : 'Admin',
                          style: TextStyle(fontSize: 15, color: Colors.black),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 30),

                // Bagian kedua
                Card(
                  elevation: 3,
                  color: Colors.red,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildProfileItem('Email',
                            authState.emailUser.toString(), Icons.email),
                        SizedBox(height: 10),
                        buildProfileItem(
                            'Nomor Telepon', '08123456789', Icons.phone),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Bagian ketiga
                Card(
                  elevation: 3,
                  color: Colors.red,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InkWell(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => AkunPage(),
                            //   ),
                            // );
                          },
                          child: buildProfileItemWithIcon(
                              'Informasi Akun', Icons.info_outline),
                        ),
                        SizedBox(height: 10),
                        buildProfileItemWithIcon(
                            'Ubah Password', Icons.lock_outline),
                        SizedBox(height: 10),
                        buildProfileItemWithIcon('FAQ', Icons.help_outline),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Bagian keempat
                Card(
                  elevation: 3,
                  color: Colors.red,
                  child: ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Log Out',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget buildProfileItem(String title, String subtitle, IconData icon) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white),
      ),
      // trailing: Icon(
      //   Icons.arrow_forward_ios,
      //   color: Colors.white,
      // ),
      leading: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }

  Widget buildProfileItemWithIcon(String title, IconData icon) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.white,
      ),
    );
  }
}
