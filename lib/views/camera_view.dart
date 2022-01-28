import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_scan_app/widgets/modal.dart';

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton.large(
            child: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
              
            },
            heroTag: null,
          ),
          FloatingActionButton.large(
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
      body: QRView(
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
    );
  }

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
    controller.scannedDataStream.first.then((scanData) {
      showModalBottomSheet(
          context: context,
          barrierColor: const Color(0x01000000),
          builder: (context) {
            return QrModal(qrData: scanData.code);
          });
      setState(() {
        res = scanData;
      });
      controller.pauseCamera();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
