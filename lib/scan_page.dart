import 'dart:developer';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  late CameraDescription _firstCamera;
  final textRecognizer = TextRecognizer();
  bool _isProcessing = false;
  String _statusMessage = '';
  String _cardNumber = '';
  String _cardHolder = '';
  String _expiryDate = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      _firstCamera = _cameras.first;
      _cameraController = CameraController(_firstCamera, ResolutionPreset.high);

      await _cameraController!.initialize();
      _cameraController!.startImageStream(_processImage);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error initializing camera: $e';
      });
    }
  }

  void _processImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final inputImage = _convertCameraImageToInputImage(image);
      final recognizedText = await textRecognizer.processImage(inputImage);

      _cardNumber = '';
      _cardHolder = '';
      _expiryDate = '';

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final text = line.text.trim();

          if (RegExp(r'\d{4} \d{4} \d{4} \d{4}').hasMatch(text)) {
            _cardNumber = text;
          } else if (RegExp(r'[A-Za-z\s]+').hasMatch(text)) {
            _cardHolder = text;
          } else if (RegExp(r'\d{2}/\d{2}').hasMatch(text)) {
            _expiryDate = text;
          }
        }
      }

      if (_cardNumber.isNotEmpty && _cardHolder.isNotEmpty && _expiryDate.isNotEmpty) {
        _statusMessage = 'Card details extracted successfully.';
        _cameraController!.stopImageStream();
        _showSaveDialog();
      } else {
        _statusMessage = 'Could not extract all card details. Please try again.';
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error processing image: $e';
      });
    } finally {
      _isProcessing = false;
    }
  }

  InputImage _convertCameraImageToInputImage(CameraImage image) {
    final bytes = _convertYuv420ToImageBytes(image);

    final inputImageMetadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation0deg,
      format: InputImageFormat.yuv420,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: inputImageMetadata,
    );
  }

  Uint8List _convertYuv420ToImageBytes(CameraImage image) {
    final bytes = Uint8List(image.planes.fold<int>(
      0,
          (previousValue, plane) => previousValue + plane.bytes.length,
    ));

    int offset = 0;
    for (final plane in image.planes) {
      bytes.setRange(offset, offset + plane.bytes.length, plane.bytes);
      offset += plane.bytes.length;
    }

    return bytes;
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Text(
          'Card Information',
          style: TextStyle(
            color: Colors.blueGrey[800],
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Card Number:', _cardNumber),
            _buildInfoRow('Card Holder:', _cardHolder),
            _buildInfoRow('Expiry Date:', _expiryDate),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
            ),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;

              if (user != null && _cardNumber.isNotEmpty && _cardHolder.isNotEmpty && _expiryDate.isNotEmpty) {
                try {
                  // Reference to the user's document
                  final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

                  // Adding the card details to the 'creditCardSaved' array
                  await userDocRef.update({
                    'creditCardSaved': FieldValue.arrayUnion([
                      {
                        'cardNumber': _cardNumber,
                        'cardHolder': _cardHolder,
                        'expiryDate': _expiryDate,
                        'timestamp': Timestamp.now(), // Use Timestamp.now() instead of FieldValue.serverTimestamp()
                      }
                    ]),
                  });

                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Return to the previous screen
                } catch (e) {
                  setState(() {
                    _statusMessage = 'Error saving card information: $e';
                  });
                }
              } else {
                setState(() {
                  _statusMessage = 'Card details are incomplete.';
                });
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueGrey[800],
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Save Card',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blueGrey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Scan Credit Card'),
          backgroundColor: Colors.blueGrey[800],
        ),
        body: Center(
          child: _statusMessage.isNotEmpty
              ? Text(
            _statusMessage,
            style: TextStyle(color: Colors.redAccent, fontSize: 16),
          )
              : CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey[800]!),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Credit Card'),
        backgroundColor: Colors.blueGrey[800],
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Instructions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Align your credit card within the frame. Ensure the card is well-lit and the text is clear. Follow the guidelines to get accurate results.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.blueGrey[800],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey[800]!, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.5,
              child: Center(
                child: Text(
                  'Position your card within the frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          if (_statusMessage.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
