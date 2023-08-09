import 'package:carpool_app/main/post_detail_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

import 'package:carpool_app/app_state.dart';
import 'package:carpool_app/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../cheng/mock.dart';

void main() {
  Widget createWidgetForTesting() {
    return const MaterialApp(
        title: 'Post Detail Page',
        home: PostDetailPage(postId: '2gd0zpOXVoFmcnEz6KaY'));
  }

  testWidgets('post detail page ...', (tester) async {
    // TODO: Implement test
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
    await tester.pumpWidget(createWidgetForTesting());

    expect(find.text('Post Detail Page'), findsOneWidget);
    // expect(find.byKey(Key("Host")), findsOneWidget);
  });
}
