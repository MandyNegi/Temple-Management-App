import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Handles real-time session tracking
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:temple/routes/route_helper.dart';
import 'package:temple/services/auth_service.dart'; // Handles background sign-out triggers
import 'package:temple/utils/colors.dart';
import 'package:temple/utils/dimensions.dart';
import 'package:temple/widget/big_text.dart';
import 'package:temple/widget/show_custom_snakbar.dart';
import 'package:temple/widget/small_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomeDrawer extends StatefulWidget {
  const CustomeDrawer({Key? key}) : super(key: key);

  @override
  State<CustomeDrawer> createState() => _CustomeDrawerState();
}

class _CustomeDrawerState extends State<CustomeDrawer> {
  String selectedItem = '2018-2019';
  final List<String> items = ['2018-2019', '2019-2020', '2020-2021', '2021-2022'];
  bool _hasInternet = false;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
  }

  Future<void> checkInternetConnection() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      setState(() {
        _hasInternet = false;
      });
    } else {
      setState(() {
        _hasInternet = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically safely resolve user email properties to calculate header avatars
    final currentUser = FirebaseAuth.instance.currentUser;
    final userEmail = currentUser?.email ?? "User";
    final userInitial = userEmail.isNotEmpty ? userEmail[0].toUpperCase() : "U";

    return Drawer(
      width: Dimensions.screenWidth / 1.20,
      backgroundColor: Colors.white, 
      child: Column(
        children: [
          // 1. MATERIAL HOMEPAGE MATCHING ORANGE HEADER
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ROW HOUSING INITIALS BADGE AND THE HEADER LOGOUT ACTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Text(
                        userInitial,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      onPressed: () async {
                        Get.back(); // Closes the active drawer menu
                        await AuthService.instance.signOut(); // Erases session tokens to gate the app
                      },
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      "JAGANNATH ",
                      style: TextStyle(
                        fontSize: Dimensions.font26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Mandir",
                      style: TextStyle(
                        fontSize: Dimensions.font26,
                        fontWeight: FontWeight.w900,
                        color: Colors.yellow, 
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Displays the active logged-in email string directly below the title layout
                Text(
                  userEmail,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // 2. SCROLLABLE NAVIGATION LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              children: [
                _buildDrawerItem(Icons.home_outlined, "Home", () {
                  Get.back();
                  Get.toNamed(RouteHelper.getInitial());
                }),
                _buildDrawerItem(Icons.library_books_outlined, "Books Management", () {
                  Get.toNamed(RouteHelper.getBooksDashboardPage());
                }),
                _buildDrawerItem(Icons.volunteer_activism_outlined, "Sewa Management", () {
                  Get.toNamed(RouteHelper.getSewaDashboardPage());
                }),
                _buildDrawerItem(Icons.bookmarks_outlined, "Book A Pooja", () {
                  Get.toNamed(RouteHelper.getSlotBookPage());
                }),
                _buildDrawerItem(Icons.attach_money_outlined, "Donate", () {
                  Get.toNamed(RouteHelper.getDonationPage());
                }),
                _buildDrawerItem(Icons.description_outlined, "Circulars", () {
                  Get.toNamed(RouteHelper.getCircularPage());
                }),
                _buildDrawerItem(Icons.church_outlined, "About US", () {
                  Get.toNamed(RouteHelper.getAboutUsPage());
                }),
                _buildDrawerItem(Icons.phone_outlined, "Contact US", () {
                  Get.toNamed(RouteHelper.getContactUsPage());
                }),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Divider(color: Colors.black12, thickness: 1),
                ),

                // 3. MODERNIZED EXPENSES PANEL WITH SOFT ORANGE TINT BACKGROUND
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.06), 
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withOpacity(0.15), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.analytics_outlined, color: Colors.orange, size: 22),
                          SizedBox(width: 12),
                          Text(
                            "Temple Expenses",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Select Statement:",
                            style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedItem,
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
                                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13),
                                borderRadius: BorderRadius.circular(10),
                                items: items
                                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                                    .toList(),
                                onChanged: (item) async {
                                  await checkInternetConnection();
                                  if (_hasInternet) {
                                    setState(() {
                                      selectedItem = item!;
                                    });
                                    openFile(fileName: '$item.pdf');
                                  } else {
                                    showCustomSnakBar("Please Turn on Your Internet", title: "Attention");
                                  }
                                }),
                          ),
                      )],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. MATERIAL FLOATING STICKY ACTION FOOTER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.upload_file, size: 20),
                  label: const Text(
                    'Upload Statements',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: () async {
                    if (_hasInternet) {
                      final path = await FlutterDocumentPicker.openDocument();
                      if (path != null) {
                        File file = File(path);
                        await uploadFile(file);
                      }
                    } else {
                      showCustomSnakBar("Please Turn on Your Internet", title: "Attention");
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Material Navigation Item Builder
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: ListTile(
        horizontalTitleGap: 12,
        leading: Icon(icon, color: Colors.black54, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black54, 
            fontSize: 14, 
            fontWeight: FontWeight.w600,
          ),
        ),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        selectedTileColor: Colors.orange.withOpacity(0.1), 
        onTap: onTap,
      ),
    );
  }

  // SECURE STORAGE LOGIC ENGINES
  Future<void> openFile({required String fileName}) async {
    try {
      var status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        print('Permission not granted');
        return;
      }

      final file = await downloadFile(fileName);
      if (file == null) return;
      print("path:${file.path}");

      final result = await OpenFile.open(
        file.path,
        type: "application/pdf",
      );
      print('Open file result: ${result.type}, ${result.message}');
    } on Exception catch (e) {
      print(e.toString());
      debugPrint("error" + e.toString());
    }
  }

  Future<File?> downloadFile(String name) async {
    try {
      String url = await FirebaseStorage.instance.ref('files/$name').getDownloadURL();
      print("url:$url");
      final appStorage = await getApplicationDocumentsDirectory();
      final file = File('${appStorage.path}/$name');
      print("file:$file");

      final response = await Dio().get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      return file;
    } catch (e) {
      print(e.toString());
      debugPrint("error" + e.toString());
      return null;
    }
  }

  Future<UploadTask?> uploadFile(File file) async {
    Reference ref = FirebaseStorage.instance.ref().child('files/').child(
        '/${(file.path).replaceAll('/data/user/0/com.example.temple/cache/', '')}');

    final metadata = SettableMetadata(
        contentType: 'application/pdf', 
        customMetadata: {'picked-file-path': file.path});
    print("Uploading..!");

    UploadTask uploadTask = ref.putData(await file.readAsBytes(), metadata);
    print("done..!");

    return Future.value(uploadTask);
  }
}
