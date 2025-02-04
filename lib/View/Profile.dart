import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  String userName = "";
  String email = "";
  String status = "";
  String userType = "";
  int companyId = 0;
  File? profileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    userName = await secureStorage.read(key: "User_Name") ?? "N/A";
    email = await secureStorage.read(key: "Email") ?? "N/A";
    status = await secureStorage.read(key: "Status") ?? "N/A";
    userType = await secureStorage.read(key: "User_Type") ?? "N/A";
    companyId = int.tryParse(await secureStorage.read(key: "Company_Id") ?? "0") ?? 0;

    String? profileImagePath = await secureStorage.read(key: "Profile_Image");
    if (profileImagePath != null) {
      profileImage = File(profileImagePath);
    }

    setState(() {});
  }



  Future<void> _pickImage() async {
    // Request photo permission dynamically
    PermissionStatus status = await Permission.photos.status;

    if (status.isDenied) {
      // Request permission if it's not granted
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      // Permission granted, proceed with picking the image
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          profileImage = File(pickedFile.path);
        });
        await secureStorage.write(key: "Profile_Image", value: pickedFile.path);
      }
    } else if (status.isPermanentlyDenied) {
      // Show a dialog or navigate to settings
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Permission Required"),
          content: const Text(
              "The app needs access to your photos to set a profile picture. Please enable the permission in settings."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );
    } else {
      // Permission denied, show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permission denied. Unable to pick image."),
        ),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
            AppLocalizations.of(context, 'Profile'),

          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            GestureDetector(
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 40,
                child: Icon(
                  Icons.person,
                  color: Colors.black,
                  size: 60.0, // Adjust the size as needed


                ),
           ),
            ),
            const SizedBox(height: 20),
            SelectableText(
              userName,

              style: const TextStyle(

                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            SelectableText(
              email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Card(
                elevation: 10,
                surfaceTintColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileRow("Status", status),
                      _buildProfileRow("User Type", userType),
                      _buildProfileRow("Company ID", companyId.toString()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
