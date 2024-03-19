import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../Constants/constant.dart';
import '../Constants/notify_socket_update.dart';
import '../Functions.dart';
import '../Models/client_header.dart';
import '../Models/liverate.dart';
import '../Models/reference_data.dart';
import '../Models/reference_data_rate.dart';
import '../Providers/liveRate_Provider.dart';

class SocketService {
  static getLiveRateData(BuildContext context) async {
    final provider = Provider.of<LiveRateProvider>(context, listen: false);

    Socket socket = io(
        Constants.socketUrl,
        OptionBuilder().setTransports(
            ['websocket']).build()); // Set socket url for connection
    socket.disconnect();
    debugPrint('Disconnect-----------------------------------');
    socket.connect();
    debugPrint('Connect-----------------------------------');
    socket.onConnect((_) async {
      socket.emit('client', [Constants.projectName]);
      // socket.emit('room', [Constants.projectName]);
      // debugPrint('Client-Emit------------------------------------------------');

      // shared.getIsLogin().then((login) async {
      //   if (login) {
      //     final loginData = await shared.getLoginData();
      //     if (loginData.isNotEmpty) {
      //       final userData = LoginData.getJson(json.decode(loginData));
      //       socket.emit(
      //           "End_Client", "${Constants.projectName}_${userData.loginId}");
      //       debugPrint(
      //           'End_Client-Emit------------------------------------------------');
      //     }
      //   }
      // });
      // debugPrint('onConnect------------------------------------------------');
    });

    socket.on('contactDetails', (response) {
      var data = Functions.inflateData(response);
      // debugPrint(data.toString());

      List<ClientHeaderData> listData = [];
      for (var jsonData in data) {
        final clientHeaderData = ClientHeaderData.fromJson(jsonData);
        listData.add(clientHeaderData);
      }

      if (listData.isNotEmpty) {
        provider.addClientHeaderData(listData);
        _addToControllerIfNotClosed(
            listData, NotifySocketUpdate.controllerClientData);
        _addToControllerIfNotClosed(
            listData, NotifySocketUpdate.controllerHome);
      }
    });

    socket.on('referanceDetails', (response) {
      var responseData = Functions.inflateData(response);
      // debugPrint(responseData[0].toString());
      List<ReferenceData> listData = [];
      for (var data in responseData) {
        final liveRate = ReferenceData.fromJson(data);
        listData.add(liveRate);
      }
      provider.addReferenceData(listData);
      // debugPrint('ClientData' + responseData.toString());
    });

    socket.on('referanceProducts', (liveRateResponse) {
      var responseData = Functions.inflateData(liveRateResponse);
      // debugPrint(responseData[0].toString());
      List<ReferenceDataRate> referenceDataRate = [];
      for (var item in responseData) {
        referenceDataRate.add(ReferenceDataRate.fromJson(item));
      }
      provider.addReferenceDataRate(referenceDataRate);
      _addToControllerIfNotClosed(
          liveRateResponse, NotifySocketUpdate.controllerRefrence);
    });

    socket.on('mainProducts', (messageResponse) async {
      List<Liverate> liveRate = [];
      var responseData = Functions.inflateData(messageResponse);

      for (var item in responseData) {
        liveRate.add(Liverate.fromJson(item));
      }
      // debugPrint(responseData[0].toString());
      provider.addLiveRateData(liveRate);
    });

    socket.onConnectError((err) => debugPrint('$err'));
    socket.onError((err) {
      debugPrint('$err');
    });
  }

  static void _addToControllerIfNotClosed<T>(T data, StreamController<T>? controller) {
    if (controller != null && !controller.isClosed) {
      controller.sink.add(data);
    }
  }
}
