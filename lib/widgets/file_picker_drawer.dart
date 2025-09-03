import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';


class FilePickerDrawer extends StatefulWidget {
  final Function(String path) onFilePicked;

  const FilePickerDrawer({super.key, required this.onFilePicked});

  @override
  State<FilePickerDrawer> createState() => _FilePickerDrawerState();
}

class _FilePickerDrawerState extends State<FilePickerDrawer> {
  Future<void> _checkAndPickFile() async {
  final androidInfo = await DeviceInfoPlugin().androidInfo;
  final sdkInt = androidInfo.version.sdkInt;

  bool granted = false;

  if (sdkInt >= 33) {
    // Android 13+
    final status = await Permission.photos.request(); // or Permission.mediaLibrary
    granted = status.isGranted;
  } else {
    final status = await Permission.storage.request();
    granted = status.isGranted;
  }

  if (granted) {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      widget.onFilePicked(result.files.single.path!);
    }
  } else {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Permission denied to access files")),
    );
  }
}


  Future<void> _captureFromCamera() async {
    PermissionStatus status = await Permission.camera.request();
    if (status.isGranted) {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        widget.onFilePicked(pickedFile.path);
      }
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission denied")),
      );
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Upload from Library'),
              onTap: () {
                Navigator.pop(context);
                _checkAndPickFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Live Capture'),
              onTap: () {
                Navigator.pop(context);
                _captureFromCamera();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.attach_file),
      label: const Text("Choose File"),
      onPressed: () => _showBottomSheet(context),
    );
  }
}
