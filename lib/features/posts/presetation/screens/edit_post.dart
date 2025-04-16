import 'dart:async';
import 'dart:io';

import 'package:dr_fit/core/shared/about_images.dart';
import 'package:dr_fit/core/utils/component.dart';
import 'package:dr_fit/core/utils/constants.dart';
import 'package:dr_fit/features/posts/cubit/posts_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditPostScreen extends StatefulWidget {
  final String postId;
  final String value;
  final String imageUrl;

  const EditPostScreen({
    required this.postId,
    required this.value,
    required this.imageUrl,
  });

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _postController;
  File? _selectedImage;
  bool _isLoading = false;
  String? _imageUrl;
  bool _removeImage = false;

  @override
  void initState() {
    super.initState();
    _postController = TextEditingController(text: widget.value);
    _imageUrl = widget.imageUrl;
  }

  Future<void> _pickImage() async {
    final File? image = await ImageServices.pickImage();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _removeImage = false;
      });
    }
  }

  Future<void> _updatePost() async {
    final trimmedText = _postController.text.trim();
    final bool noText = trimmedText.isEmpty;
    final bool noImage =
        (_selectedImage == null && _imageUrl == null) || _removeImage;

    if (noText && noImage) {
      showToast(
        text: 'يرجى إدخال نص أو اختيار صورة!',
        state: ToastStates.WARNING,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? finalImageUrl;

      if (_removeImage) {
        finalImageUrl = null;
      } else if (_selectedImage != null) {
        finalImageUrl = await ImageServices.uploadImage(_selectedImage!);
      } else {
        finalImageUrl = _imageUrl;
      }

      await context.read<PostsCubit>().updatePost(
            postId: widget.postId,
            newText: trimmedText,
            newImageUrl: finalImageUrl,
          );

      showToast(
        text: 'تم تحديث المنشور بنجاح!',
        state: ToastStates.SUCCESS,
      );

      await context.read<PostsCubit>().fetchPostById(postId: widget.postId);
      Navigator.pop(context);
    } catch (e) {
      showToast(
        text: 'حدث خطأ أثناء تحديث المنشور!',
        state: ToastStates.ERROR,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildImageWidget() {
    if (_selectedImage != null) {
      return FutureBuilder<Size>(
        future: _getImageSize(_selectedImage!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final size = snapshot.data!;
            return AspectRatio(
              aspectRatio: size.width / size.height,
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
              ),
            );
          }
          return Container(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        },
      );
    } else if (_imageUrl != null && !_removeImage) {
      return Image.network(
        _imageUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: Icon(Icons.error, color: Colors.red),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Future<Size> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();
    final Image image = Image.file(imageFile);
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );
    return completer.future;
  }

  Future<bool> _onWillPop() async {
    if (_postController.text.trim() != widget.value ||
        _selectedImage != null ||
        _removeImage) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('لم يتم حفظ التعديلات'),
          content: Text('هل تريد الخروج بدون حفظ التغييرات؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('نعم'),
            ),
          ],
        ),
      );
      return shouldLeave ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = (_selectedImage != null) ||
        (_imageUrl != null && _imageUrl!.isNotEmpty && !_removeImage);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        final shouldLeave = await _onWillPop();
        if (shouldLeave && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        appBar: AppBar(
          title: Text('تعديل المنشور', style: TextStyle(color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _postController,
                    maxLines: 5,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      hintText: 'اكتب شيئًا...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (hasImage)
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.black,
                              insetPadding: EdgeInsets.all(10),
                              child: InteractiveViewer(
                                panEnabled: true,
                                minScale: 0.5,
                                maxScale: 3.0,
                                child: _selectedImage != null
                                    ? Image.file(_selectedImage!)
                                    : Image.network(_imageUrl!),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _buildImageWidget(),
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.image, color: Colors.white),
                      label: Text(
                        hasImage ? 'تغيير الصورة' : 'إضافة صورة',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: _pickImage,
                    ),
                    if (hasImage)
                      ElevatedButton.icon(
                        icon: Icon(Icons.delete, color: Colors.white),
                        label: Text('حذف الصورة',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('تأكيد الحذف'),
                              content:
                                  Text('هل أنت متأكد أنك تريد حذف الصورة؟'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('إلغاء'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedImage = null;
                                      _removeImage = true;
                                      _imageUrl = null;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text('حذف'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updatePost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bottomNavigationBar,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? CupertinoActivityIndicator()
                        : Text('تحديث',
                            style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}