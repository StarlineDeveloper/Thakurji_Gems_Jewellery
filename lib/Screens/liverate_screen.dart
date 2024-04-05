// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../Constants/app_colors.dart';
import '../Constants/notify_socket_update.dart';
import '../Functions.dart';
import '../Models/client_header.dart';
import '../Models/comex_data_model.dart';
import '../Models/liverate.dart';
import '../Models/reference_data.dart';
import '../Models/reference_data_rate.dart';
import '../Providers/liveRate_Provider.dart';
import '../Widgets/custom_text.dart';

class LiveRateScreen extends StatefulWidget {
  static const String routeName = '/live-rate';

  const LiveRateScreen({super.key});

  @override
  State<LiveRateScreen> createState() => _LiveRateScreenState();
}

class _LiveRateScreenState extends State<LiveRateScreen> {
  late LiveRateProvider liveRateProvider;

  // Lists and other variables
  List<Liverate> liveRatesDetailMaster = [];
  List<ReferenceDataRate> liveRateReferenceDetail = [];
  List<ReferenceData> referenceData = [];
  List<ComexDataModel> referenceComexData = [];
  List<ComexDataModel> referenceNextData = [];
  List<ComexDataModel> referenceNextDataOldChange = [];
  List<ComexDataModel> referenceFutureData = [];
  List<Liverate> liveRatesDetailOldMaster = [];
  List<ComexDataModel> referenceComexDataOldChange = [];
  List<ComexDataModel> referenceFutureDataOldChange = [];
  List<Liverate> liveRatesDetailOldChange = [];

  String bid = '';
  String ask = '';
  String high = '';
  String low = '';

  ClientHeaderData clientHeadersDetail = ClientHeaderData();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    liveRateProvider = Provider.of<LiveRateProvider>(context, listen: false);
    loadData();

    _initializeListeners();
    if (!mounted) {
      return;
    }
  }

  void _initializeControllers() {
    NotifySocketUpdate.controllerRefrence = StreamController();
    if (!mounted) {
      return;
    }
  }

  void _initializeListeners() {
    liveRatesDetailMaster = liveRateProvider.getLiveRateData();
    referenceFutureData = liveRateProvider.getFutureData();
    referenceComexData = liveRateProvider.getComexData();
    referenceNextData = liveRateProvider.getNextData();
    NotifySocketUpdate.controllerRefrence!.stream.asBroadcastStream().listen(
      (event) {
        loadData();
      },
    );
    // NotifySocketUpdate.controllerMainData!.stream.asBroadcastStream().listen(
    //   (event) {
    //     Future.delayed(const Duration(seconds: 1), () {
    //       liveRatesDetailMaster = _liverateProvider.getLiveRateData();
    //
    //       liveRatesDetailOldMaster = liveRatesDetailMaster;
    //
    //       if (!streamController.isClosed) {
    //         streamController.sink.add(liveRatesDetailMaster);
    //       }
    //     });
    //   },
    // );
  }

  @override
  void dispose() {
    NotifySocketUpdate.controllerRefrence!.close();
    // NotifySocketUpdate.controllerMainData!.close();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  loadData() {
    liveRateReferenceDetail = [];
    referenceData = liveRateProvider.getReferenceData();
    liveRateReferenceDetail = liveRateProvider.getReferenceDataRate();
    clientHeadersDetail = liveRateProvider.getClientHeaderData();

    // liveRateReferenceDetailOld = liveRateReferenceDetail;

    Functions.checkConnectivity().then((isConnected) {
      List<ComexDataModel> comexData = [];
      List<ComexDataModel> futureData = [];
      List<ComexDataModel> nextData = [];
      if (isConnected) {
        setState(() {
          referenceFutureData = liveRateProvider.getFutureData();
          referenceComexData = liveRateProvider.getComexData();
          referenceNextData = liveRateProvider.getNextData();
        });
        // Set Future and Next list based on Liverates and Reference
        for (var data in referenceData) {
          for (var rate in liveRateReferenceDetail) {
            if (rate.symbol!.toLowerCase() == data.source!.toLowerCase()) {
              bid = rate.bid.toString();
              ask = rate.ask.toString();
              high = rate.high.toString();
              low = rate.low.toString();
            } // Set bid, ask, high and low which matches the symbol of rate and source of data.
          }
          if (/*data.isDisplay! &&*/
              (data.source == 'gold' || data.source == 'silver')) {
            futureData.add(
              ComexDataModel(
                symbolName: data.name,
                bid: bid.toString(),
                ask: ask.toString(),
                high: high.toString(),
                low: low.toString(),
                // isDisplay: data.isDisplay,
              ),
            );
          } else if (/*data.isDisplay! &&*/
              (data.source == 'XAGUSD' ||
                  data.source == 'XAUUSD' ||
                  data.source == 'INRSpot')) {
            comexData.add(
              ComexDataModel(
                symbolName: data.name,
                bid: bid.toString(),
                ask: ask.toString(),
                high: high.toString(),
                low: low.toString(),
                // isDisplay: data.isDisplay,
              ),
            );
          } else if (/*data.isDisplay! &&*/
              (data.source == 'goldnext' || data.source == 'silvernext')) {
            nextData.add(
              ComexDataModel(
                symbolName: data.name,
                bid: bid.toString(),
                ask: ask.toString(),
                high: high.toString(),
                low: low.toString(),
                // isDisplay: data.isDisplay,
              ),
            );
          }
        }
        liveRateProvider.addFutureData(futureData);
        liveRateProvider.addComexData(comexData);
        liveRateProvider.addNextData(nextData);
      } else {
        setState(() {
          referenceFutureData = liveRateProvider.getFutureData();
          referenceComexData = liveRateProvider.getComexData();
          referenceNextData = liveRateProvider.getNextData();
        });
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      // liveRatesDetailMaster=[];

      liveRatesDetailMaster = liveRateProvider.getLiveRateData();

      liveRatesDetailOldMaster = liveRatesDetailMaster;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: referenceComexData.isEmpty ||
                        referenceComexData.length > 3
                        ? 3
                        : referenceComexData.length,
                    // crossAxisSpacing: size.width * .01,
                    mainAxisExtent: size.height * 0.13,
                  ),
                  itemBuilder: (context, index) =>
                      buildComexContainers(size, index),
                  itemCount: referenceComexData.length,
                ),
              ),
              SizedBox(
                height: size.width * .02,
              ),
              buildNonLoginProductInfo(size),
              Visibility(
                visible: clientHeadersDetail.isRate != null &&
                    clientHeadersDetail.isRate!,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: liveRatesDetailMaster.length,
                  itemBuilder: (context, index) => buildProductContainer(
                    size,
                    index,
                  ),
                ),
              ),
              SizedBox(
                height: size.width * .02,
              ),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: referenceFutureData.isEmpty ||
                        referenceFutureData.length > 2
                        ? 2
                        : referenceFutureData.length,
                    crossAxisSpacing: size.width * .02,
                    // childAspectRatio: size.width / (size.height / 3.1),
                    childAspectRatio: referenceFutureData.length < 2
                        ? 2.7
                        : size.width == 0
                        ? 1
                        : size.width / 260,
                  ),
                  itemBuilder: (builder, index) {
                    return buildFutureContainers(size, index);
                  },
                  itemCount: referenceFutureData.length,
                ),
              ),
              SizedBox(
                height: size.width * .02,
              ),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: referenceNextData.isEmpty ||
                        referenceNextData.length > 2
                        ? 2
                        : referenceNextData.length,
                    crossAxisSpacing: size.width * .02,
                    // childAspectRatio: size.width / (size.height / 3.1),
                    childAspectRatio: referenceNextData.length < 2
                        ? 2.7
                        : size.width == 0
                        ? 1
                        : size.width / 260,
                  ),
                  itemBuilder: (builder, index) {
                    return buildNextContainers(size, index);
                  },
                  itemCount: referenceNextData.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNonLoginProductInfo(Size size) {
    return Column(
      children: [
        clientHeadersDetail.isRate != null &&
                clientHeadersDetail.isRate! &&
                liveRatesDetailMaster.isNotEmpty
            ? Container(
                height: 35.0,
                decoration: BoxDecoration(
                  // border:
                  //     Border.all(width: 0.8, color: AppColors.secondaryColor),
                  gradient: AppColors.primaryGradient,
                  // color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),

                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: size.width * .33,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: const CustomText(
                          text: 'PRODUCT',
                          size: 15.0,
                          fontWeight: FontWeight.bold,
                          textColor: AppColors.textColor,
                          align: TextAlign.start,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: SizedBox(
                        // width: size.width / 5,
                        child: Visibility(
                          visible: clientHeadersDetail.isBuy != null &&
                              clientHeadersDetail.isBuy!,
                          child: const CustomText(
                            text: 'BUY',
                            size: 15.0,
                            fontWeight: FontWeight.bold,
                            textColor: AppColors.textColor,
                            align: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: SizedBox(
                        // width: size.width / 5,
                        child: Visibility(
                          visible: clientHeadersDetail.isSell != null &&
                              clientHeadersDetail.isSell!,
                          child: const CustomText(
                            text: 'SELL',
                            size: 15.0,
                            fontWeight: FontWeight.bold,
                            textColor: AppColors.textColor,
                            align: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    // Flexible(
                    //   flex: 1,
                    //   fit: FlexFit.tight,
                    //   child: SizedBox(
                    //     // width: size.width / 5,
                    //     child: Visibility(
                    //       visible: clientHeadersDetail.isSell != null &&
                    //           clientHeadersDetail.isSell!,
                    //       child: const CustomText(
                    //         text: 'T-CHANGE',
                    //         size: 12.0,
                    //         fontWeight: FontWeight.bold,
                    //         textColor: AppColors.textColor,
                    //         align: TextAlign.center,
                    //       ),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              )
            : const CustomText(
                text: 'Liverate Currently Not Available',
                size: 16.0,
                fontWeight: FontWeight.bold,
                textColor: AppColors.primaryTextColor,
                align: TextAlign.center,
              ),
      ],
    );
  }

  Widget buildFutureContainers(Size size, int index) {
    if (referenceFutureDataOldChange.isNotEmpty) {
      if (referenceFutureDataOldChange.length == referenceFutureData.length) {
        var oldAskRate = referenceFutureDataOldChange[index].ask!.isEmpty
            ? 0.0
            : double.parse(referenceFutureDataOldChange[index].ask!);
        var newAskRate = referenceFutureData[index].ask!.isEmpty
            ? 0.0
            : double.parse(referenceFutureData[index].ask!);

        setFutureAskLabelColor(
            oldAskRate, newAskRate, referenceFutureData[index]);

        var oldBidRate = referenceFutureDataOldChange[index].bid!.isEmpty
            ? 0.0
            : double.parse(referenceFutureDataOldChange[index].bid!);
        var newBidRate = referenceFutureData[index].bid!.isEmpty
            ? 0.0
            : double.parse(referenceFutureData[index].bid!);

        setFutureBidLabelColor(
            oldBidRate, newBidRate, referenceFutureData[index]);
      }
    }
    if (referenceFutureData.length - 1 == index) {
      referenceFutureDataOldChange = referenceFutureData;
    }

    return referenceFutureData.isEmpty
        ? Container()
        :
    Container(
      width: size.width,
      decoration:

      ShapeDecoration(
        color: AppColors.defaultColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.primaryColor, width: 1.0),
          // Border added here
          borderRadius: BorderRadius.circular(5),
        ),
        shadows: const [AppColors.boxShadow],
      ),
      child: Column(
        children: [
          Container(
            width: size.width,
            decoration: BoxDecoration(
              // color: AppColors.primaryColor,
                gradient: AppColors.primaryGradient
              // borderRadius: const BorderRadius.only(
              //   topLeft: Radius.circular(0.0),
              //   topRight: Radius.circular(0.0),
              // ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: CustomText(
                text: referenceFutureData[index]
                    .symbolName
                    ?.toUpperCase()
                    .trim() ??
                    '',
                fontWeight: FontWeight.bold,
                textColor: AppColors.textColor,
                size: 14.0,
                align: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Column(
                              children: [
                                CustomText(
                                  align: TextAlign.center,
                                  text: 'BUY',
                                  fontWeight: FontWeight.bold,
                                  textColor: AppColors.textColor,
                                  size: 14.0,
                                ),
                                CustomText(
                                  text: referenceFutureData[index].bid ??
                                      '',
                                  fontWeight: FontWeight.bold,
                                  textColor: referenceFutureData[index]
                                      .bidBGColor,
                                  size: 17.0,
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Column(
                              children: [
                                CustomText(
                                  align: TextAlign.center,
                                  text: 'SELL',
                                  fontWeight: FontWeight.bold,
                                  textColor: AppColors.textColor,
                                  size: 14.0,
                                ),
                                CustomText(
                                  text: referenceFutureData[index].ask ??
                                      '',
                                  fontWeight: FontWeight.bold,
                                  textColor: referenceFutureData[index]
                                      .askBGColor,
                                  size: 17.0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Column(
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.only(left: 5.0, right: 5.0),
                        child: const Divider(
                          color: AppColors.primaryColor,
                          thickness: 1,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              flex: 1,
                              fit: FlexFit.tight,
                              child: CustomText(
                                text:
                                'L : ${referenceFutureData[index].low!.isEmpty ? '' : referenceFutureData[index].low!}',
                                fontWeight: FontWeight.bold,
                                textColor: AppColors.textColor,
                                align: TextAlign.center,
                                size: 12.0,
                              ),
                            ),

                            // SizedBox(
                            //   width: 10,
                            // ),
                            Flexible(
                              flex: 1,
                              fit: FlexFit.tight,
                              child: CustomText(
                                text:
                                'H : ${referenceFutureData[index].high!.isEmpty ? '' : referenceFutureData[index].high!}',
                                fontWeight: FontWeight.bold,
                                textColor: AppColors.textColor,
                                align: TextAlign.center,
                                size: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNextContainers(Size size, int index) {
    if (referenceNextDataOldChange.isNotEmpty) {
      if (referenceNextDataOldChange.length == referenceNextData.length) {
        var oldAskRate = referenceNextDataOldChange[index].ask!.isEmpty
            ? 0.0
            : double.parse(referenceNextDataOldChange[index].ask!);
        var newAskRate = referenceNextData[index].ask!.isEmpty
            ? 0.0
            : double.parse(referenceNextData[index].ask!);

        setFutureAskLabelColor(
            oldAskRate, newAskRate, referenceNextData[index]);

        var oldBidRate = referenceNextDataOldChange[index].bid!.isEmpty
            ? 0.0
            : double.parse(referenceNextDataOldChange[index].bid!);
        var newBidRate = referenceNextData[index].bid!.isEmpty
            ? 0.0
            : double.parse(referenceNextData[index].bid!);

        setFutureBidLabelColor(
            oldBidRate, newBidRate, referenceNextData[index]);
      }
    }

    if (referenceNextData.length - 1 == index) {
      referenceNextDataOldChange = referenceNextData;
    }

    return referenceNextData.isEmpty
        ? Container()
        :
    Container(
      // height: 100,
      width: size.width,
      decoration: ShapeDecoration(
        color: AppColors.defaultColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.primaryColor, width: 1.0),
          // Border added here
          borderRadius: BorderRadius.circular(5),
        ),
        shadows: const [AppColors.boxShadow],
      ),

      child: Column(
        children: [
          Container(
            width: size.width,
            decoration: BoxDecoration(
              // color: AppColors.primaryColor,

              gradient: AppColors.primaryGradient,
              // borderRadius: const BorderRadius.only(
              //   topLeft: Radius.circular(5.0),
              //   topRight: Radius.circular(5.0),
              // ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: CustomText(
                text: referenceNextData[index]
                    .symbolName
                    ?.toUpperCase()
                    .trim() ??
                    '',
                fontWeight: FontWeight.bold,
                textColor: AppColors.textColor,
                size: 14.0,
                align: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Column(
                              children: [
                                CustomText(
                                  align: TextAlign.center,
                                  text: 'BUY',
                                  fontWeight: FontWeight.bold,
                                  textColor: AppColors.textColor,
                                  size: 14.0,
                                ),
                                CustomText(
                                  text:
                                  referenceNextData[index].bid ?? '',
                                  fontWeight: FontWeight.bold,
                                  textColor:
                                  referenceNextData[index].bidBGColor,
                                  size: 17.0,
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Column(
                              children: [
                                CustomText(
                                  align: TextAlign.center,
                                  text: 'SELL',
                                  fontWeight: FontWeight.bold,
                                  textColor: AppColors.textColor,
                                  size: 14.0,
                                ),
                                CustomText(
                                  text:
                                  referenceNextData[index].ask ?? '',
                                  fontWeight: FontWeight.bold,
                                  textColor:
                                  referenceNextData[index].askBGColor,
                                  size: 17.0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.only(left: 5.0, right: 5.0),
                        child: const Divider(
                          color: AppColors.primaryColor,
                          thickness: 1,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 1,
                              fit: FlexFit.tight,
                              child: CustomText(
                                text:
                                'L : ${referenceNextData[index].low!.isEmpty ? '' : referenceNextData[index].low!}',
                                fontWeight: FontWeight.bold,
                                textColor: AppColors.textColor,
                                align: TextAlign.center,
                                size: 12.0,
                              ),
                            ),
                            // SizedBox(
                            //   width: 10,
                            // ),
                            Flexible(
                              flex: 1,
                              fit: FlexFit.tight,
                              child: CustomText(
                                text:
                                'H : ${referenceNextData[index].high!.isEmpty ? '' : referenceNextData[index].high!}',
                                fontWeight: FontWeight.bold,
                                align: TextAlign.center,
                                textColor: AppColors.textColor,
                                size: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildComexContainers(Size size, int index) {
    if (referenceComexDataOldChange.isNotEmpty) {
      if (referenceComexDataOldChange.length == referenceComexData.length) {
        var oldAskRate = referenceComexDataOldChange[index].ask!.isEmpty
            ? 0.0
            : double.parse(referenceComexDataOldChange[index].ask!);
        var newAskRate = referenceComexData[index].ask!.isEmpty
            ? 0.0
            : double.parse(referenceComexData[index].ask!);

        setAskLabelColor(oldAskRate, newAskRate, referenceComexData[index]);

        var oldBidRate = referenceComexDataOldChange[index].bid!.isEmpty
            ? 0.0
            : double.parse(referenceComexDataOldChange[index].bid!);
        var newBidRate = referenceComexData[index].bid!.isEmpty
            ? 0.0
            : double.parse(referenceComexData[index].bid!);

        setBidLabelColor(oldBidRate, newBidRate, referenceComexData[index]);
      }
    }
    if (referenceComexData.length - 1 == index) {
      referenceComexDataOldChange = referenceComexData;
    }

    return referenceComexData.isEmpty
        ? Container()
        :
    Card(
      // shadowColor: referenceComexData[index].askBGColor,
      color: AppColors.defaultColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.primaryColor, width: 1.0),
        borderRadius: BorderRadius.circular(
          5.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: size.width,
            decoration: BoxDecoration(
              // color: AppColors.primaryColor,
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5.0),
                topRight: Radius.circular(5.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: CustomText(
                text: referenceComexData[index].symbolName!.trim() ?? '',
                fontWeight: FontWeight.bold,
                textColor: AppColors.textColor,
                size: 14.0,
                align: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    // height: 30.0,
                    width: size.width / 4.5,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.transparent,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(7),
                      ),
                    ),
                    child:
                    // AnimatedFlipCounter(
                    //   value:double.parse(referenceComexData[index].ask ?? ''),
                    //   fractionDigits: 2, // decimal precision
                    //   textStyle: TextStyle(
                    //     letterSpacing: 0.2,
                    //     fontSize: 17,
                    //     fontWeight: FontWeight.bold,
                    //     color: referenceComexData[index].askBGColor,
                    //   ),
                    // )
                    CustomText(
                      text: referenceComexData[index].ask ?? '',
                      fontWeight: FontWeight.bold,
                      textColor: referenceComexData[index].askBGColor,
                      size: 17.0,
                      align: TextAlign.start,
                    ),
                  ),
                ),
                Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Divider(
                      color: AppColors.primaryColor,
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            text:
                            'L:${referenceComexData[index].low!.isEmpty ? '' : referenceComexData[index].low!}',
                            fontWeight: FontWeight.bold,
                            textColor: AppColors.textColor,
                            size: 10.5,
                            align: TextAlign.start,
                          ),
                          CustomText(
                            text:
                            '/H:${referenceComexData[index].high!.isEmpty ? '' : referenceComexData[index].high!}',
                            fontWeight: FontWeight.bold,
                            textColor: AppColors.textColor,
                            size: 10.5,
                            align: TextAlign.start,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductContainer(Size size, int index) {
    try {
      if (liveRatesDetailOldChange.isNotEmpty) {
        if (liveRatesDetailOldChange.length == liveRatesDetailMaster.length) {
          if (liveRatesDetailOldChange[index].ask == '-' ||
              liveRatesDetailOldChange[index].ask == '--') {
            liveRatesDetailMaster[index].askBGColor = AppColors.textColor;
            liveRatesDetailMaster[index].askTextColor = AppColors.textColor;
          } else {
            dynamic oldAskRate = liveRatesDetailOldChange[index].ask!.isEmpty
                ? 0.0
                : double.parse(liveRatesDetailOldChange[index].ask!);
            dynamic newAskRate = liveRatesDetailMaster[index].ask!.isEmpty
                ? 0.0
                : double.parse(liveRatesDetailMaster[index].ask!);

            setLabelColorsAskMainProduct(
                oldAskRate, newAskRate, liveRatesDetailMaster[index]);
          }


          if (liveRatesDetailOldChange[index].bid == '-' ||
              liveRatesDetailOldChange[index].bid == '--') {
            liveRatesDetailMaster[index].bidBGColor = AppColors.textColor;
            liveRatesDetailMaster[index].bidTextColor = AppColors.textColor;
            // setLabelColorsMainProduct('--', '--', liveRatesDetailMaster[index]);
          } else {
            dynamic oldBidRate = liveRatesDetailOldChange[index].bid!.isEmpty
                ? 0.0
                : double.parse(liveRatesDetailOldChange[index].bid!);
            dynamic newBidRate = liveRatesDetailMaster[index].bid!.isEmpty
                ? 0.0
                : double.parse(liveRatesDetailMaster[index].bid!);

            setLabelColorsBidMainProduct(
                oldBidRate, newBidRate, liveRatesDetailMaster[index]);
          }

          // if (liveRatesDetailOldChange[index].diff == '-' ||
          //     liveRatesDetailOldChange[index].diff == '--') {
          //   liveRatesDetailMaster[index].diffBGColor = AppColors.defaultColor;
          //   liveRatesDetailMaster[index].diffTextColor = AppColors.defaultColor;
          //   // setLabelColorsMainProduct('--', '--', liveRatesDetailMaster[index]);
          // } else {
          //   dynamic oldBidRate = liveRatesDetailOldChange[index].diff!.isEmpty
          //       ? 0.0
          //       : double.parse(liveRatesDetailOldChange[index].diff!);
          //   dynamic newBidRate = liveRatesDetailMaster[index].diff!.isEmpty
          //       ? 0.0
          //       : double.parse(liveRatesDetailMaster[index].diff!);
          //
          //   setLabelColorsDiffMainProduct(
          //       oldBidRate, newBidRate, liveRatesDetailMaster[index]);
          // }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    if (liveRatesDetailMaster.length - 1 == index) {
      liveRatesDetailOldChange = liveRatesDetailMaster;
    }

    return liveRatesDetailMaster.isEmpty
        ? SizedBox()
        : Padding(
            padding: const EdgeInsets.only(
                top: 5.0, left: 0.0, right: 0.0, bottom: 0.0),
            child: Container(
              height: 55.0,
              decoration: ShapeDecoration(
                color: AppColors.bg,
                shape: RoundedRectangleBorder(
                  side:BorderSide(color: AppColors.secondaryColor, width: 1.0),
                  borderRadius: BorderRadius.circular(5),
                ),
                // shadows: const [AppColors.boxShadow],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: size.width * .33,
                        child: Padding(

                          padding: const EdgeInsets.only(left: 8.0),
                          child: CustomText(
                            text: liveRatesDetailMaster[index]
                                .name!
                                .trim()
                                .toUpperCase(),
                            size: 14,
                            fontWeight: FontWeight.bold,
                            textColor: AppColors.primaryTextColor,
                            align: TextAlign.start,
                            // noOfLines: 2,
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   width: size.width * .3,
                      //   child: CustomText(
                      //     text:
                      //     liveRateReferenceDetail[0].time!.trim()!=null?'Time-${liveRateReferenceDetail[0].time!.trim()}':'',
                      //     size: 10.5,
                      //     fontWeight: FontWeight.bold,
                      //     textColor: AppColors.secondaryTextColor,
                      //     align: TextAlign.start,
                      //   ),
                      // ),
                    ],
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: SizedBox(
                      // width: size.width / 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Visibility(
                            visible: clientHeadersDetail.isBuy != null &&
                                clientHeadersDetail.isBuy!,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(3),
                                    color: AppColors.transparent),
                                padding: const EdgeInsets.all(3.0),
                                child: CustomText(
                                    text:
                                        '${liveRatesDetailMaster[index].bid}',
                                    size: 15,
                                    fontWeight: FontWeight.bold,
                                    textColor:
                                        liveRatesDetailMaster[index]
                                            .bidBGColor),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: clientHeadersDetail.isLow != null &&
                                clientHeadersDetail.isLow!,
                            child: CustomText(
                              text:
                                  'L-${liveRatesDetailMaster[index].low}',
                              size: 13.5,
                              fontWeight: FontWeight.normal,
                              textColor: AppColors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: SizedBox(
                      // width: size.width / 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Visibility(
                            visible: clientHeadersDetail.isSell != null &&
                                clientHeadersDetail.isSell!,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: AppColors.transparent,
                                ),
                                padding: const EdgeInsets.all(3.0),
                                child: CustomText(
                                  text:
                                      '${liveRatesDetailMaster[index].ask}',
                                  size: 15,
                                  fontWeight: FontWeight.bold,
                                  textColor: liveRatesDetailMaster[index]
                                      .askBGColor,
                                  align: TextAlign.start,
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: clientHeadersDetail.isHigh != null &&
                                clientHeadersDetail.isHigh!,
                            child: CustomText(
                              text:
                                  'H-${liveRatesDetailMaster[index].high}',
                              size: 13.5,
                              textColor: AppColors.green,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Flexible(
                  //   flex: 1,
                  //   fit: FlexFit.tight,
                  //   child: SizedBox(
                  //     // width: size.width / 5,
                  //     child: Padding(
                  //       padding: const EdgeInsets.only(
                  //           left: 10.0, right: 10.0),
                  //       child: Container(
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(3),
                  //           color: AppColors.transparent,
                  //         ),
                  //         padding: const EdgeInsets.all(3.0),
                  //         child: CustomText(
                  //           text: '${liveRatesDetailMaster[index].diff}',
                  //           size: 13,
                  //           fontWeight: FontWeight.bold,
                  //           textColor:
                  //               liveRatesDetailMaster[index].diffBGColor,
                  //           align: TextAlign.center,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
          );
  }

  setAskLabelColor(dynamic oldRate, dynamic newRate, model) {
    if (oldRate < newRate) {
      model.askBGColor = AppColors.green;
      model.askTextColor = AppColors.defaultColor;
    } else if (oldRate > newRate) {
      model.askBGColor = AppColors.red;
      model.askTextColor = AppColors.defaultColor;
    } else {
      model.askBGColor = AppColors.textColor;
      model.askTextColor = AppColors.textColor;
    }
  }

  setFutureAskLabelColor(dynamic oldRate, dynamic newRate, model) {
    if (oldRate < newRate) {
      model.askBGColor = AppColors.green;
      model.askTextColor = AppColors.defaultColor;
    } else if (oldRate > newRate) {
      model.askBGColor = AppColors.red;
      model.askTextColor = AppColors.defaultColor;
    } else {
      model.askBGColor = AppColors.textColor;
      model.askTextColor = AppColors.textColor;
    }
  }

  setBidLabelColor(dynamic oldRate, dynamic newRate, model) {
    if (oldRate < newRate) {
      model.bidBGColor = AppColors.green;
      model.bidTextColor = AppColors.defaultColor;
    } else if (oldRate > newRate) {
      model.bidBGColor = AppColors.red;
      model.bidTextColor = AppColors.defaultColor;
    } else {
      model.bidBGColor = AppColors.textColor;
      model.bidTextColor = AppColors.textColor;
    }
  }

  setFutureBidLabelColor(dynamic oldRate, dynamic newRate, model) {
    if (oldRate < newRate) {
      model.bidBGColor = AppColors.green;
      model.bidTextColor = AppColors.defaultColor;
    } else if (oldRate > newRate) {
      model.bidBGColor = AppColors.red;
      model.bidTextColor = AppColors.defaultColor;
    } else {
      model.bidBGColor = AppColors.textColor;
      model.bidTextColor = AppColors.textColor;
    }
  }

  void setLabelColorsBidMainProduct(dynamic oldRate, dynamic newRate, model) {
    if (oldRate < newRate) {
      // model.askBGColor = AppColors.green;
      // model.askTextColor = AppColors.defaultColor;
      model.bidBGColor = AppColors.green;
      model.bidTextColor = AppColors.defaultColor;
    } else if (oldRate > newRate) {
      // model.askBGColor = AppColors.red;
      // model.askTextColor = AppColors.defaultColor;
      model.bidBGColor = AppColors.red;
      model.bidTextColor = AppColors.defaultColor;
    } else {
      // model.askBGColor = AppColors.primaryColor;
      // model.askTextColor = AppColors.secondaryTextColor;
      model.bidBGColor = AppColors.textColor;
      model.bidTextColor = AppColors.textColor;
    }
  }

  void setLabelColorsDiffMainProduct(dynamic oldRate, dynamic newRate, model) {
    if (oldRate < newRate) {
      // model.askBGColor = AppColors.green;
      // model.askTextColor = AppColors.defaultColor;
      model.diffBGColor = AppColors.green;
      model.diffTextColor = AppColors.defaultColor;
    } else if (oldRate > newRate) {
      // model.askBGColor = AppColors.red;
      // model.askTextColor = AppColors.defaultColor;
      model.diffBGColor = AppColors.red;
      model.diffTextColor = AppColors.defaultColor;
    } else {
      // model.askBGColor = AppColors.primaryColor;
      // model.askTextColor = AppColors.secondaryTextColor;

      model.diffBGColor = AppColors.textColor;
      model.diffTextColor = AppColors.textColor;
    }
  }

  void setLabelColorsAskMainProduct(dynamic oldRate, dynamic newRate, model) {
    if (oldRate < newRate) {
      model.askBGColor = AppColors.green;
      model.askTextColor = AppColors.defaultColor;
      // model.bidBGColor = AppColors.green;
      // model.bidTextColor = AppColors.defaultColor;
    } else if (oldRate > newRate) {
      model.askBGColor = AppColors.red;
      model.askTextColor = AppColors.defaultColor;
      // model.bidBGColor = AppColors.red;
      // model.bidTextColor = AppColors.defaultColor;
    } else {
      model.askBGColor = AppColors.textColor;
      model.askTextColor = AppColors.textColor;
      // model.bidBGColor = AppColors.primaryColor;
      // model.bidTextColor = AppColors.secondaryTextColor;
    }
  }
}
