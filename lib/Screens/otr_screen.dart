import 'dart:convert';
import 'dart:io';

import 'package:thakurji_jems/Services/common_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Constants/app_colors.dart';
import '../Constants/constant.dart';
import '../Constants/images.dart';
import '../Functions.dart';
import '../Models/CommonRequestModel.dart';
import '../Routes/page_route.dart';
import '../Utils/shared.dart';
import '../Widgets/custom_text.dart';
import 'home_screen.dart';

class Otr_Screen extends StatefulWidget {
  static const String routeName = PageRoutes.Otr_Screen;

  const Otr_Screen({super.key});

  @override
  State<Otr_Screen> createState() => _Otr_ScreenState();
}

class _Otr_ScreenState extends State<Otr_Screen> {
  GlobalKey<FormState> _loginFormKey = GlobalKey();
  final Shared shared = Shared();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _firmNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  bool isLoginClickable = true;
  bool isLoadingLogin = false;

  bool isNamenameValidate = false;
  bool isMobileValidate = false;
  bool isFirmNameValidate = false;
  bool isCityValidate = false;
  Services services = Services();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        elevation: 4,
        systemOverlayStyle:
        SystemUiOverlayStyle(statusBarColor: AppColors.transparent),
        backgroundColor: AppColors.textColor,
        toolbarHeight: 50,
        // elevation: .0,
        title: const CustomText(
          text: 'One Time Registration',
          textColor: AppColors.defaultColor,
          size: 16.0,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.defaultColor,
        // decoration: BoxDecoration(
        //   // color:
        //   image: DecorationImage(
        //     image: AssetImage(AppImagePath.bg),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.05),
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  AppImagePath.splashImage,
                  scale: 6,
                ),
              ),
            ),
            Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                color: AppColors.secondaryLightColor,
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          style: TextStyle(
                            fontSize:
                            MediaQuery.of(context).textScaler.scale(16),
                          ),
                          controller: _nameController,
                          autovalidateMode: isNamenameValidate
                              ? AutovalidateMode.always
                              : AutovalidateMode.disabled,
                          decoration:
                          getInputBoxDecoration('Enter Name', Icons.person),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: 1,
                          cursorColor: AppColors.secondaryColor,
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        TextFormField(
                          style: TextStyle(
                            fontSize:
                            MediaQuery.of(context).textScaler.scale(16),
                          ),
                          controller: _firmNameController,
                          autovalidateMode: isFirmNameValidate
                              ? AutovalidateMode.always
                              : AutovalidateMode.disabled,
                          decoration: getInputBoxDecoration(
                              'Enter Firm Name', Icons.factory_rounded),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: 1,
                          cursorColor: AppColors.primaryColor,
                          // obscureText: true,
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        TextFormField(
                          style: TextStyle(
                            fontSize:
                            MediaQuery.of(context).textScaler.scale(16),
                          ),
                          controller: _mobileController,
                          autovalidateMode: isMobileValidate
                              ? AutovalidateMode.always
                              : AutovalidateMode.disabled,
                          decoration: getInputBoxDecoration(
                              'Enter Contact No', Icons.phone_android_rounded),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          maxLines: 1,
                          cursorColor: AppColors.primaryColor,
                          // obscureText: true,
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        TextFormField(
                          style: TextStyle(
                            fontSize:
                            MediaQuery.of(context).textScaler.scale(16),
                          ),
                          controller: _cityController,
                          autovalidateMode: isCityValidate
                              ? AutovalidateMode.always
                              : AutovalidateMode.disabled,
                          decoration: getInputBoxDecoration(
                              'Enter City', Icons.location_city_rounded),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: 1,
                          cursorColor: AppColors.primaryColor,
                          // obscureText: true,
                        ),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        InkWell(
                          onTap: () {
                            callInsertOtr();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Stack(
                              children: [
                                Visibility(
                                  visible: !isLoadingLogin,
                                  child: const CustomText(
                                    text: 'Submit',
                                    textColor: AppColors.defaultColor,
                                    size: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Visibility(
                                  visible: isLoadingLogin,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.defaultColor,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getInputBoxDecoration(String text, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(
        icon,
        color: AppColors.secondaryColor,
        size: 25,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      hintText: text,
      hintStyle: const TextStyle(fontSize: 14.0, color: AppColors.primaryColor),
      fillColor: AppColors.defaultColor,
      filled: true,
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      ),
    );
  }

  void callInsertOtr() {
    if (_loginFormKey.currentState!.validate()) {
      if (_nameController.text.isEmpty) {
        Platform.isIOS
            ? Functions.showSnackBar(context, 'Please enter your name.')
            : Functions.showToast('Please enter your name.');
      }
      else if (_firmNameController.text.isEmpty) {
        Platform.isIOS
            ? Functions.showSnackBar(context, 'Please enter firm name.')
            : Functions.showToast('Please enter firm name.');
      }
      else if (_mobileController.text.isEmpty) {
        Platform.isIOS
            ? Functions.showSnackBar(context, 'Please enter contact number.')
            : Functions.showToast('Please enter contact number.');
      }
      else if (_mobileController.text.length!=10) {
        Platform.isIOS
            ? Functions.showSnackBar(context, 'Please enter valid contact number.')
            : Functions.showToast('Please enter valid contact number.');
      }
      else if (_cityController.text.isEmpty) {
        Platform.isIOS
            ? Functions.showSnackBar(context, 'Please enter city.')
            : Functions.showToast('Please enter city.');
      }
      else {
        Functions.checkConnectivity().then((isConnected) {
          if (isConnected) {
            if (isLoginClickable) {
              setState(() {
                isLoginClickable = false;
                isLoadingLogin = true;
              });
            }
            var otr = otrRequestToJson(
                OtrRequest(
                    user: Constants.projectName,
                    name: _nameController.text.trim(),
                    firmName: _firmNameController.text.trim(),
                    contactNo: _mobileController.text.trim(),
                    city: _cityController.text.trim()
                ));
            services.submitOtr(otr).then((response) {
              if (response.code == 200) {
                shared.setIsFirstTimeRegister(true);
                Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
                // Navigator.of(context).pop();
                Platform.isIOS
                    ? Functions.showSnackBar(context, response.message)
                    : Functions.showToast(response.message);
                // Navigator.of(context).pop();
                setState(() {
                  isLoginClickable = true;
                  isLoadingLogin = false;
                });

                // Functions.showToast('Successfully Register');
              } else {
                setState(() {
                  isLoginClickable = true;
                  isLoadingLogin = false;
                });
                // Functions.showToast('Login Fail');
              }
            });
          } else {
            setState(() {
              isLoginClickable = true;
              isLoadingLogin = false;
            });
            Functions.showToast(Constants.noInternet);
          }
        });
      }
    }
  }
}