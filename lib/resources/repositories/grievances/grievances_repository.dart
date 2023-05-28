import 'dart:convert';
import 'dart:developer';

import 'package:civic_user/constants/env_variable.dart';
import 'package:civic_user/models/grievances/grievances_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class GrievancesRepository {
  // static List<Grievances> grievanceList = [];

  Future<String> getGrievancesJson(
      String municipalityId, String createdBy) async {
    // return rootBundle.loadString('assets/grievance.json');
    final response = await Dio()
        .get(
          '$API_URL/grievances/by-created-by',
          data: jsonEncode(
              {"createdBy": createdBy, "municipalityId": municipalityId}),
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        )
        .timeout(const Duration(seconds: 10));
    return jsonEncode(response.data);
  }

  Future<List<Grievances>> loadGrievancesJson(
      String municipalityId, String createdBy) async {
    List<Grievances> grievanceList = [];
    try {
      final list =
          json.decode(await getGrievancesJson(municipalityId, createdBy))
              as List<dynamic>;
      for (int i = 0; i < list.length; i++) {
        Grievances grievance = Grievances(
          createdByName: list[i]['CreatedByName'],
          address: list[i]['Address'],
          priority: list[i]['Priority'],
          longitude: list[i]['LocationLong'],
          grievanceId: list[i]['GrievanceID'],
          contactNumber: list[i]['ContactNumber'],
          status: list[i]['Status'],
          description: list[i]['Description'],
          expectedCompletion: list[i]['ExpectedCompletion'],
          municipalityId: list[i]['MunicipalityID'],
          latitude: list[i]['LocationLat'],
          lastModifiedDate: list[i]['LastModifiedDate'],
          location: list[i]['Location'],
          contactByPhoneEnabled: list[i]['MobileContactStatus'],
          createdBy: list[i]['CreatedBy'],
          wardNumber: list[i]['WardNumber'],
          grievanceType: list[i]['GrievanceType'],
          assets: list[i]['Assets'],
        );
        grievanceList.add(grievance);
      }
      print(grievanceList);
      grievanceList.sort((g1, g2) {
        DateTime timestamp1 = DateTime.parse(g1.lastModifiedDate.toString());
        DateTime timestamp2 = DateTime.parse(g2.lastModifiedDate.toString());
        return timestamp2.compareTo(timestamp1);
      });
    } catch (e) {
      log('Caught error: ${e.toString()}');
    }
    return grievanceList;
  }

  Future<Response> addGrievanceCommentFile({
    required String encodedCommentFile,
    required String fileType,
    required String grievanceId,
  }) async {
    final response = await Dio().post(
      '$API_URL/general/upload-assets',
      data: jsonEncode({
        "File": encodedCommentFile,
        "FileType": fileType,
        "GrievanceID": grievanceId,
        "Section": 'comments'
      }),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    return response;
  }

  Future<void> addGrievanceComment({
    required String grievanceId,
    required String userId,
    required String name,
    required String comment,
    required Map? assets,
  }) async {
    try {
      final response = Dio().post(
        '$API_URL/grievances/grievance-comments',
        data: jsonEncode(
          {
            "GrievanceID": grievanceId,
            "CommentedBy": userId,
            "CommentedByName": name,
            "Assets": assets,
            "Comment": comment,
            "CreatedDate": DateTime.now().toString(),
          },
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<Response> addGrievanceAssetFile({
    required String encodedAssetFile,
    required String fileType,
    required String userId,
  }) async {
    final response = await Dio().post(
      '$API_URL/general/upload-assets',
      data: jsonEncode({
        "File": encodedAssetFile,
        "FileType": fileType,
        "UserID": userId,
        "Section": 'grievance'
      }),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    log(response.data.toString());
    return response;
  }

  Future<Response> modifyGrieance(
      String grievanceId, Grievances newGrievance) async {
    final response = await Dio().put(
      '$API_URL/grievances/modify-grievance',
      data: jsonEncode({
        "grievanceId": newGrievance.grievanceId,
        "expectedCompletion": newGrievance.expectedCompletion,
        "municipalityId": newGrievance.municipalityId,
        "userId": newGrievance.createdBy,
        "createdByName": newGrievance.createdByName,
        "grievanceType": newGrievance.grievanceType,
        "priority": newGrievance.priority,
        "status": newGrievance.status,
        "wardNumber": newGrievance.wardNumber,
        "description": newGrievance.description,
        "contactNumber": newGrievance.contactNumber,
        "latitude": newGrievance.latitude,
        "longitude": newGrievance.longitude,
        "address": newGrievance.address,
        "contactByPhoneEnabled": newGrievance.contactByPhoneEnabled,
        "lastModifiedDate": newGrievance.lastModifiedDate,
        "location": newGrievance.location,
        "newHouseAddress": newGrievance.newHouseAddress,
        "planDetails": newGrievance.planDetails,
        "deceasedName": newGrievance.deceasedName,
        "relation": newGrievance.relation,
        "createdDate": newGrievance.createdDate,
        "assets": newGrievance.assets
      }),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    return response;
  }

  // Future<List<Grievances>> closeGrievance(String grievanceId) async {
  //   await Future.delayed(const Duration(seconds: 2));
  //   grievanceList
  //           .firstWhere((element) => element.grievanceId == grievanceId)
  //           .open ==
  //       false;

  //   return grievanceList;
  // }

  // updateGrievanceStatus(String grievanceId, String status) async {
  //   grievanceList
  //       .firstWhere((element) => element.grievanceId == grievanceId)
  //       .status = status;
  // }

  // updateExpectedCompletion(
  //     String grievanceId, String expectedCompletion) async {
  //   grievanceList
  //       .firstWhere((element) => element.grievanceId == grievanceId)
  //       .expectedCompletion = expectedCompletion;
  // }

  Future<String> getGrievances(String municipalityId, String createdBy) async {
    final response = await Dio()
        .get(
          '$API_URL/grievances/by-created-by',
          data: jsonEncode(
              {"createdBy": createdBy, "municipalityId": municipalityId}),
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        )
        .timeout(const Duration(seconds: 10));
    return jsonEncode(response.data);
  }

  Future<Response> getGrievanceById({
    required String municipalityId,
    required String grievanceId,
  }) async {
    final response = await Dio().get(
      '$API_URL/grievances/grievance-comments-web?MunicipalityID=$municipalityId&GrievanceID=$grievanceId',
      // data: jsonEncode({
      //   "MunicipalityID": municipalityId,
      //   "GrievanceID": grievanceId,
      // }),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    log(response.toString());
    return response;
  }

  Future<Response> addGrievanceData(Grievances grievance) async {
    final response = await Dio().post(
      '$API_URL/grievances/create-grievance',
      data: jsonEncode({
        "municipalityId": grievance.municipalityId,
        "userId": grievance.createdBy,
        "createdByName": grievance.createdByName,
        "grievanceType": grievance.grievanceType,
        "createdDate": grievance.createdDate,
        "priority": grievance.priority,
        "status": grievance.status,
        "wardNumber": grievance.wardNumber,
        "description": grievance.description,
        "lastModifiedDate": grievance.lastModifiedDate,
        "contactNumber": grievance.contactNumber,
        "latitude": grievance.latitude,
        "longitude": grievance.longitude,
        "address": grievance.address,
        "contactByPhoneEnabled": grievance.contactByPhoneEnabled,
        "location": grievance.location,
        "assets": grievance.assets,
        "newHouseAddress": grievance.newHouseAddress,
        "planDetails": grievance.planDetails,
        "deceasedName": grievance.deceasedName,
        "relation": grievance.relation,
      }),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    return response;
  }
}
