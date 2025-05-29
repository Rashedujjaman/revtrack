import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:revtrack/models/business_model.dart';
import 'package:revtrack/services/business_service.dart';

class EditBusinessBottomSheet extends StatefulWidget {
  final Business business;

  const EditBusinessBottomSheet({Key? key, required this.business})
      : super(key: key);

  @override
  State<EditBusinessBottomSheet> createState() =>
      _EditBusinessBottomSheetState();
}

class _EditBusinessBottomSheetState extends State<EditBusinessBottomSheet> {
  final TextEditingController _businessNameController = TextEditingController();
  File? _imageFile;
  String imageUrl = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    imageUrl = widget.business.logoUrl;
    _businessNameController.text = widget.business.name;
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {}
  }

  Future<void> _updateBusiness(businessName, imageFile) async {
    final updatedName = businessName;
    setState(() {
      isLoading = true;
    });

    if (updatedName.isNotEmpty) {
      try {
        String finalLogoUrl = imageUrl;
        if (_imageFile != null) {
          finalLogoUrl = await BusinessService()
              .uploadImageToFirebase(_imageFile!, widget.business.id);
        }

        await BusinessService().updateBusiness(
          widget.business.id,
          updatedName,
          finalLogoUrl,
        );

        if (context.mounted) {
          Navigator.pop(context, {
            'name': updatedName,
            'logoUrl': finalLogoUrl,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Business updated successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating business: $e')),
          );
        }
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit Business',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.withAlpha(25),
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl) as ImageProvider
                            : null),
                    child: _imageFile == null && imageUrl.isEmpty
                        ? const Icon(Icons.business,
                            size: 50, color: Colors.grey)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () async {
                      await _pickImage();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        // color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(
                  labelText: 'Business Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              onPressed: _imageFile == null &&
                      _businessNameController.text.trim() ==
                          widget.business.name
                  ? null
                  : () async {
                      await _updateBusiness(
                        _businessNameController.text.trim(),
                        _imageFile,
                      );
                    },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Changes'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
