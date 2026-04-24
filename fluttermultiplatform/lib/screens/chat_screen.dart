import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../config/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/shared_widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final chat = context.read<ChatProvider>();
    if (auth.user != null) {
      chat.connect(auth.user!.id);
      chat.fetchRooms(auth.user!.id);
      chat.fetchUsers();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final chat = context.watch<ChatProvider>();
    final loc = context.watch<AppLocalizations>();
    final userId = auth.user?.id;
    final activeMessages = chat.activeRoomId != null ? (chat.messages[chat.activeRoomId!] ?? []) : [];
    _scrollToBottom();

    return SizedBox(
      height: MediaQuery.of(context).size.height - 180,
      child: Row(
        children: [
          // Room list
          SizedBox(
            width: 300,
            child: Card(
              child: Column(
                children: [
                  Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [const Icon(Icons.chat_rounded, size: 20), const SizedBox(width: 8), Text(loc.t('chat.messages'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                    IconButton(
                      onPressed: () => _showUserModal(context, auth, chat, loc),
                      icon: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: CronosColors.primary50, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add, size: 18, color: CronosColors.primary600)),
                    ),
                  ])),
                  const Divider(height: 1),
                  Expanded(
                    child: chat.rooms.isEmpty
                        ? Center(child: Text(loc.t('chat.no_rooms'), style: const TextStyle(color: CronosColors.gray400, fontSize: 13)))
                        : ListView.separated(
                            itemCount: chat.rooms.length,
                            separatorBuilder: (_, _) => const Divider(height: 1, color: CronosColors.gray100),
                            itemBuilder: (_, i) {
                              final room = chat.rooms[i];
                              final isActive = chat.activeRoomId == room.id;
                              String displayName = room.name;
                              if (room.type == 'private') {
                                final other = room.members.firstWhere((m) => m['id'] != userId, orElse: () => {'name': room.name});
                                displayName = other['name'] ?? room.name;
                              }
                              return ListTile(
                                selected: isActive,
                                selectedTileColor: CronosColors.primary50,
                                leading: CircleAvatar(backgroundColor: CronosColors.ocean100, child: const Icon(Icons.person, color: CronosColors.ocean600, size: 20)),
                                title: Text(displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                                subtitle: Text(room.type, style: TextStyle(fontSize: 11, color: CronosColors.gray500)),
                                onTap: () { chat.setActiveRoom(room.id); chat.fetchMessages(room.id); },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Chat area
          Expanded(
            child: Card(
              child: chat.activeRoomId != null
                  ? Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(color: CronosColors.gray50, border: Border(bottom: BorderSide(color: CronosColors.gray200))),
                          child: Row(children: [
                            CircleAvatar(radius: 16, backgroundColor: CronosColors.primary50, child: const Icon(Icons.person, size: 16, color: CronosColors.primary600)),
                            const SizedBox(width: 10),
                            Text(_getActiveName(chat, userId), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ]),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.all(20),
                            itemCount: activeMessages.length,
                            itemBuilder: (_, i) {
                              final msg = activeMessages[i];
                              final isMe = msg.senderId == userId;
                              return Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
                                  decoration: BoxDecoration(
                                    color: isMe ? CronosColors.primary600 : CronosColors.gray100,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16),
                                    ),
                                  ),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    if (!isMe) Text(msg.senderName, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isMe ? Colors.white70 : CronosColors.gray500)),
                                    Text(msg.content, style: TextStyle(fontSize: 14, color: isMe ? Colors.white : CronosColors.gray800)),
                                    const SizedBox(height: 2),
                                    Align(alignment: Alignment.centerRight, child: Text(_formatTime(msg.createdAt), style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : CronosColors.gray400))),
                                  ]),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(color: CronosColors.gray50, border: Border(top: BorderSide(color: CronosColors.gray200))),
                          child: Row(children: [
                            Expanded(child: TextField(controller: _msgCtrl, onSubmitted: (_) => _send(chat), decoration: InputDecoration(hintText: loc.t('chat.placeholder')))),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: () => _send(chat), style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(14)), child: const Icon(Icons.send, size: 20)),
                          ]),
                        ),
                      ],
                    )
                  : EmptyState(title: loc.t('chat.select_title'), message: loc.t('chat.select_msg')),
            ),
          ),
        ],
      ),
    );
  }

  String _getActiveName(ChatProvider chat, String? userId) {
    final room = chat.rooms.firstWhere((r) => r.id == chat.activeRoomId, orElse: () => ChatRoom(id: '', name: 'Chat'));
    if (room.type == 'private') {
      final other = room.members.firstWhere((m) => m['id'] != userId, orElse: () => {'name': room.name});
      return other['name'] ?? room.name;
    }
    return room.name;
  }

  void _send(ChatProvider chat) {
    if (_msgCtrl.text.trim().isEmpty || chat.activeRoomId == null) return;
    chat.sendMessage(chat.activeRoomId!, _msgCtrl.text);
    _msgCtrl.clear();
  }

  String _formatTime(String s) { try { return DateFormat('HH:mm').format(DateTime.parse(s).toLocal()); } catch (_) { return ''; } }

  void _showUserModal(BuildContext context, AuthProvider auth, ChatProvider chat, AppLocalizations loc) {
    showDialog(context: context, builder: (ctx) {
      String search = '';
      return StatefulBuilder(builder: (ctx, setS) {
        final filtered = chat.users.where((u) => u['id'] != auth.user?.id && (u['name'].toString().toLowerCase().contains(search.toLowerCase()) || u['role'].toString().toLowerCase().contains(search.toLowerCase()))).toList();
        final grouped = <String, List<dynamic>>{};
        for (final u in filtered) { (grouped[u['role']] ??= []).add(u); }
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 500),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(padding: const EdgeInsets.fromLTRB(20, 16, 12, 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(loc.t('chat.start_new'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ])),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: TextField(onChanged: (v) => setS(() => search = v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search, size: 20), hintText: loc.t('chat.search_users')))),
              const SizedBox(height: 8),
              Flexible(child: ListView(padding: const EdgeInsets.all(16), children: ['petambak', 'logistik', 'konsumen'].map((role) {
                final usersInRole = grouped[role] ?? [];
                if (usersInRole.isEmpty) return const SizedBox.shrink();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(role.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CronosColors.gray400, letterSpacing: 1.5))),
                  ...usersInRole.map((u) => Card(child: ListTile(
                    leading: CircleAvatar(backgroundColor: CronosColors.primary50, child: const Icon(Icons.person, size: 18, color: CronosColors.primary600)),
                    title: Text(u['name'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text(u['email'] ?? '', style: TextStyle(fontSize: 10, color: CronosColors.gray500)),
                    onTap: () async {
                      final roomId = await chat.createRoom(u['name'], 'private', [auth.user!.id, u['id']]);
                      if (roomId != null) { chat.setActiveRoom(roomId); chat.fetchMessages(roomId); }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ))),
                ]);
              }).toList())),
            ]),
          ),
        );
      });
    });
  }
}
