import 'package:flutter/cupertino.dart';

import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

import '../Constants/constant.dart';
import '../Models/api_response.dart';

class Services {
  Future<ApiResponse> getBankDetail() async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}bankDetails?user=${Constants.projectName}'),
        headers: Constants.headers,
      );
      return apiResponseFromJson(response.body); // Convert Json to Response Model
    } catch (e) {
      // Handle any errors that occur during the HTTP request.
      print('Error occurred while fetching bank details: $e');
      throw Exception('Failed to fetch bank details');
    }
  }

  Future<ApiResponse> submitFeedback(String feedback) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}feedbackDetails'),
        body: feedback,
        headers: Constants.headers,
      );
      return apiResponseFromJson(response.body); // Convert Json to Response Model
    } catch (e) {
      // Handle any errors that occur during the HTTP request.
      print('Error occurred while submitting feedback: $e');
      throw Exception('Failed to submit feedback');
    }
  }

  Future<ApiResponse> getUpdateList(String fromDate,String toDate) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}updateDetails?user=${Constants.projectName}&fromDate=$fromDate&toDate=$toDate'),
        headers: Constants.headers,
        // body: update,
      );
      return apiResponseFromJson(response.body); // Convert Json to Response Model
    } catch (e) {
      // Handle any errors that occur during the HTTP request.
      print('Error occurred while fetching updates: $e');
      throw Exception('Failed to fetch updates');
    }
  }

  Future<ApiResponse> getDeviceVersion(String deviceType) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}versionAndroidIos?user=${Constants.projectName}&type=$deviceType'),
        headers: Constants.headers,
      );
      return apiResponseFromJson(response.body); // Convert Json to Response Model
    } catch (e) {
      // Handle any errors that occur during the HTTP request.
      print('Error occurred while fetching device version: $e');
      throw Exception('Failed to fetch device version');
    }
  }

  Future<ApiResponse> submitOtr(String otr) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}otrDetails'),
        body: otr,
        headers: Constants.headers,
      );
      return apiResponseFromJson(response.body); // Convert Json to Response Model
    } catch (e) {
      // Handle any errors that occur during the HTTP request.
      print('Error occurred while submitting otr: $e');
      throw Exception('Failed to submit otr');
    }
  }

}
