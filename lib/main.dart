import 'package:flutter/material.dart';
import 'package:flutter_matrix_example/login_page.dart';
import 'package:flutter_matrix_example/room_list_page.dart';
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create the Client instance, configure the database and init it. This will
  // already look up for an existing session and restore it.
  final client = Client(
    'Flutter Matrix Example',
    databaseBuilder: (client) async {
      final dir = await getApplicationSupportDirectory();
      final db = MatrixSdkDatabase(
        client.clientName,
        database: await openDatabase('${dir.path}/${client.clientName}.sqlite'),
        fileStorageLocation: (await getTemporaryDirectory()).uri,
      );
      await db.open();
      return db;
    },
  );
  await client.init(waitForFirstSync: false);

  // Start the Flutter app now!
  runApp(MatrixExampleChat(client: client));
}

/// Widget representing the app itself. Holds the client object in it:
class MatrixExampleChat extends StatelessWidget {
  final Client client;
  const MatrixExampleChat({required this.client, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: client.clientName,
      home: client.isLogged()
          ? RoomListPage(client: client)
          : LoginPage(client: client),
    );
  }
}
