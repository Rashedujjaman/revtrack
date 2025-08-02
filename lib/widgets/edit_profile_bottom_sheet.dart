import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:revtrack/models/user_model.dart';
import 'package:revtrack/services/firebase_service.dart';
import 'package:revtrack/services/snackbar_service.dart';

/// Profile editing bottom sheet with image upload functionality
/// 
/// Features:
/// - User profile photo upload with size validation (max 2MB)
/// - Form validation for required fields (first name, phone number)
/// - Bangladeshi phone number format validation (01XXXXXXXXX)
/// - Read-only email field (cannot be changed)
/// - Image picker integration with gallery selection
/// - Loading states during profile update operations
/// - Firebase Storage integration for profile image upload
/// - Responsive design with keyboard-aware scrolling
/// - Material Design 3 compliance with proper theming
class EditProfileBottomSheet extends StatefulWidget {
  final UserModel user;

  /// Creates a profile editing bottom sheet
  /// 
  /// Parameters:
  /// - [user]: UserModel containing current user profile data
  const EditProfileBottomSheet({Key? key, required this.user})
      : super(key: key);

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

/// Stateful widget implementation with form state and image management
class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// Convenience getter for accessing user data
  get user => widget.user;

  // Image handling state
  File? _imageFile;           // Selected image file from gallery
  String imageUrl = '';       // Current profile image URL
  bool isLoading = false;     // Loading state for save operation

  @override
  void initState() {
    super.initState();
    // Populate form fields with existing user data
    _firstNameController.text = widget.user.firstName;
    _lastNameController.text = widget.user.lastName ?? '';
    _emailController.text = widget.user.email ?? '';
    _phoneNumberController.text = widget.user.phoneNumber ?? '';
    imageUrl = widget.user.imageUrl ?? '';
  }

  /// Validates Bangladeshi phone number format (01XXXXXXXXX)
  /// 
  /// Parameters:
  /// - [value]: Phone number string to validate
  /// 
  /// Returns: true if format matches 01 followed by 8-9 digits
  bool isValidPhoneNumber(String value) {
    final RegExp regex = RegExp(r"^01[0-9]{8,9}$");
    return regex.hasMatch(value);
  }

  /// Handles profile image selection from device gallery
  /// 
  /// Features:
  /// - Image size validation (max 2MB)
  /// - Error dialog for oversized images
  /// - Gallery source selection via ImagePicker
  /// - Comprehensive error handling with user feedback
  /// 
  /// Shows error dialog if selected image exceeds 2MB limit.
  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes = await file.length();
        if (bytes > 2 * 1024 * 1024) {
          if (context.mounted && mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.red,
                title: const Text('Image Size Error',
                    style: TextStyle(color: Colors.white)),
                content: const Text('Please select an image smaller than 2MB.',
                    style: TextStyle(color: Colors.white)),
                actions: [
                  TextButton(
                    autofocus: true,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }
          return;
        }
        setState(() {
          _imageFile = file;
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

  /// Saves profile changes to Firebase with image upload
  /// 
  /// Process:
  /// 1. Validates form fields using form key
  /// 2. Uploads new image to Firebase Storage if selected
  /// 3. Updates user profile through FirebaseService
  /// 4. Returns updated user data to parent widget
  /// 5. Shows success/error feedback to user
  /// 
  /// Handles loading states and comprehensive error management.
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        UserModel updatedUser = UserModel(
          uid: user.uid,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: user.email,
          phoneNumber: _phoneNumberController.text.trim(),
          imageUrl: _imageFile != null
              ? await FirebaseService()
                  .uploadImageToFirebase(_imageFile!, widget.user.uid)
              : user.imageUrl,
        );

        await FirebaseService().updateUserProfile(
          updatedUser,
        );

        if (mounted) {
          Navigator.pop(context, {updatedUser});
          SnackbarService().successMessage(
            context,
            'Profile updated successfully',
          );
        }
      } catch (e) {
        if (mounted) {
          SnackbarService().errorMessage(
            context,
            'Error: ${e.toString()}',
          );
        }
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
    setState(() => isLoading = false);
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
            Text('Edit Profile', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 3),
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
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
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
                      child: const Icon(Icons.camera_alt, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone number is required';
                      } else if (value.isNotEmpty &&
                          !isValidPhoneNumber(value)) {
                        return 'Invalid phone number format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    readOnly: true,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              onPressed: isLoading ? null : _saveProfile,
              child: isLoading
                  ? const CircularProgressIndicator(
                      padding: EdgeInsets.symmetric(horizontal: 8))
                  : const Text('Save Changes'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
