import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImageDialog extends StatefulWidget {
  @override
  _UploadImageDialogState createState() => _UploadImageDialogState();
}

class _UploadImageDialogState extends State<UploadImageDialog> {
  ImagePicker imagePicker = ImagePicker();
  late XFile  imageFile;

  void _openGallery(BuildContext context) async {
    var picture = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = picture!;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 5,
      child: Container(
        height: 150,
        width: 350,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10.0, top: 10),
              child: Text(
                "Upload Image",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                "Select a Photo..",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "CANCEL",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async{

                  },
                  child: const Text(
                    "GALLERY",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text(
                    "CAMERA",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
