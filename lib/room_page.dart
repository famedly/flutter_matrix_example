import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class RoomPage extends StatefulWidget {
  final Room room;
  const RoomPage({required this.room, super.key});

  @override
  RoomPageState createState() => RoomPageState();
}

class RoomPageState extends State<RoomPage> {
  late final Future<Timeline> _timelineFuture;

  @override
  void initState() {
    _timelineFuture = widget.room.getTimeline(onUpdate: () {
      setState(() {});
      debugPrint('On update');
    });
    super.initState();
  }

  final TextEditingController _sendController = TextEditingController();

  void _send() {
    widget.room.sendTextEvent(_sendController.text.trim());
    _sendController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.getLocalizedDisplayname()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<Timeline>(
                future: _timelineFuture,
                builder: (context, snapshot) {
                  final timeline = snapshot.data;
                  if (timeline == null) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  timeline.setReadMarker();
                  return Column(
                    children: [
                      Center(
                        child: TextButton(
                            onPressed: timeline.requestHistory,
                            child: const Text('Load more...')),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.builder(
                          reverse: true,
                          itemCount: timeline.events.length,
                          itemBuilder: (context, i) => timeline
                                      .events[i].relationshipEventId !=
                                  null
                              ? Container()
                              : Opacity(
                                  opacity: timeline.events[i].status.isSent
                                      ? 1
                                      : 0.5,
                                  child: timeline.events[i].type !=
                                          EventTypes.Message
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 4,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            timeline.events[i]
                                                .calcLocalizedBodyFallback(
                                              const MatrixDefaultLocalizations(),
                                            ),
                                            textAlign: TextAlign.center,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        )
                                      : ListTile(
                                          leading: CircleAvatar(
                                            foregroundImage: timeline
                                                        .events[i]
                                                        .senderFromMemoryOrFallback
                                                        .avatarUrl ==
                                                    null
                                                ? null
                                                : NetworkImage(timeline
                                                    .events[i]
                                                    .senderFromMemoryOrFallback
                                                    .avatarUrl!
                                                    .getThumbnail(
                                                      widget.room.client,
                                                      width: 56,
                                                      height: 56,
                                                    )
                                                    .toString()),
                                          ),
                                          title: Row(
                                            children: [
                                              Expanded(
                                                child: Text(timeline.events[i]
                                                    .senderFromMemoryOrFallback
                                                    .calcDisplayname()),
                                              ),
                                              Text(
                                                timeline
                                                    .events[i].originServerTs
                                                    .toIso8601String(),
                                                style: const TextStyle(
                                                    fontSize: 10),
                                              ),
                                            ],
                                          ),
                                          subtitle: Text(timeline.events[i]
                                              .getDisplayEvent(timeline)
                                              .body),
                                        ),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: _sendController,
                    decoration: const InputDecoration(
                      hintText: 'Send message',
                    ),
                  )),
                  IconButton(
                    icon: const Icon(Icons.send_outlined),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
