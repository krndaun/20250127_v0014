import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:nesysworks/models/JoinedRequestItem.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nesysworks/models/request_item.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ApiService {
  static const String baseUrl = 'http://121.140.204.7:18988';
  static const String loginUrl = 'https://works.plinemotors.kr';

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }


  // 참여 요청 데이터 가져오기
  static Future<JoinedRequestItem?> fetchJoinedRequests(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/api/user_joined_request?user_id=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('[DEBUG] fetchJoinedRequests 응답: $data');

        return JoinedRequestItem.fromJson(data);
      } else {
        throw Exception('Failed to fetch joined requests: ${response.statusCode}');
      }
    } catch (e) {
      print('[ERROR] fetchJoinedRequests 오류: $e');
      return null;
    }
  }


  static Future<Map<String, dynamic>> fetchFromServer(String userId) async {
    final url = Uri.parse('$baseUrl/api/user_joined_request?user_id=$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('[ERROR] fetchFromServer 오류: $e');
      throw Exception('Error: $e');
    }
  }

  // static Future<List<RequestItem>> fetchJoinedRequests(String userId) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/api/user_joined_request?user_id=$userId'),
  //     );
  //     final data = _processResponse(response);
  //     final List<dynamic> requests = data['data'] ?? [];
  //     return requests.map((item) => RequestItem.fromJson(item)).toList();
  //   } catch (e) {
  //     print('[ERROR] fetchJoinedRequests 오류: $e');
  //     return [];
  //   }
  // // 구조:   {"is_participating":false,"data":[{"request_id":19,"vehicle_number":"10나1010","situation":"어쩌고\n어쩌고\n어쩌고\n어쩌고","location":"서울 금천구 독산동","latitude":"37.4681432","longitude":"126.8993930","workers":10,"duration":60,"start_time":"2025-01-22T11:06:00.000Z","joined_workers":0,"joined_usernames":[{"user_id":-1,"name":"Unknown","latitude":0,"longitude":0,"distance":null,"status":"unknown","task_status":"notStarted"}],"is_participating":false},{"request_id":20,"vehicle_number":"023","situation":"023","location":"서울 금천구 독산동","latitude":"37.4681432","longitude":"126.8993930","workers":2,"duration":2,"start_time":"2025-01-23T10:47:00.000Z","joined_workers":1,"joined_usernames":[{"user_id":30296,"name":"이세진","latitude":37.4665917,"longitude":126.8880783,"distance":1.01,"status":"progress","task_status":"notStarted"}],"is_participating":false}]}
  // }
  // 전체 요청 데이터 가져오기
  static Future<List<RequestItem>> fetchAllRequests(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/ast_req_info?user_id=$userId'));
    final data = _processResponse(response);
    final List<dynamic> requests = data['data'] ?? [];
    return requests.map((item) => RequestItem.fromJson(item)).toList();
  }
  // static Future<List<RequestItem>> fetchAllRequests(String userId) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/api/ast_req_info?user_id=$userId'),
  //     );
  //     final data = _processResponse(response);
  //     final List<dynamic> requests = data['data'] ?? [];
  //     return requests.map((item) => RequestItem.fromJson(item)).toList();
  //   } catch (e) {
  //     print('[ERROR] fetchAllRequests 오류: $e');
  //     return [];
  //   }
  //   //[{"id":19,"vehicle_number":"10나1010","situation":"어쩌고\n어쩌고\n어쩌고\n어쩌고","text_info1":null,"text_info2":null,"text_info3":null,"location":"서울 금천구 독산동","latitude":"37.4681432","longitude":"126.8993930","workers":10,"joined_workers":0,"duration":60,"start_time":"2025-01-22T11:06:00.000Z","progress_status":"Pending","created_at":"2025-01-23T05:06:53.000Z","updated_at":"2025-01-23T05:06:53.000Z","reporter":"신고자","reporter_phone":"010-1900-1199","received_date":"2025-02-13T15:00:00.000Z","completed_date":null,"reception_type":"접1","transport_company":"00운수","driving_distance":null,"manufacturer_number":null,"repair_type":null,"operation_status":null,"title":null,"issue_description":null,"same_issue_history":0,"fault_category":null,"fault_part":null,"fault_code_category":null,"fault_code":null,"repair_description":null,"material_numbers":null,"material_quantities":null,"repair_person":null,"company_person":null,"claim":null,"claim_status":null,"is_user_joined":0,"joined_usernames":null,"is_closed":0},{"id":20,"vehicle_number":"023","situation":"023","text_info1":null,"text_info2":null,"text_info3":null,"location":"서울 금천구 독산동","latitude":"37.4681432","longitude":"126.8993930","workers":2,"joined_workers":1,"duration":2,"start_time":"2025-01-23T10:47:00.000Z","progress_status":"Pending","created_at":"2025-01-24T04:48:04.000Z","updated_at":"2025-01-24T04:48:04.000Z","reporter":"0","reporter_phone":"023","received_date":"2025-01-23T15:00:00.000Z","completed_date":null,"reception_type":"접1","transport_company":"023","driving_distance":null,"manufacturer_number":null,"repair_type":null,"operation_status":null,"title":null,"issue_description":null,"same_issue_history":0,"fault_category":null,"fault_part":null,"fault_code_category":null,"fault_code":null,"repair_description":null,"material_numbers":null,"material_quantities":null,"repair_person":null,"company_person":null,"claim":null,"claim_status":null,"is_user_joined":0,"joined_usernames":"{\"name\": \"이세진\", \"user_id\": 30296, \"latitude\": 37.46659170, \"longitude\": 126.88807830, \"distance\": 1.0133741377604066},{\"name\": \"이세진\", \"user_id\": 30296, \"latitude\": 37.46659170, \"longitude\": 126.88807830, \"distance\": 1.0133741377604066}","is_closed":0}]
  // }

  static Map<String, String> getHeaders() {
    return {'Content-Type': 'application/json'};
  }

  static Future<void> loadUserData(UserProvider userProvider) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final email = prefs.getString('email');
    final id = prefs.getString('id');

    if (id == null) {
      throw Exception('[ERROR] User ID is null');
    }

    userProvider.setUser({
      'username': username,
      'email': email,
      'id': id,
    });
  }
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$loginUrl/apilogin');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('로그인 중 오류 발생: $e');
    }
  }


  static Future<RequestItem> fetchRequestDetails(int reqId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/req_info/$reqId'));

      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          return RequestItem.fromJson(data);
        } else {
          throw Exception('[ERROR] Invalid data type: ${data.runtimeType}');
        }
      } else {
        throw Exception('Failed to fetch request details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('[ERROR] Error fetching request details: $e');
    }
  }
  // 공통 응답 처리
  static dynamic _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }



  // Future<List<RequestItem>> fetchJoinedRequests(String userId) async {
  //   try {
  //     print('[DEBUG] fetchJoinedRequests 호출 - userId: $userId');
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/api/ast_req_info?user_id=$userId'),
  //     );
  //
  //     print('[DEBUG] fetchJoinedRequests 응답 상태 코드: ${response.statusCode}');
  //     print('[DEBUG] fetchJoinedRequests 응답 본문: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //
  //       if (data == null || data.isEmpty) {
  //         print('[DEBUG] 응답 데이터가 비어 있습니다.');
  //         return [];
  //       }
  //
  //       // JSON 배열인지 확인 후 파싱
  //       if (data is List) {
  //         return data.map((item) {
  //           try {
  //             return _parseRequestItem(item);
  //           } catch (e) {
  //             print('[DEBUG] RequestItem 파싱 오류: $e');
  //             return RequestItem.empty();
  //           }
  //         }).toList();
  //       } else {
  //         print('[DEBUG] 데이터가 배열 형식이 아닙니다.');
  //         return [];
  //       }
  //     } else {
  //       throw Exception('Failed to load joined requests: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('[DEBUG] fetchJoinedRequests 오류: $e');
  //     throw Exception('Error: $e');
  //   }
  // }

  /// 요청 항목 파싱
  static Future<List<RequestItem>> fetchRequests(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/api/ast_req_info?user_id=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((json) {
          return RequestItem.fromJson(json as Map<String, dynamic>);
        }).toList();
      } else {
        throw Exception('Failed to fetch requests: ${response.statusCode}');
      }
    } catch (e) {
      print('[ERROR] fetchRequests 오류: $e');
      return [];
    }
  }

  static Future<void> createRequest(Map<String, dynamic> requestData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/req_info/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      print('createRequest 응답 상태 코드: ${response.statusCode}');
      print('createRequest 응답 본문: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to create request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating request: $e');
      throw Exception('요청 생성 실패: $e');
    }
  }
  static Future<void> updateRequestStatus(int reqId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/update_status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'req_id': reqId, 'status': status}),
      );

      print('updateRequestStatus 응답 상태 코드: ${response.statusCode}');
      print('updateRequestStatus 응답 본문: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update request status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating request status: $e');
      throw Exception('요청 상태 업데이트 실패: $e');
    }
  }
  static Future<List<RequestItem>> fetchNearbyRequests(String userId, double maxDistance) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/nearby_requests?user_id=$userId&max_distance=$maxDistance'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => RequestItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch nearby requests: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching nearby requests: $e');
      throw Exception('Error: $e');
    }
  }
  static Future<void> updateLocation(String userId, double latitude, double longitude) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/update_location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        print('[ApiService] 위치 업데이트 성공');
      } else {
        print('[ApiService] 위치 업데이트 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('[ApiService] 위치 업데이트 오류: $e');
    }
  }

  static Future<List<RequestItem>> fetchRequestList(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/requests?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final requests = (data['data'] as List<dynamic>).map((item) {
          item['is_participating'] = convertToBool(item['is_participating']);
          return RequestItem.fromJson(item);
        }).toList();
        print(' data :  $data');
        print('requests : $requests');

        return requests;
      } else {
        throw Exception('Failed to fetch request list: ${response.statusCode}');
      }
    } catch (e) {
      print('[ERROR] fetchRequestList 오류: $e');
      return [];
    }
  }


  // 참여자 데이터를 가져오는 메서드
  static Future<List<Map<String, dynamic>>> fetchParticipants(int requestId) async {
    final url = Uri.parse('$baseUrl/api/participant_distances?req_id=$requestId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // 서버에서 받아온 데이터 디코딩
      final List<dynamic> data = jsonDecode(response.body);

      // 데이터를 맵 형식으로 변환
      return data.map<Map<String, dynamic>>((participant) {
        return {
          'user_id': participant['user_id'],
          'name': participant['name'],
          'distance': participant['distance'],
          'status': participant['participant_status'], // 상황 정보
          'event_location': participant['request_location'], // 요청 위치 주소
        };
      }).toList();
    } else {
      throw Exception('참여자 데이터를 불러오는 데 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  }
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.locality ?? ''} ${place.subLocality ?? ''} ${place.street ?? ''}';
      }
      return '주소를 찾을 수 없습니다.';
    } catch (e) {
      print('주소 변환 오류: $e');
      return '주소 변환 실패';
    }
  }

  static Future<Map<String, dynamic>> joinRequest(int reqId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/join'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'req_id': reqId, 'user_id': userId}),
      );

      print('joinRequest 응답 상태 코드: ${response.statusCode}');
      print('joinRequest 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        // 응답 데이터를 JSON으로 디코딩하여 반환
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('서버에서 참여 요청 처리 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('joinRequest 오류: $e');
      throw Exception('참여 요청 실패: $e');
    }
  }

  static Future<void> updateTaskStatus(
      int reqId, String userId, String status) async {
    await http.post(
      Uri.parse('$baseUrl/api/update_status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'req_id': reqId, 'user_id': userId, 'status': status}),
    );
  }
}

class UserProvider with ChangeNotifier {
  String? username;
  String? email;
  String? id;

  void setUser(Map<String, String?> user) {
    username = user['username'];
    email = user['email'];
    id = user['id'];
    notifyListeners();
  }

  bool get isUserLoggedIn => id != null;
}
bool convertToBool(dynamic value) {
  if (value is bool) return value; // 이미 bool인 경우
  if (value is int) return value == 1; // 1이면 true
  if (value is String) {
    final lowerValue = value.toLowerCase();
    return lowerValue == 'true' || lowerValue == '1';
  }
  return false; // 기본값
}