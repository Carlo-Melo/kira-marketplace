import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/helpers/picked_image_data.dart';

class ImagePickerWidget extends StatefulWidget {
  final String title;
  final String helperText;
  final ValueChanged<PickedImageData> onImagePicked;

  const ImagePickerWidget({
    super.key,
    required this.title,
    required this.helperText,
    required this.onImagePicked,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  PickedImageData? _image;

  Future<void> _pickFromGallery() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final image = PickedImageData(fileName: file.name, bytes: bytes);
    setState(() => _image = image);
    widget.onImagePicked(image);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(widget.helperText, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  _image!.bytes,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                alignment: Alignment.center,
                child: const Text('Nenhuma imagem selecionada'),
              ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.upload_file),
              label: const Text('Selecionar imagem'),
            ),
          ],
        ),
      ),
    );
  }
}
