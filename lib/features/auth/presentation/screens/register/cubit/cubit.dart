import 'package:dr_fit/features/auth/presentation/screens/register/cubit/states.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterCubit extends Cubit<RegisterStates> {
  RegisterCubit() : super(RegisterInitialState());

  static RegisterCubit get(context) => BlocProvider.of(context);

  IconData suffix = Icons.visibility_outlined;
  bool isPassword = true;
  bool isConfirmPassword = true;
  bool isChecked = false;

  void changePasswordVisibility() {
    isPassword = !isPassword;
    suffix =
        isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined;

    emit(RegisterChangePasswordVisibilityState());
  }

  void changeConfirmPasswordVisibility() {
    isConfirmPassword = !isConfirmPassword;
    suffix = isConfirmPassword
        ? Icons.visibility_outlined
        : Icons.visibility_off_outlined;

    emit(RegisterChangePasswordVisibilityState());
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(RegisterLoadingState());
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      emit(RegisterLoadedState());
    } catch (e) {
      emit(RegisterFailState(massege: e.toString()));
    }
  }
}
