import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/helpers/picked_image_data.dart';

class SelfieCaptureWidget extends StatefulWidget {
  final ValueChanged<PickedImageData> onSelfieCaptured;

  const SelfieCaptureWidget({
    super.key,
    required this.onSelfieCaptured,
  });

  @override
  State<SelfieCaptureWidget> createState() => _SelfieCaptureWidgetState();
}

class _SelfieCaptureWidgetState extends State<SelfieCaptureWidget> {
  final ImagePicker _picker = ImagePicker();
  PickedImageData? _selfie;

  Future<void> _captureSelfie() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 85,
    );

    if (file == null) return;
    final bytes = await file.readAsBytes();
    final selfie = PickedImageData(fileName: file.name, bytes: bytes);
    setState(() => _selfie = selfie);
    widget.onSelfieCaptured(selfie);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selfie', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Use a câmera frontal para capturar a selfie.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Center(
              child: CircleAvatar(
                radius: 64,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _selfie == null ? null : MemoryImage(_selfie!.bytes),
                child: _selfie == null
                    ? const Icon(Icons.person, size: 48, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: OutlinedButton.icon(
                onPressed: _captureSelfie,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capturar selfie'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
