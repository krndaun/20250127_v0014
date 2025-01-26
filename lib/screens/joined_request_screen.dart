import 'package:flutter/material.dart';
import 'package:nesysworks/models/JoinedRequestItem.dart';
import 'package:nesysworks/models/request_item.dart';
import 'package:nesysworks/widgets/ActionButton.dart';
import 'package:nesysworks/widgets/ParticipantList.dart';
import 'package:nesysworks/services/api_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class JoinedRequestScreen extends StatefulWidget {
  final String userId; // 사용자 ID
  final IO.Socket? socket;
  final double maxDistance;
  final RequestItem joinedRequest; // 참여 요청 데이터
  final List<Map<String, dynamic>> participants;

  const JoinedRequestScreen({
    required this.userId,
    this.socket,
    required this.maxDistance,
    required this.joinedRequest,
    required this.participants,
    Key? key,
  }) : super(key: key);

  @override
  _JoinedRequestScreenState createState() => _JoinedRequestScreenState();
}

class _JoinedRequestScreenState extends State<JoinedRequestScreen> {
  late Future<RequestItem?> _joinedRequestFuture;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _joinedRequestFuture = _fetchJoinedRequest(); // Future를 초기화
  }

  Future<JoinedRequestItem?> _fetchJoinedRequest() async {
    try {
      final response = await ApiService.fetchJoinedRequests(widget.userId);
      if (response != null) {
        print('[DEBUG] JoinedRequestScreen 응답: $response');
        return JoinedRequestItem.fromJson(response as Map<String, dynamic>);
      }
    } catch (e) {
      print('[ERROR] 데이터 가져오기 실패: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('참여 정보')),
      body: FutureBuilder<RequestItem?>(
        future: _joinedRequestFuture, // 이미 초기화된 Future 사용
        builder: (context, snapshot) {
          print('[DEBUG] FutureBuilder 상태: ${snapshot.connectionState}');
          print('[DEBUG] FutureBuilder 데이터: ${snapshot.data?.toJson()}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('[ERROR] FutureBuilder 에러: ${snapshot.error}');
            return const Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            print('[DEBUG] 참여 요청 데이터가 없습니다.');
            return const Center(child: Text('참여 요청 데이터가 없습니다.'));
          }

          final joinedRequest = snapshot.data!;
          print('[DEBUG] 참여 요청 데이터: ${joinedRequest.toJson()}');
          print('[DEBUG] 참여자 세부 정보: ${joinedRequest.participantDetails}');

          if (joinedRequest.participantDetails.isEmpty) {
            return const Center(child: Text('참여 요청의 참여자가 없습니다.'));
          }

          return ListView.builder(
            itemCount: joinedRequest.participantDetails.length,
            itemBuilder: (context, index) {
              final participant = joinedRequest.participantDetails[index];
              return ListTile(
                title: Text(participant['name'] ?? '알 수 없음'),
                subtitle: Text('거리: ${(participant['distance'] ?? 0).toStringAsFixed(2)} km'),
              );
            },
          );
        },
      )
    );
  }
}