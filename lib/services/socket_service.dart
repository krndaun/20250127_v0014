import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:nesysworks/models/request_item.dart';

class SocketManager {
  final IO.Socket socket;

  SocketManager(this.socket);

  void initialize(Function(dynamic data) onUpdate) {
    socket.onConnect((_) => print('[DEBUG] 소켓 연결 성공'));
    socket.onDisconnect((_) => print('[DEBUG] 소켓 연결 종료'));
    socket.on('update_request', onUpdate);
    socket.connect();
  }

  void dispose() {
    socket.disconnect();
    socket.dispose();
  }
}

class SocketService extends ChangeNotifier { // ChangeNotifier 추가
  static final SocketService _instance = SocketService._internal();
  IO.Socket? _socket;

  factory SocketService() {
    return _instance;
  }
  SocketService._internal();

  void initializeSocket() {
    if (_socket != null) {
      print('[DEBUG] 소켓이 이미 초기화되었습니다.');
      return;
    }

    _socket = IO.io(
      'http://121.140.204.7:18988',
      {
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionAttempts': 10, // 재연결 시도 횟수
        'reconnectionDelay': 3000, // 재연결 딜레이
      },
    );

    // 연결 성공
    _socket?.onConnect((_) {
      print('[DEBUG] 소켓 연결 성공');
      _socket?.emit('ping', 'Client connected');
    });

    // 연결 종료
    _socket?.onDisconnect((_) {
      print('[DEBUG] 소켓 연결 끊김');
    });

    // 에러 핸들링
    _socket?.onError((error) {
      print('[ERROR] 소켓 에러 발생: $error');
    });

    // 연결 재시도
    _socket?.onReconnect((_) {
      print('[DEBUG] 소켓 재연결 성공');
    });

    _socket?.onReconnectAttempt((_) {
      print('[DEBUG] 소켓 재연결 시도 중...');
    });

    // 이벤트 처리 예시
    _socket?.on('update_request', (data) {
      print('[DEBUG] 수신된 요청 데이터: $data');
    });

    _socket?.connect();
  }

  void dispose() {
    _socket?.disconnect();
    _socket = null;
  }

  IO.Socket? get socket => _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String url) {
    _socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
  }

  void disconnectSocket() {
    _socket?.disconnect();
    print('[DEBUG] 소켓 연결 해제 요청');
  }


  void disconnect() {
    _socket?.disconnect();
    _socket = null; // 추가적으로 소켓을 null로 설정
  }

  void listenForRequestUpdates(Function(Map<String, dynamic>) onUpdate) {
    _socket?.on('update_request', (data) {
      try {
        final parsedData = Map<String, dynamic>.from(data);
        onUpdate(parsedData);
      } catch (e) {
        print('[ERROR] 요청 업데이트 처리 중 오류: $e');
      }
    });
  }

  void joinRequest(int reqId, String userId) {
    _socket?.emit('join', {'reqId': reqId, 'userId': userId});
  }

  void leaveRequest(int reqId, String userId) {
    _socket?.emit('leave', {'reqId': reqId, 'userId': userId});
  }


  /// 실시간 요청 업데이트 이벤트 수신
  void listenForUpdates(Function(Map<String, dynamic>) onUpdate) {
    socket?.on('update_request', (data) {
      try {
        // 데이터 변환
        final parsedData = Map<String, dynamic>.from(data);
        parsedData['joined_usernames'] = _normalizeParticipants(parsedData['joined_usernames']);

        onUpdate(parsedData);
      } catch (e) {
        print('[ERROR] Failed to process socket data: $e');
      }
    });
  }
  void listenForParticipation(Function(bool) onParticipationUpdate) {
    _socket?.on('update_participation', (data) {
      try {
        final isParticipating = data['is_participating'] as bool;
        onParticipationUpdate(isParticipating);
      } catch (e) {
        print('[SOCKET] 참여 상태 업데이트 오류: $e');
      }
    });
  }

  List<Map<String, dynamic>> _normalizeParticipants(dynamic data) {
    if (data == null) return [];
    try {
      if (data is String) {
        return (jsonDecode(data) as List).map((item) => Map<String, dynamic>.from(item)).toList();
      } else if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      print('[ERROR] Failed to normalize participants: $e');
    }
    return [];
  }
  /// 상태 업데이트 이벤트 전송
  void emitStatusUpdate(int reqId, String status) {
    socket?.emit('update_status', {'reqId': reqId, 'status': status});
  }

  // /// 요청 참여 이벤트 전송
  // void joinRequest(String reqId, String userId) {
  //   socket?.emit('join', {'reqId': reqId, 'userId': userId});
  //   notifyListeners(); // UI 갱신 알림
  // }
  //
  // /// 요청 나가기 이벤트 전송
  // void leaveRequest(String reqId, String userId) {
  //   socket?.emit('leave', {'reqId': reqId, 'userId': userId});
  //   notifyListeners(); // UI 갱신 알림
  // }



}