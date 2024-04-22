import 'package:flutter/material.dart';
import 'package:flutter_matrix_example/login_page.dart';
import 'package:flutter_matrix_example/room_page.dart';
import 'package:matrix/matrix.dart';

class RoomListPage extends StatefulWidget {
  final Client client;
  const RoomListPage({required this.client, super.key});

  @override
  RoomListPageState createState() => RoomListPageState();
}

class RoomListPageState extends State<RoomListPage> {
  /// Calls the logout method and routes back to the LoginPage
  void _logout() async {
    final navigator = Navigator.of(context);
    final client = widget.client;
    await client.logout();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage(client: client)),
      (route) => false,
    );
  }

  /// Tries to join a room and routes to it if successful
  void _join(Room room) async {
    if (room.membership != Membership.join) {
      await room.join();
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoomPage(room: room),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.client;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: client.onSync.stream,
        builder: (context, _) => ListView.builder(
          itemCount: client.rooms.length,
          itemBuilder: (context, i) => ListTile(
            leading: CircleAvatar(
              foregroundImage: client.rooms[i].avatar == null
                  ? null
                  : NetworkImage(client.rooms[i].avatar!
                      .getThumbnail(
                        client,
                        width: 56,
                        height: 56,
                      )
                      .toString()),
            ),
            title: Row(
              children: [
                Expanded(
                    child: Text(client.rooms[i].getLocalizedDisplayname())),
                if (client.rooms[i].notificationCount > 0)
                  Material(
                      borderRadius: BorderRadius.circular(99),
                      color: Theme.of(context).colorScheme.primary,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 2.0,
                        ),
                        child: Text(
                          client.rooms[i].notificationCount.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ))
              ],
            ),
            subtitle: Text(
              client.rooms[i].lastEvent?.calcLocalizedBodyFallback(
                      const MatrixDefaultLocalizations()) ??
                  'No messages',
              maxLines: 1,
            ),
            onTap: () => _join(client.rooms[i]),
          ),
        ),
      ),
    );
  }
}
