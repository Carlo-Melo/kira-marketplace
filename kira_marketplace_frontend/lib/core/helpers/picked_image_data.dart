import 'dart:typed_data';

class PickedImageData {
  final String fileName;
  final Uint8List bytes;

  const PickedImageData({
    required this.fileName,
    required this.bytes,
  });
}
