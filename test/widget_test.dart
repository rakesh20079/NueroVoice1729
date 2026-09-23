import 'package:flutter_test/flutter_test.dart';
import 'package:neurovoice/main.dart';
import 'package:neurovoice/models/screening_state.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('NeuroVoice app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ScreeningSessionProvider()),
        ],
        child: const NeuroVoiceApp(),
      ),
    );

    // Verify brand title and hero screening prompt are rendered
    expect(find.text('NeuroVoice'), findsWidgets);
    expect(find.text("Parkinson's voice screening"), findsOneWidget);
    expect(find.text('Start screening'), findsOneWidget);
  });
}
