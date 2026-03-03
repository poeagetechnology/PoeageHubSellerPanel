import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup';

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _sellerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _aadharNumberController = TextEditingController();

  dynamic _selfieImage;
  dynamic _aadharFrontImage;
  dynamic _aadharBackImage;
  dynamic _gstCertificateImage;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _sellerNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _phoneController.dispose();
    _gstNumberController.dispose();
    _aadharNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      switch (type) {
        case 'selfie':
          _selfieImage = kIsWeb ? image : File(image.path);
          break;
        case 'aadharFront':
          _aadharFrontImage = kIsWeb ? image : File(image.path);
          break;
        case 'aadharBack':
          _aadharBackImage = kIsWeb ? image : File(image.path);
          break;
        case 'gst':
          _gstCertificateImage = kIsWeb ? image : File(image.path);
          break;
      }
    });
  }

  Widget _buildImageUploadButton(
      String label, dynamic image, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
              color: image == null
                  ? Colors.grey.shade400
                  : Colors.green),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              image == null
                  ? Icons.upload_file
                  : Icons.check_circle,
              color:
              image == null ? Colors.grey : Colors.green,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                image == null ? label : "$label ✓",
                style: TextStyle(
                  color: image == null
                      ? Colors.grey[700]
                      : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selfieImage == null ||
        _aadharFrontImage == null ||
        _aadharBackImage == null ||
        _gstCertificateImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text('Please upload all required documents')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthProvider>().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        sellerName: _sellerNameController.text.trim(),
        businessName:
        _businessNameController.text.trim(),
        businessAddress:
        _businessAddressController.text.trim(),
        phone: _phoneController.text.trim(),
        gstNumber: _gstNumberController.text.trim(),
        aadharNumber:
        _aadharNumberController.text.trim(),
        selfieImage: _selfieImage!,
        aadharFrontImage: _aadharFrontImage!,
        aadharBackImage: _aadharBackImage!,
        gstCertificateImage:
        _gstCertificateImage!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text("Account submitted for approval ✅"),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(
          const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.of(context)
          .pushReplacementNamed('/waiting');
    } catch (error) {
      if (!mounted) return;

      String message = error.toString();

      if (message.contains('email-already-in-use')) {
        message = "Email already in use.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerLoading =
        context.watch<AuthProvider>().isLoading;

    final isLoading = providerLoading || _isSubmitting;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Create Seller Account',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                _buildTextField(
                    _sellerNameController, 'Full Name'),
                _buildTextField(
                    _emailController, 'Email',
                    keyboard:
                    TextInputType.emailAddress),
                _buildTextField(
                    _passwordController, 'Password',
                    obscure: true),
                _buildTextField(
                    _businessNameController,
                    'Business Name'),
                _buildTextField(
                    _businessAddressController,
                    'Business Address',
                    maxLines: 3),
                _buildTextField(
                    _phoneController, 'Phone Number',
                    keyboard: TextInputType.phone),
                _buildTextField(
                    _gstNumberController, 'GST Number'),
                _buildTextField(
                    _aadharNumberController,
                    'Aadhar Number'),

                const SizedBox(height: 24),
                const Text(
                  'Required Documents',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildImageUploadButton(
                    'Upload Selfie',
                    _selfieImage,
                        () => _pickImage('selfie')),
                const SizedBox(height: 12),

                _buildImageUploadButton(
                    'Upload Aadhar Front',
                    _aadharFrontImage,
                        () => _pickImage(
                        'aadharFront')),
                const SizedBox(height: 12),

                _buildImageUploadButton(
                    'Upload Aadhar Back',
                    _aadharBackImage,
                        () => _pickImage(
                        'aadharBack')),
                const SizedBox(height: 12),

                _buildImageUploadButton(
                    'Upload GST Certificate',
                    _gstCertificateImage,
                        () => _pickImage('gst')),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed:
                  isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF1F2937),
                    padding:
                    const EdgeInsets.symmetric(
                        vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(8)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                      color: Colors.white)
                      : const Text(
                    'Submit for Approval',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(),
                  child: const Text(
                      'Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool obscure = false,
        int maxLines = 1,
        TextInputType keyboard = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }

          if (label == 'Password' &&
              value.length < 6) {
            return 'Password must be at least 6 characters';
          }

          return null;
        },
      ),
    );
  }
}