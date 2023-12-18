import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home page.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Settings',style: TextStyle(color: Colors.black),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            ListTile(
              title: Text('Account Settings'),
              onTap: () {
                // Navigate to account settings page or perform action
                _navigateToAccountSettings(context);
              },
            ),
            // You can add more ListTile widgets for various settings
          ],
        ),
      ),
    );
  }

  void _navigateToAccountSettings(BuildContext context) {
    // Implement navigation to account settings page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountSettingsPage()),
    );
  }
}

// Add your AccountSettingsPage widget implementation here



