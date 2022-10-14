import 'package:flutter/material.dart';
import 'package:qr_scan_app/database/db.dart';
import 'package:qr_scan_app/models/qr_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'views/camera_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<QrData>> refresh() async {
    return await DatabaseHelper.instance.getQrDataList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const CameraView()),
            (route) => false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete all data'),
                    content:
                        const Text('Are you sure you want to delete all data?'),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: const Text('Delete'),
                        onPressed: () {
                          DatabaseHelper.instance.deleteAllQrData();
                          Navigator.pop(context);
                          setState(() {
                            refresh();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              },
            )
          ],
          title: const Text('QR Scanner'),
        ),
        body: FutureBuilder<List<QrData>>(
            future: refresh(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return snapshot.data!.isEmpty
                    ? Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('No Scanned Data!',
                              style: TextStyle(fontSize: 20)),
                          Text('Tap the camera to scan a QR code',
                              style: TextStyle(fontSize: 16)),
                        ],
                      ))
                    : ListView(
                        children: snapshot.data!.map((qrData) {
                          return Card(
                            child: ListTile(
                              title: Text(qrData.name),
                              subtitle: Text(qrData.createdAt),
                              leading: qrData.isUrl == 1
                                  ? IconButton(
                                      onPressed: () async {
                                        if (!await launch(qrData.name)) {
                                          SnackBar(
                                              content: Text(
                                                  'Could not launch $qrData.name!'));
                                        }
                                      },
                                      icon: const Icon(Icons.link))
                                  : IconButton(
                                      onPressed: () async {
                                        const url =
                                            'https://www.google.com/search?q=';
                                        if (await canLaunch(
                                            url + qrData.name)) {
                                          await launch(url + qrData.name);
                                        } else {
                                          SnackBar(
                                              content: Text(
                                                  'Could not launch $qrData.name!'));
                                        }
                                      },
                                      icon: const Icon(Icons.search)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => {
                                  DatabaseHelper.instance.deleteQrData(qrData),
                                  setState(() {}),
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      );
              }
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.large(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const CameraView(),
              ),
              (route) => false,
            );
          },
          child: const Icon(Icons.camera_alt),
        ),
      ),
    );
  }
}
