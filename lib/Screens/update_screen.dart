// ignore_for_file: camel_case_types, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Constants/app_colors.dart';
import '../Constants/constant.dart';
import '../Functions.dart';
import '../Models/CommonRequestModel.dart';
import '../Services/common_service.dart';
import '../Widgets/custom_text.dart';

class Update_Screen extends StatefulWidget {
  const Update_Screen({super.key});

  @override
  State<Update_Screen> createState() => Update_ScreenState();
}

class Update_ScreenState extends State<Update_Screen> {
  String selectedFromDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  String selectedToDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  bool isLoading = false;
  bool isLoadingProg = true;
  late List<UpdateList> updateList = [];
  Services updateService = Services();
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;

    callUpdateApi();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CustomText(
                  text: 'From',
                  size: 15.0,
                  fontWeight: FontWeight.normal,
                  textColor: AppColors.primaryTextColor,
                  align: TextAlign.start,
                ),
                GestureDetector(
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Functions.calenderStyle(context),
                          child: child!,
                        );
                      },
                    ).then((selectedDate) {
                      if (selectedDate != null) {
                        setState(() {
                          selectedFromDate =
                              DateFormat('dd/MM/yyyy').format(selectedDate);
                        });
                      }
                    });
                  },
                  child: Container(
                      width: size.width * 0.25,
                      height: 25.0,
                      // color: AppColors.primaryColor,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.grey)),
                      alignment: Alignment.center,
                      child: CustomText(
                          text: selectedFromDate,
                          fontWeight: FontWeight.normal,
                          textColor: AppColors.primaryTextColor,
                          size: 13.0)),
                ),
                const CustomText(
                  text: 'To',
                  size: 15.0,
                  fontWeight: FontWeight.normal,
                  textColor: AppColors.primaryTextColor,
                  align: TextAlign.start,
                ),
                GestureDetector(
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Functions.calenderStyle(context),
                          child: child!,
                        );
                      },
                    ).then((selectedDate) {
                      if (selectedDate != null) {
                        setState(() {
                          selectedToDate =
                              DateFormat('dd/MM/yyyy').format(selectedDate);
                        });
                      }
                    });
                  },
                  child: Container(
                      width: size.width * 0.25,
                      height: 25.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.grey)),
                      alignment: Alignment.center,
                      child: CustomText(
                          text: selectedToDate,
                          fontWeight: FontWeight.normal,
                          textColor: AppColors.primaryTextColor,
                          size: 13.0)),
                ),
                GestureDetector(
                  onTap: () {
                    debugPrint(
                        "startDate->$selectedFromDate/endDate->$selectedToDate");
                    setState(() {
                      isLoading = true;
                    });
                    callUpdateApi();
                  },
                  child: Container(
                    height: 25.0,
                    width: size.width * 0.25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      // color: AppColors.primaryColor,
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Stack(
                      children: [
                        Visibility(
                          visible: !isLoading,
                          child: CustomText(
                            text: 'Search',
                            size: 15.0,
                            fontWeight: FontWeight.bold,
                            textColor: AppColors.defaultColor,
                            align: TextAlign.start,
                          ),
                        ),
                        Visibility(
                          visible: isLoading,
                          child: SizedBox(
                            height: 15.0,
                            width: 15,
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
          const Divider(
            color: AppColors.secondaryColor,
            thickness: 1,
          ),
          Expanded(
            child: updateList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text: 'Updates Not Available',
                          textColor: AppColors.primaryTextColor,
                          size: 20.0,
                          fontWeight: FontWeight.normal,
                        ),
                        Visibility(
                          visible: isLoadingProg,
                          child: SizedBox(
                            height: 15.0,
                            width: 15,
                            child: CircularProgressIndicator(
                              color: AppColors.primaryTextColor,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: updateList.length,
                    itemBuilder: (builder, index) {
                      return buildUpdateContainer(size, updateList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  buildUpdateContainer(Size size, UpdateList updateList) {
    var size = MediaQuery.of(context).size;
    return Card(
      elevation: 4,
      // shadowColor: AppColors.hintColorLight,
      color: AppColors.defaultColor,
      shape: RoundedRectangleBorder(
        side:  BorderSide(color: AppColors.secondaryColor, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      // decoration: ShapeDecoration(
      //   color: Colors.white,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(12),
      //   ),
      //   shadows: [AppColors.boxShadow],
      // ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:   CustomText(
                    text: updateList.title!= null ? updateList.title!.trim() : 'N/A',
                    textColor: AppColors.primaryTextColor,
                    size: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomText(
                  text:  "${DateFormat('HH:mm a').format(updateList.modifiedDate!)}",
                  textColor: AppColors.secondaryColor,
                  size: 14.0,
                  fontWeight: FontWeight.bold,
                )
              ],
            ),
            SizedBox(height: size.height * 0.01),
            CustomText(
              text: updateList.description != null
                  ? updateList.description!.trim()
                  : 'N/A',
              textColor: Colors.grey,
              size: 14.0,
              fontWeight: FontWeight.normal,
            ),

            SizedBox(height: size.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomText(
                  text:  "${DateFormat('dd').format(updateList.modifiedDate!)}",
                  textColor: Colors.grey,
                  size: 16.0,
                  fontWeight: FontWeight.normal,
                ),
                CustomText(
                  text: " ${DateFormat('MMM yyyy').format(updateList.modifiedDate!)}",
                  textColor: Colors.grey,
                  size: 16.0,
                  fontWeight: FontWeight.normal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void callUpdateApi() {
    Functions.checkConnectivity().then((isConnected) {
      if (isConnected) {
        // var startDate = Functions.convertDateFormat(selectedFromDate);
        // var endDate = Functions.convertDateFormat(selectedToDate);

        updateService.getUpdateList(selectedFromDate, selectedToDate).then((response) {
          if (_isMounted) {
            setState(() {
              isLoading = false;
              isLoadingProg = false;
              if (response.code != 400) {
                updateList = List<UpdateList>.from(response.data.map((item) => UpdateList.fromJson(item)));
              } else {
                updateList.clear();
              }
            });
          }
        });
      } else {
        if (_isMounted) {
          setState(() {
            isLoading = false;
            isLoadingProg = false;
          });
        }
        Functions.showToast(Constants.noInternet);
      }
    });
  }
}
