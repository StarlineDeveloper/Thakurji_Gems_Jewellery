// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Constants/app_colors.dart';
import '../Constants/constant.dart';
import '../Constants/notify_socket_update.dart';
import '../Functions.dart';
import '../Models/CommonRequestModel.dart';
import '../Models/client_header.dart';
import '../Providers/liveRate_Provider.dart';
import '../Services/common_service.dart';
import '../Widgets/contact_detail_container.dart';
import '../Widgets/custom_text.dart';

class ContactUs_Screen extends StatefulWidget {
  const ContactUs_Screen({super.key});

  @override
  State<ContactUs_Screen> createState() => ContactUs_ScreenState();
}

class ContactUs_ScreenState extends State<ContactUs_Screen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final Services feedbackService = Services();
  bool isLoading = false;
  FocusNode emailFocusNode = new FocusNode();
  FocusNode phoneFocusNode = new FocusNode();
  FocusNode subjectFocusNode = new FocusNode();
  FocusNode messageFocusNode = new FocusNode();

  ClientHeaderData liveData = ClientHeaderData();
  late LiveRateProvider _liverateProvider;
  bool isAddressContainerVisible = false;
  bool isEmailContainerVisible = false;
  bool isBookingContainerVisible = false;

  bool isAddress1Visible = false;
  bool isAddress2Visible = false;
  bool isAddress3Visible = false;

  bool isEmail1Visible = false;
  bool isEmail2Visible = false;

  bool isBooking1Visible = false;
  bool isBooking2Visible = false;
  bool isBooking3Visible = false;
  bool isBooking4Visible = false;
  bool isBooking5Visible = false;
  bool isBooking6Visible = false;
  bool isBooking7Visible = false;

  clearFields() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    subjectController.clear();
    messageController.clear();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _liverateProvider = Provider.of<LiveRateProvider>(context, listen: false);
    getLiveData();
    NotifySocketUpdate.controllerClientData = StreamController.broadcast();
    NotifySocketUpdate.controllerClientData!.stream.listen((event) {
      getLiveData();
    });
  }

  @override
  void dispose() {
    NotifySocketUpdate.controllerClientData!.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 4.0),
          child: Column(
            children: [
              Visibility(
                visible: isAddressContainerVisible,
                child: Container(
                  margin: EdgeInsets.only(top: 4),
                  width: size.width,
                  padding: const EdgeInsets.all(10.0),
                  decoration: ShapeDecoration(
                    color: AppColors.defaultColor,
                    shape: RoundedRectangleBorder(
                      side:  BorderSide(color: AppColors.secondaryColor, width: 1.0),

                      borderRadius: BorderRadius.circular(8),
                    ),
                    // shadows: const [AppColors.boxShadow],
                  ),
                  // decoration: ShapeDecoration(
                  //   color: AppColors.defaultColor,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   //  shadows: const [AppColors.boxShadow],
                  // ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          // color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.defaultColor,
                          size: 30.0,
                        ),
                      ),
                      AddressContainer(
                        isVisible: isAddress1Visible,
                        titleText: 'ADDRESS',
                        titleSize: 16.0,
                        descriptionText: liveData.address1 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.secondaryColor,
                        titleFontWeight: FontWeight.bold,
                        descriptionFontWeight: FontWeight.w400,
                      ),
                      AddressContainer(
                        isVisible: isAddress2Visible,
                        titleText: 'ADDRESS',
                        titleSize: 16.0,
                        descriptionText: liveData.address2 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.secondaryColor,
                        titleFontWeight: FontWeight.bold,
                        descriptionFontWeight: FontWeight.w400,
                      ),
                      AddressContainer(
                        isVisible: isAddress3Visible,
                        titleText: 'ADDRESS',
                        titleSize: 16.0,
                        descriptionText: liveData.address3 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.secondaryColor,
                        titleFontWeight: FontWeight.bold,
                        descriptionFontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 3.0,
              ),
              Visibility(
                visible: isEmailContainerVisible,
                child: Container(
                  width: size.width,
                  padding: const EdgeInsets.all(10.0),
                  decoration: ShapeDecoration(
                    color: AppColors.defaultColor,
                    shape: RoundedRectangleBorder(
                      side:  BorderSide(color: AppColors.secondaryColor, width: 1.0),

                      borderRadius: BorderRadius.circular(8),
                    ),
                    // shadows: const [AppColors.boxShadow],
                  ),
                  // decoration: ShapeDecoration(
                  //   color: Colors.white,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   //  shadows: const [AppColors.boxShadow],
                  // ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          // color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: const Icon(
                          Icons.email_rounded,
                          color: AppColors.defaultColor,
                          size: 30.0,
                        ),
                      ),
                      Visibility(
                        visible: isEmailContainerVisible,
                        child: const CustomText(
                          text: 'EMAIL',
                          size: 16.0,
                          textColor: AppColors.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ContactDetailContainer(
                        isVisible: isEmail1Visible,
                        descriptionText: liveData.email1 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.primaryTextColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(scheme: 'mailto', path: liveData.email1),
                          );
                        },
                      ),
                      ContactDetailContainer(
                        isVisible: isEmail2Visible,
                        descriptionText: liveData.email2 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.primaryTextColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(scheme: 'mailto', path: liveData.email2),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 3.0,
              ),
              Visibility(
                visible: isBookingContainerVisible,
                child: Container(
                  width: size.width,
                  padding: const EdgeInsets.all(10.0),
                  decoration: ShapeDecoration(
                    color: AppColors.defaultColor,
                    shape: RoundedRectangleBorder(
                      side:  BorderSide(color: AppColors.secondaryColor, width: 1.0),

                      borderRadius: BorderRadius.circular(8),
                    ),
                    // shadows: const [AppColors.boxShadow],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,

                          // color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: const Icon(
                          Icons.add_ic_call_rounded,
                          color: AppColors.defaultColor,
                          size: 30.0,
                        ),
                      ),
                      Visibility(
                        visible: isBookingContainerVisible,
                        child: const CustomText(
                          text: 'BOOKING NUMBER',
                          size: 16.0,
                          textColor: AppColors.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ContactDetailContainer(
                        isVisible: isBooking1Visible,
                        descriptionText: liveData.number1 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.primaryTextColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(
                                scheme: 'tel',
                                path: Functions.alphaNum(liveData.number1!)),
                          );
                        },
                      ),
                      ContactDetailContainer(
                        isVisible: isBooking2Visible,
                        descriptionText: liveData.number2 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.primaryTextColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(
                                scheme: 'tel',
                                path: Functions.alphaNum(liveData.number2!)),
                          );
                        },
                      ),
                      ContactDetailContainer(
                        isVisible: isBooking3Visible,
                        descriptionText: liveData.number3 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.primaryTextColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(
                                scheme: 'tel',
                                path: Functions.alphaNum(liveData.number3!)),
                          );
                        },
                      ),
                      ContactDetailContainer(
                        isVisible: isBooking4Visible,
                        descriptionText: liveData.number4 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.primaryTextColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(
                                scheme: 'tel',
                                path: Functions.alphaNum(liveData.number4!)),
                          );
                        },
                      ),
                      ContactDetailContainer(
                        isVisible: isBooking5Visible,
                        descriptionText: liveData.number5 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.primaryTextColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(
                                scheme: 'tel',
                                path: Functions.alphaNum(liveData.number5!)),
                          );
                        },
                      ),
                      ContactDetailContainer(
                        isVisible: isBooking6Visible,
                        descriptionText: liveData.number6 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.primaryTextColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(
                                scheme: 'tel',
                                path: Functions.alphaNum(liveData.number6!)),
                          );
                        },
                      ),
                      ContactDetailContainer(
                        isVisible: isBooking7Visible,
                        descriptionText: liveData.number7 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.primaryTextColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(
                                scheme: 'tel',
                                path: Functions.alphaNum(liveData.number7!)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 3.0,
              ),
              Container(
                width: size.width,
                // margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(10.0),
                decoration: ShapeDecoration(
                  color: AppColors.defaultColor,
                  shape: RoundedRectangleBorder(
                    side:  BorderSide(color: AppColors.secondaryColor, width: 1.0),

                    borderRadius: BorderRadius.circular(8),
                  ),
                  // shadows: const [AppColors.boxShadow],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          // color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Align(
                            alignment: Alignment.center,
                            child: CustomText(
                                text: 'FEEDBACK FROM',
                                fontWeight: FontWeight.normal,
                                textColor: AppColors.textColor,
                                size: 18.0)),
                      ),
                      const SizedBox(
                        height: 7.0,
                      ),
                      CustomText(
                          text: 'Name*',
                          fontWeight: FontWeight.normal,
                          textColor: AppColors.primaryTextColor,
                          size: 14.0),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).textScaler.scale(16),
                          color: AppColors.primaryTextColor
                        ),
                        controller: nameController,
                        decoration:
                            getInputBoxDecoration('Please Enter Your Name'),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        cursorColor: AppColors.secondaryColor,
                        onFieldSubmitted: (String value) {
                          FocusScope.of(context).requestFocus(emailFocusNode);
                        },
                      ),
                      const SizedBox(
                        height: 7.0,
                      ),
                      CustomText(
                          text: 'Email*',
                          fontWeight: FontWeight.normal,
                          textColor: AppColors.primaryTextColor,
                          size: 14.0),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).textScaler.scale(16),
                            color: AppColors.primaryTextColor
                        ),
                        controller: emailController,
                        decoration:
                            getInputBoxDecoration('Please Enter Your Email'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        cursorColor: AppColors.secondaryColor,
                        focusNode: emailFocusNode,
                        onFieldSubmitted: (String value) {
                          FocusScope.of(context).requestFocus(phoneFocusNode);
                        },
                      ),
                      const SizedBox(
                        height: 7.0,
                      ),
                      CustomText(
                          text: 'Phone*',
                          fontWeight: FontWeight.normal,
                          textColor: AppColors.primaryTextColor,
                          size: 14.0),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).textScaler.scale(16),
                            color: AppColors.primaryTextColor
                        ),
                        controller: phoneController,
                        decoration:
                            getInputBoxDecoration('Please Enter Your Phone'),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        cursorColor: AppColors.secondaryColor,
                        focusNode: phoneFocusNode,
                        onFieldSubmitted: (String value) {
                          FocusScope.of(context).requestFocus(subjectFocusNode);
                        },
                      ),
                      const SizedBox(
                        height: 7.0,
                      ),
                      CustomText(
                          text: 'Subject*',
                          fontWeight: FontWeight.normal,
                          textColor: AppColors.primaryTextColor,
                          size: 14.0),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).textScaler.scale(16),
                            color: AppColors.primaryTextColor
                        ),
                        controller: subjectController,
                        decoration: getInputBoxDecoration(
                            'Please Enter Your Subject(Optional)'),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        cursorColor: AppColors.secondaryColor,
                        focusNode: subjectFocusNode,
                        onFieldSubmitted: (String value) {
                          FocusScope.of(context).requestFocus(messageFocusNode);
                        },
                      ),
                      const SizedBox(
                        height: 7.0,
                      ),
                      CustomText(
                          text: 'Message*',
                          fontWeight: FontWeight.normal,
                          textColor: AppColors.primaryTextColor,
                          size: 14.0),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).textScaler.scale(16),
                            color: AppColors.primaryTextColor
                        ),
                        controller: messageController,
                        decoration: getInputBoxDecoration('Message For Me'),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        cursorColor: AppColors.secondaryColor,
                        focusNode: messageFocusNode,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          bool isAnyFieldEmpty = nameController.text.isEmpty ||
                              emailController.text.isEmpty ||
                              phoneController.text.isEmpty ||
                              // subjectController.text.isEmpty ||
                              messageController.text.isEmpty;

                          if (isAnyFieldEmpty) {
                            Platform.isIOS
                                ? Functions.showSnackBar(context, 'Please fill all fields.')
                                : Functions.showToast('Please fill all fields.');
                          } else if (!Functions.velidateEmail(emailController.text)) {
                            Platform.isIOS
                                ? Functions.showSnackBar(context, 'Please enter a valid email.')
                                : Functions.showToast('Please enter a valid email.');
                          } else {
                            var feedback = feedbackToJson(
                                FeedbackRequest(
                                    user: Constants.projectName,
                                    name: nameController.text,
                                    email: emailController.text,
                                    mobile: phoneController.text,
                                    subject: subjectController.text,
                                    message: messageController.text
                                ));

                            sendFeedback(feedback);
                          }
                        },
                        child: Container(
                          width: size.width * .9,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            // color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          alignment: Alignment.center,
                          padding:
                              const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Stack(
                            children: [
                              Visibility(
                                visible: !isLoading,
                                child: CustomText(
                                    text: 'Submit Feedback',
                                    fontWeight: FontWeight.normal,
                                    textColor: AppColors.textColor,
                                    size: 16.0),
                              ),
                              Visibility(
                                visible: isLoading,
                                child: SizedBox(
                                  height: 20.0,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.defaultColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  getInputBoxDecoration(String text) {
    return InputDecoration(
      isDense: true,

      contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
      hintText: text,
      hintStyle: TextStyle(fontSize: 16.0, color: AppColors.hintColor),

      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(
          color: AppColors.primaryTextColor,
        ),

      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(
          color:  AppColors.primaryTextColor,
        ),
      ),
    );
  }

  sendFeedback(String feedback) {
    setState(() {
      isLoading = true;
    });
    Functions.checkConnectivity().then((isConnected) {
      if (isConnected) {
        feedbackService.submitFeedback(feedback).then((response) {
          if (response.code == 200) {
            setState(() {
              isLoading = false;
            });
            Functions.showToast(
                response.message);
            clearFields();
          } else {
            Functions.showToast(response.message!);
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Functions.showToast(Constants.noInternet);
      }
    });
  }
  getLiveData() {
    setState(() {
      liveData = _liverateProvider.getClientHeaderData();
    });

    // Check for visiblity of Address Area
    if (
        liveData.address1!.trim().isEmpty &&

        liveData.address2!.trim().isEmpty &&

        liveData.address3!.trim().isEmpty) {
      isAddressContainerVisible = false;
    } else {
      isAddressContainerVisible = true;
      liveData.address1 != null&&
          liveData.address1!.trim().isNotEmpty
          ? isAddress1Visible = true
          : isAddress1Visible = false;
      liveData.address2 != null&&
          liveData.address2!.trim().isNotEmpty
          ? isAddress2Visible = true
          : isAddress2Visible = false;
      liveData.address3 != null&&
          liveData.address3!.trim().isNotEmpty
          ? isAddress3Visible = true
          : isAddress3Visible = false;
    }

    // Check for visiblity of Email Area and Booking Area
    if (liveData.email1!.isEmpty && liveData.email2!.isEmpty) {
      isEmailContainerVisible = false;
    } else {
      isEmailContainerVisible = true;
      liveData.email1!.isEmpty
          ? isEmail1Visible = false
          : isEmail1Visible = true;
      liveData.email2!.isEmpty
          ? isEmail2Visible = false
          : isEmail2Visible = true;
    }

    // Check for visiblity of Booking Area
    if (
        liveData.number1!.trim().isEmpty &&
        liveData.number2!.trim().isEmpty &&
        liveData.number3!.trim().isEmpty &&
        liveData.number4!.trim().isEmpty &&
        liveData.number5!.trim().isEmpty &&
        liveData.number6!.trim().isEmpty &&
        liveData.number7!.trim().isEmpty) {
      isBookingContainerVisible = false;
    } else {
      isBookingContainerVisible = true;
      liveData.number1 != null
          ? isBooking1Visible = true
          : isBooking1Visible = false;
      liveData.number2!.trim().isNotEmpty
          ? isBooking2Visible = true
          : isBooking2Visible = false;
      liveData.number3.trim().isNotEmpty
          ? isBooking3Visible = true
          : isBooking3Visible = false;
      liveData.number4 .trim().isNotEmpty
          ? isBooking4Visible = true
          : isBooking4Visible = false;
      liveData.number5 .trim().isNotEmpty
          ? isBooking5Visible = true
          : isBooking5Visible = false;
      liveData.number6 .trim().isNotEmpty
          ? isBooking6Visible =true
          : isBooking6Visible = false;
      liveData.number7 .trim().isNotEmpty
          ? isBooking7Visible = true
          : isBooking7Visible = false;
    }
  }
}

class AddressContainer extends StatelessWidget {
  const AddressContainer({
    required this.descriptionText,
    required this.descriptionSize,
    required this.color,
    required this.descriptionFontWeight,
    required this.titleText,
    required this.titleSize,
    required this.titleFontWeight,
    this.isVisible = false,
    super.key,
  });

  final bool isVisible;
  final String titleText;
  final double titleSize;
  final String descriptionText;
  final double descriptionSize;
  final Color color;
  final FontWeight titleFontWeight;
  final FontWeight descriptionFontWeight;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Container(
        margin: const EdgeInsets.only(
          top: 10,
        ),
        // color: AppColors.defaultColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: titleText,
              size: titleSize,
              textColor: color,
              fontWeight: titleFontWeight,
            ),
            CustomText(
              text: descriptionText,
              fontWeight: descriptionFontWeight,
              textColor: AppColors.primaryTextColor,
              size: descriptionSize,
              align: TextAlign.center,
            ),

            // Text(
            //   textScaleFactor: 1.0,
            //   descriptionText,
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //       fontSize: descriptionSize,
            //       color: color,
            //       fontWeight: descriptionFontWeight),
            // ),
          ],
        ),
      ),
    );
  }
}
