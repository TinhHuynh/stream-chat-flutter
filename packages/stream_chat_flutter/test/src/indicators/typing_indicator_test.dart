import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../mocks.dart';

void main() {
  testWidgets(
    'it should show channel typing',
    (WidgetTester tester) async {
      final client = MockClient();
      final clientState = MockClientState();
      final channel = MockChannel();
      final channelState = MockChannelState();
      final lastMessageAt = DateTime.parse('2020-06-22 12:00:00');

      when(() => client.state).thenReturn(clientState);
      when(() => clientState.currentUser).thenReturn(OwnUser(id: 'user-id'));
      when(() => channel.lastMessageAt).thenReturn(lastMessageAt);
      when(() => channel.state).thenReturn(channelState);
      when(() => channel.client).thenReturn(client);
      when(() => channel.isMuted).thenReturn(false);
      when(() => channel.isMutedStream).thenAnswer((i) => Stream.value(false));
      when(() => channel.extraDataStream).thenAnswer(
        (i) => Stream.value({
          'name': 'test',
        }),
      );
      when(() => channel.extraData).thenReturn({
        'name': 'test',
      });
      when(() => channelState.membersStream).thenAnswer(
        (i) => Stream.value([
          Member(
            userId: 'user-id',
            user: User(id: 'user-id'),
          )
        ]),
      );
      when(() => channelState.members).thenReturn([
        Member(
          userId: 'user-id',
          user: User(id: 'user-id'),
        ),
      ]);
      when(() => channelState.messages).thenReturn([
        Message(
          text: 'hello',
          user: User(id: 'other-user'),
        )
      ]);
      when(() => channelState.messagesStream).thenAnswer(
        (i) => Stream.value([
          Message(
            text: 'hello',
            user: User(id: 'other-user'),
          )
        ]),
      );

      when(() => channelState.typingEvents).thenAnswer((i) => {
            User(id: 'other-user', extraData: const {'name': 'demo'}):
                Event(type: EventType.typingStart),
          });
      when(() => channelState.typingEventsStream).thenAnswer(
        (i) => Stream.value({
          User(id: 'other-user', extraData: const {'name': 'demo'}):
              Event(type: EventType.typingStart),
        }),
      );

      const typingKey = Key('typing');

      await tester.pumpWidget(MaterialApp(
        home: StreamChat(
          client: client,
          child: StreamChannel(
            channel: channel,
            child: const Scaffold(
              body: StreamTypingIndicator(
                key: typingKey,
              ),
            ),
          ),
        ),
      ));

      // wait for the initial state to be rendered.
      await tester.pump(Duration.zero);

      expect(find.byKey(typingKey), findsOneWidget);
      expect(find.byType(Flexible), findsOneWidget);
    },
  );
}
