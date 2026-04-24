import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final String createdAt;
  final String senderName;

  ChatMessage({required this.id, required this.roomId, required this.senderId, required this.content, required this.createdAt, this.senderName = ''});

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id']?.toString() ?? '',
        roomId: json['room_id']?.toString() ?? '',
        senderId: json['sender_id']?.toString() ?? '',
        content: json['content'] ?? '',
        createdAt: json['created_at'] ?? '',
        senderName: json['sender']?['name'] ?? '',
      );
}

class ChatRoom {
  final String id;
  final String name;
  final String type;
  final List<dynamic> members;

  ChatRoom({required this.id, required this.name, this.type = '', this.members = const []});

  factory ChatRoom.fromJson(Map<String, dynamic> json) => ChatRoom(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        type: json['type'] ?? '',
        members: json['members'] ?? [],
      );
}

class ChatProvider extends ChangeNotifier {
  List<ChatRoom> rooms = [];
  List<dynamic> users = [];
  Map<String, List<ChatMessage>> messages = {};
  String? activeRoomId;
  WebSocketChannel? _channel;
  bool loading = false;

  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<void> fetchRooms(String userId) async {
    loading = true;
    notifyListeners();
    try {
      final res = await _dio.get('/chat/rooms/$userId');
      rooms = ((res.data['data'] ?? []) as List).map((e) => ChatRoom.fromJson(e)).toList();
    } catch (_) {}
    loading = false;
    notifyListeners();
  }

  Future<void> fetchUsers() async {
    try {
      final res = await _dio.get('/chat/users');
      users = res.data['data'] ?? [];
    } catch (_) {}
    notifyListeners();
  }

  Future<void> fetchMessages(String roomId) async {
    try {
      final res = await _dio.get('/chat/messages/$roomId');
      messages[roomId] = ((res.data['data'] ?? []) as List).map((e) => ChatMessage.fromJson(e)).toList();
    } catch (_) {}
    notifyListeners();
  }

  Future<String?> createRoom(String name, String type, List<String> userIds) async {
    try {
      final res = await _dio.post('/chat/rooms', data: {'name': name, 'type': type, 'target_user_id': userIds.first});
      final newRoom = ChatRoom.fromJson(res.data['data']);
      if (!rooms.any((r) => r.id == newRoom.id)) {
        rooms.insert(0, newRoom);
      }
      notifyListeners();
      return newRoom.id;
    } catch (_) {
      return null;
    }
  }

  void connect(String userId) {
    if (_channel != null) return;
    final wsUrl = '${ApiConfig.wsBase}?user_id=$userId';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _channel!.stream.listen((event) {
      final data = jsonDecode(event);
      if (data['id'] != null) {
        final msg = ChatMessage.fromJson(data);
        messages[msg.roomId] = [...(messages[msg.roomId] ?? []), msg];
        notifyListeners();
      }
    }, onDone: () {
      _channel = null;
      Future.delayed(const Duration(seconds: 3), () => connect(userId));
    });
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void sendMessage(String roomId, String content) {
    _channel?.sink.add(jsonEncode({'type': 'message', 'room_id': roomId, 'content': content}));
  }

  void setActiveRoom(String roomId) {
    activeRoomId = roomId;
    _channel?.sink.add(jsonEncode({'type': 'join', 'room_id': roomId}));
    notifyListeners();
  }
}
