import 'package:dr_fit/core/utils/constants.dart';
import 'package:dr_fit/features/auth/presentation/screens/forgetpassword/forgetpassword_screen.dart';
import 'package:dr_fit/features/auth/presentation/screens/login/cubit/cubit.dart';
import 'package:dr_fit/features/auth/presentation/screens/login/cubit/states.dart';
import 'package:dr_fit/features/auth/presentation/screens/register/register_screen.dart';
import 'package:dr_fit/features/onboarding/view/components/component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  var formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: BlocConsumer<LoginCubit,LoginStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            backgroundColor: kPrimaryColor,
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Text(
                          '!مرحبا بعودتك',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 100,
                        ),
                        defaultFormField(
                          controller: emailController,
                          type: TextInputType.text,
                          validate: (value) {
                            if (value!.isEmpty) {
                              return ' الرجاء ادخال البريد الالكترونى';
                            }
                            return null;
                          },
                          label: 'البريد الالكترونى',
                          prefix: Icons.email,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        defaultFormField(
                          controller: passwordController,
                          type: TextInputType.visiblePassword,
                          suffix: LoginCubit.get(context).isPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          onSubmit: (value) {
                            if (formKey.currentState!.validate()) {}
                          },
                          isPassword: LoginCubit.get(context).isPassword,
                          suffixPressed: LoginCubit.get(context).changePasswordVisibility,
                          validate: (value) {
                            if (value!.isEmpty) {
                              return 'الرجاء ادخال كلمه المرور';
                            }
                            return null;
                          },
                          label: 'كلمة المرور',
                          prefix: Icons.lock,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Row(
                            children: [
                              Checkbox(
                                value: LoginCubit.get(context).isChecked,
                                onChanged: (value) {
                                  LoginCubit.get(context).changeCheckBoxSelected(value!);
                                },
                              ),
                              Text('تذكرنى'),
                              Spacer(),
                              TextButton(
                                onPressed: () {
                                  navigateTo(context, ForgetpasswordScreen());
                                },
                                child: Text('هل نسيت كلمه المرور'),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60),
                          child: defaultButton(
                            function: () {
                              if (formKey.currentState!.validate()) {}
                            },
                            text: 'تسجيل الدخول',
                            isUpperCase: true,
                            radius: 20,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('تسجيل باستخدام',
                                  style: TextStyle(fontSize: 15)),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 50,
                            left: 50,
                            top: 15,
                            bottom: 15,
                          ),
                          child: Container(
                            height: 50,
                            child: Row(
                              children: [
                                
                                Spacer(),
                                IconButton(
                                  iconSize: 50,
                                  onPressed: () {},
                                  icon: Image(
                                    image: AssetImage(
                                      'assets/logo/google_logo.png',
                                    ),
                                  ),
                                ),
                                Spacer(),
                                
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ' ليس لديك حساب؟',
                            ),
                            defaultTextButton(
                              function: () {
                                navigateTo(context, RegisterScreen());
                              },
                              text: 'التسجيل',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


