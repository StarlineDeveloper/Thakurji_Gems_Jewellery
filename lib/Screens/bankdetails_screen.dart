// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Constants/app_colors.dart';
import '../Constants/constant.dart';
import '../Constants/images.dart';
import '../Functions.dart';
import '../Models/CommonRequestModel.dart';
import '../Services/common_service.dart';
import '../Widgets/custom_text.dart';

class BankDetail_Screen extends StatefulWidget {
  const BankDetail_Screen({super.key});

  @override
  State<BankDetail_Screen> createState() => _BankDetail_ScreenState();
}

class _BankDetail_ScreenState extends State<BankDetail_Screen>
    with AutomaticKeepAliveClientMixin<BankDetail_Screen> {
  @override
  bool get wantKeepAlive => true;

  bool isLoading = true;
  late List<BankList> bankList = [];
  Services bankService = Services();
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;

    callBankDetailsApi();
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
      child: bankList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: 'Bank Not Available',
                    textColor: AppColors.primaryTextColor,
                    size: 20.0,
                    fontWeight: FontWeight.normal,
                  ),
                  Visibility(
                    visible: isLoading,
                    child: SizedBox(
                      height: 15.0,
                      width: 15,
                      child: CircularProgressIndicator(
                        color: AppColors.primaryTextColor,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: bankList.length,
              itemBuilder: (builder, index) {
                return buildBankDetailContainer(size, bankList[index]);
              },
            ),
    );
  }

  Widget buildBankDetailContainer(Size size, BankList bankList) {
    return Card(
      elevation: 4,
      // shadowColor: AppColors.hintColorLight,
      color: AppColors.defaultColor,
      shape: RoundedRectangleBorder(
        side:  BorderSide(color: AppColors.secondaryColor, width: 1.0),
        borderRadius: BorderRadius.circular(5.0),
      ),
      // margin: EdgeInsets.only(left: 4.0,right: 4.0,top: 4.0),
      // decoration: ShapeDecoration(
      //   color: Colors.white,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(12),
      //   ),
      //   shadows: [AppColors.boxShadow],
      // ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(

                imageUrl: bankList.bankLogoUrl!.isNotEmpty ? bankList.bankLogoUrl! : '',
                fit: BoxFit.fill,
                errorWidget: (context, url, error) {
                  return Image.asset(AppImagePath.splashImage);
                },
                placeholder: (context, url) {
                  return const CupertinoActivityIndicator(color: AppColors.primaryTextColor,);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Bank Name',
                      textColor: AppColors.primaryTextColor,
                      size: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 8),
                    CustomText(
                      text: 'Account Name',
                      textColor: AppColors.primaryTextColor,
                      size: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 8),
                    CustomText(
                      text: 'Account No',
                      textColor: AppColors.primaryTextColor,
                      size: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 8),
                    CustomText(
                      text: 'IFSC Code',
                      textColor: AppColors.primaryTextColor,
                      size: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 8),
                    CustomText(
                      text: 'Branch Name',
                      textColor: AppColors.primaryTextColor,
                      size: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomText(
                        text: '  :: ${bankList.bankName}',
                        textColor: AppColors.primaryColor,
                        size: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                      SizedBox(height: 8),
                      CustomText(
                        text: '  :: ${bankList.accountName}',
                        textColor: AppColors.primaryColor,
                        size: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                      SizedBox(height: 8),
                      CustomText(
                        text: '  :: ${bankList.accountNumber}',
                        textColor: AppColors.primaryColor,
                        size: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                      SizedBox(height: 8),
                      CustomText(
                        text: '  :: ${bankList.ifscCode}',
                        textColor: AppColors.primaryColor,
                        size: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                      SizedBox(height: 8),
                      CustomText(
                        text: '  :: ${bankList.branchName}',
                        textColor: AppColors.primaryColor,
                        size: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void callBankDetailsApi() async {
    final isConnected = await Functions.checkConnectivity();

    if (!isConnected) {
      if (_isMounted) {
        setState(() {
          isLoading = false;
        });
      }
      Functions.showToast(Constants.noInternet);
      return;
    }

    try {
      final response = await bankService.getBankDetail();

      if (!_isMounted) return;

      setState(() {
        isLoading = false;
        if (response.code != 400) {
          bankList = List<BankList>.from(
            response.data.map((item) => BankList.fromJson(item)),
          );
        } else {
          bankList.clear();
        }
      });
    } catch (e) {
      if (_isMounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error occurred while fetching bank details: $e');
      Functions.showToast('Failed to fetch bank details');
    }
  }
}
