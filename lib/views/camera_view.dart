import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class CameraView extends StatefulWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  bool? _validURL;
  String? _scanResult;
  QRViewController? controller;
  int flexProperty = 2;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QRscanner');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
            heroTag: null,
          ),
          FloatingActionButton(
            child: FutureBuilder(
              future: controller?.getFlashStatus(),
              builder: (context, snapshot) => Icon(
                  snapshot.data == true ? Icons.flash_on : Icons.flash_off),
            ),
            onPressed: () async {
              await controller?.toggleFlash();
              setState(() {});
            },
            heroTag: null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.indigo,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.6,
              ),
              onPermissionSet: (control, permission) =>
                  _onPermissionSet(context, control, permission),
            ),
          ),
          _scanResult != null
              ? Expanded(
                  flex: flexProperty,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Center(
                        child: Text(_scanResult!, style: TextStyle(fontSize: 20)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _validURL != false
                                ? Column(
                                    children: [
                                      CircleAvatar(
                                        child: IconButton(
                                          icon: const Icon(Icons.link),
                                          onPressed: _launchURL,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text('Go to link'),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      CircleAvatar(
                                        child: IconButton(
                                            icon: const Icon(Icons.search),
                                            onPressed: _launchSearch),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text('Search'),
                                    ],
                                  ),
                            Column(
                              children: [
                                CircleAvatar(
                                  child: IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: () {
                                      setState(() {
                                        _scanResult = null;
                                        _validURL = null;
                                        controller?.resumeCamera();
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text('Scan Again'),
                              ],
                            ),
                            Column(
                              children: [
                                CircleAvatar(
                                  child: IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      Clipboard.setData(
                                          ClipboardData(text: _scanResult));
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text('Copy')
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              : Expanded(
                  flex: flexProperty,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
        ],
      ),
    );
  }

  void _launchSearch() async {
    const url = 'https://www.google.com/search?q=';
    if (await canLaunch(url + _scanResult!)) {
      await launch(url + _scanResult!);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchURL() async {
    if (!await launch(_scanResult!)){
      SnackBar(content: Text('Could not launch $_scanResult!'));
      setState(() {
        _validURL = false;
      
      });
      throw 'Could not launch $_scanResult!';
    }}
  

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      const ScaffoldMessenger(
          child: SnackBar(
        content: Text('Camera permissions denied'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _onViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        _scanResult = scanData.code;
        _validURL = Uri.parse(_scanResult!).isAbsolute;
        controller.pauseCamera();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
