import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../providers/auth_provider.dart';
import 'approval_status_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup';

  final bool isEditMode;

  const SignupScreen({super.key, this.isEditMode = false});

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
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.isEditMode && !_isInitialized) {
      final seller =
          Provider.of<AuthProvider>(context, listen: false).currentSeller;

      if (seller != null) {
        _sellerNameController.text = seller.sellerName;
        _emailController.text = seller.email;
        _businessNameController.text = seller.businessName;
        _businessAddressController.text = seller.businessAddress;
        _phoneController.text = seller.phone;
        _gstNumberController.text = seller.gstNumber;
        _aadharNumberController.text = seller.aadharNumber;
      }

      _isInitialized = true;
    }
  }

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!widget.isEditMode &&
        (_selfieImage == null ||
            _aadharFrontImage == null ||
            _aadharBackImage == null ||
            _gstCertificateImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();

      if (widget.isEditMode) {
        await authProvider.updateSellerAndResubmit(
          sellerName: _sellerNameController.text.trim(),
          businessName: _businessNameController.text.trim(),
          businessAddress: _businessAddressController.text.trim(),
          phone: _phoneController.text.trim(),
          gstNumber: _gstNumberController.text.trim(),
          aadharNumber: _aadharNumberController.text.trim(),
          selfieImage: _selfieImage,
          aadharFrontImage: _aadharFrontImage,
          aadharBackImage: _aadharBackImage,
          gstCertificateImage: _gstCertificateImage,
        );
      } else {
        await authProvider.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          sellerName: _sellerNameController.text.trim(),
          businessName: _businessNameController.text.trim(),
          businessAddress: _businessAddressController.text.trim(),
          phone: _phoneController.text.trim(),
          gstNumber: _gstNumberController.text.trim(),
          aadharNumber: _aadharNumberController.text.trim(),
          selfieImage: _selfieImage!,
          aadharFrontImage: _aadharFrontImage!,
          aadharBackImage: _aadharBackImage!,
          gstCertificateImage: _gstCertificateImage!,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditMode
              ? "Profile updated & sent for re-approval ✅"
              : "Account submitted for approval ✅"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const ApprovalStatusScreen(),
        ),
            (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceAll('Exception: ', '')),
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
    final isLoading =
        context.watch<AuthProvider>().isLoading || _isSubmitting;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                Text(
                  widget.isEditMode
                      ? "Update Your Details"
                      : "Create Seller Account",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                _buildTextField(_sellerNameController, 'Full Name'),
                _buildTextField(_emailController, 'Email',
                    enabled: !widget.isEditMode,
                    keyboard: TextInputType.emailAddress),

                if (!widget.isEditMode)
                  _buildTextField(_passwordController, 'Password',
                      obscure: true),

                _buildTextField(_businessNameController, 'Business Name'),
                _buildTextField(_businessAddressController,
                    'Business Address',
                    maxLines: 3),
                _buildTextField(_phoneController, 'Phone Number',
                    keyboard: TextInputType.phone),
                _buildTextField(_gstNumberController, 'GST Number'),
                _buildTextField(_aadharNumberController, 'Aadhar Number'),

                const SizedBox(height: 30),

                const Text(
                  "Required Documents",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildUploadTile("Upload Selfie", "selfie"),
                _buildUploadTile("Upload Aadhar Front", "aadharFront"),
                _buildUploadTile("Upload Aadhar Back", "aadharBack"),
                _buildUploadTile("Upload GST Certificate", "gst"),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    padding:
                    const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(8)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                      color: Colors.white)
                      : Text(
                    widget.isEditMode
                        ? 'Update & Re-Submit'
                        : 'Submit for Approval',
                    style: const TextStyle(
                        fontSize: 16, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20),

                if (!widget.isEditMode)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadTile(String title, String type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _pickImage(type),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.upload_file),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
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
        bool enabled = true,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        maxLines: maxLines,
        enabled: enabled,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (label == 'Password' && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }
}