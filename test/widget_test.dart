import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homework_hunter/main.dart';

void main() {
  testWidgets('ホーム画面にステージ1が表示される', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: HomeworkHunterApp()),
    );
    await tester.pump();

    expect(find.textContaining('宿題ハンター'), findsOneWidget);
    expect(find.textContaining('漢字ゴブリンの罠'), findsOneWidget);
  });
}
