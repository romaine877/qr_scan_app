import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class CameraView extends StatefulWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  Barcode? res;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QRscanner');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          res != null
              ? Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      res?.code ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
              : const Expanded(
                  flex: 1,
                  child: Center(child: CircularProgressIndicator()),
                ),
        ],
      ),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      const ScaffoldMessenger(
          child: SnackBar(
        content: Text('Camera permission denied'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _onViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.first.then((scanData) {
      Navigator.pop(context);
       setState(() {
        res = scanData;
      });
    });
    
  }

  @override
  void dispose() {
    super.dispose();
  }
}
