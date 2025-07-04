import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_fit/core/network/local/cache_helper.dart';
import 'package:dr_fit/core/shared/about_images.dart';
import 'package:dr_fit/features/storage/data/repo_imp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dr_fit/core/utils/component.dart';
import 'package:dr_fit/core/utils/constants.dart';
import 'package:dr_fit/core/utils/context_extension.dart';
import 'package:dr_fit/features/layout/presentation/screens/layout.dart';

class InformationScreen extends StatefulWidget {
  final double weight, height;
  const InformationScreen(
      {super.key, required this.height, required this.weight});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final formKey = GlobalKey<FormState>();
  final firebase = FirebaseFirestore.instance;
  final firebaseAuth = FirebaseAuth.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  File? _selectedImage;
  final storageRepo = UploadProfileImageStorageRepoImp();

  // Function to pick an image
  Future<void> pickImage() async {
    File? image = await ImageServices.pickImage();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // Function to upload image and save user data
  Future<void> saveUserData() async {
    if (!formKey.currentState!.validate()) return;

    try {
      String? uid = firebaseAuth.currentUser?.uid;
      if (uid == null) {
        print('❌ No authenticated user found');
        return;
      }

      // Upload image if selected
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl =
            await storageRepo.uploadToStorage(name: uid, file: _selectedImage!);
      }
      // Save user data to Firestore
      await firebase.collection('users').doc(uid).set({
        'uid': uid,
        'name': nameController.text.trim(),
        'height': widget.height,
        'weight': widget.weight,
        'age': ageController.text.trim(),
        'phone': phoneController.text.trim(),
        'img': imageUrl ?? '', // Save image URL or empty string if no image
      });
      print('✅ User data saved successfully');
      CacheHelper.setData(key: 'dataSaved', value: true);
      print('${CacheHelper.sharedPreferences!.getBool('dataSaved')}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ User data saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DrFitLayout()));
    } catch (e) {
      print('❌ Error saving user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        leadingWidth: 200,
        backgroundColor: PrimaryColor(context),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios_new_rounded,
                    color: buttonPrimaryColor(context), size: 20),
                Text('عودة',
                    style: TextStyle(
                        color: buttonPrimaryColor(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: PrimaryColor(context),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Text('اكمل بياناتك',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: buttonPrimaryColor(context))),
                  SizedBox(height: context.height * .05),

                  // Profile Image Picker
                  GestureDetector(
                    onTap: pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : null,
                          child: _selectedImage == null
                              ? Icon(Icons.person,
                                  size: 50, color: Colors.grey.shade600)
                              : null,
                        ),
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(50)),
                          child:
                              Icon(Icons.edit, color: Colors.black, size: 20),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.height * .08),
                  defaultFormField(
                    controller: nameController,
                    type: TextInputType.text,
                    validate: (value) =>
                        value!.isEmpty ? ' الرجاء ادخال الاسم' : null,
                    label: 'الاسم',
                    prefix: Icons.person,
                  ),
                  SizedBox(height: context.height * .03),
                  defaultFormField(
                    controller: ageController,
                    type: TextInputType.number,
                    validate: (value) {
                      if (value!.isEmpty) return ' الرجاء ادخال عمرك';
                      int age = int.tryParse(value) ?? 0;
                      if (age < 18 || age > 70) return 'الرجاء ادخال سن مناسب';
                      return null;
                    },
                    label: 'العمر',
                    prefix: Icons.calendar_month_sharp,
                  ),
                  SizedBox(height: context.height * .03),
                  defaultFormField(
                    maxLength: 11,
                    controller: phoneController,
                    type: TextInputType.phone,
                    validate: (value) {
                      if (value!.isEmpty) return 'الرجاء ادخال رقم الهاتف';
                      if (!RegExp(r'^(01[0-2,5]{1}[0-9]{8})$')
                          .hasMatch(value)) {
                        return 'الرجاء ادخال رقم هاتف صحيح';
                      }
                      return null;
                    },
                    label: 'رقم الهاتف',
                    prefix: Icons.phone_enabled_rounded,
                  ),
                  SizedBox(height: context.height * .09),

                  // Submit Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: defaultButton(
                      width: context.width * .444,
                      function: saveUserData,
                      text: 'التالي',
                      background: Colors.blueAccent,
                      radius: 20, context: context,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
