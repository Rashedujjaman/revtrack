import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:revtrack/models/business_model.dart';
import 'package:revtrack/services/business_service.dart';
import 'package:revtrack/services/snackbar_service.dart';

class BusinessBottomSheet extends StatefulWidget {
  final Business? business;
  final String userId;

  const BusinessBottomSheet({Key? key, this.business, required this.userId})
      : super(key: key);

  @override
  State<BusinessBottomSheet> createState() => _BusinessBottomSheetState();
}

class _BusinessBottomSheetState extends State<BusinessBottomSheet> {
  final TextEditingController _businessNameController = TextEditingController();
  File? _imageFile;
  String imageUrl = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.business != null) {
      // If businessId is provided, fetch the business details
      imageUrl = widget.business!.logoUrl ?? '';
      _businessNameController.text = widget.business!.name;
    }
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
    } catch (e) {
      if (context.mounted && mounted) {
        SnackbarService().errorMessage(
          context,
          'Error picking image: $e',
        );
      }
    }
  }

  Future<void> _saveBusiness() async {
    final businessName = _businessNameController.text.trim();

    if (businessName.isEmpty) {
      SnackbarService().errorMessage(
        context,
        'Business name cannot be empty',
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (widget.business == null) {
        // Adding new business
        String logoUrl = '';
        if (_imageFile != null) {
          logoUrl = await BusinessService()
              .uploadImageToFirebase(_imageFile!, widget.userId);
        }

        await BusinessService()
            .addBusiness(widget.userId, businessName, logoUrl);

        if (mounted) {
          Navigator.pop(context);
          SnackbarService().successMessage(
            context,
            'Business added successfully',
          );
        }
      } else {
        // Editing existing business
        String finalLogoUrl = imageUrl;
        if (_imageFile != null) {
          finalLogoUrl = await BusinessService()
              .uploadImageToFirebase(_imageFile!, widget.business!.id);
        }

        await BusinessService().updateBusiness(
          widget.business!.id,
          businessName,
          finalLogoUrl,
        );

        if (mounted) {
          Navigator.pop(context, {
            'name': businessName,
            'logoUrl': finalLogoUrl,
          });
          SnackbarService().successMessage(
            context,
            'Business updated successfully',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarService().errorMessage(
          context,
          'Error: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
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
            Text(
              widget.business == null ? 'Add Business' : 'Edit Business',
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
                    onTap: _pickImage,
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
              onPressed: isLoading ? null : () => _saveBusiness(),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Text(widget.business == null
                      ? 'Add Business'
                      : 'Save Changes'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
