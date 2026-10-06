// Teste de widget pentru calculatorul de consum de combustibil.
//
// Verifică cele două fluxuri principale ale aplicației: calculul consumului
// mediu (L/100 km) și calculul prețului final cu reducere.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab_1_pam/main.dart';

/// Pornește aplicația pe o suprafață înaltă, ca ambele carduri să fie
/// vizibile fără derulare (viewportul implicit de test este doar 800x600).
Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1000, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const FuelCalculatorApp());
}

void main() {
  testWidgets('Ecranul principal afișează ambele secțiuni', (WidgetTester tester) async {
    await pumpApp(tester);

    expect(find.text('Calculator consum combustibil'), findsOneWidget);
    expect(find.text('1. Consum Mediu Automobil'), findsOneWidget);
    expect(find.text('2. Calcul Cost & Reducere'), findsOneWidget);
  });

  testWidgets('Calculează consumul mediu la 100 km', (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField).at(0), '250');
    await tester.enterText(find.byType(TextField).at(1), '20');

    await tester.tap(find.text('Calculează Consumul'));
    await tester.pump();

    // (20 / 250) * 100 = 8.00 L/100 km
    expect(find.text('Consum mediu: 8.00 L/100 km'), findsOneWidget);
  });

  testWidgets('Afișează mesaj de eroare pentru valori invalide', (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField).at(0), '0');
    await tester.enterText(find.byType(TextField).at(1), 'abc');

    await tester.tap(find.text('Calculează Consumul'));
    await tester.pump();

    expect(
      find.text('Vă rugăm să introduceți valori numerice valide (> 0).'),
      findsOneWidget,
    );
  });

  testWidgets('Calculează prețul final fără reducere', (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField).at(2), '25');

    await tester.tap(find.text('Calculează Prețul Final & Cost Total'));
    await tester.pump();

    expect(find.textContaining('Preț final/L: 25.00 MDL'), findsOneWidget);
  });

  testWidgets('Aplică reducerea selectată din dropdown și costul total', (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField).at(1), '10'); // litri
    await tester.enterText(find.byType(TextField).at(2), '20'); // preț/litru

    // Alege 10% din meniul derulant.
    await tester.tap(find.byType(DropdownButton<double>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10%').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calculează Prețul Final & Cost Total'));
    await tester.pump();

    // 20 MDL - 10% = 18 MDL/L; 10 L * 18 MDL = 180 MDL
    expect(find.textContaining('Preț final/L: 18.00 MDL'), findsOneWidget);
    expect(find.textContaining('Cost total combustibil (10.0 L): 180.00 MDL'), findsOneWidget);
  });

  testWidgets('Reducerea manuală peste 100% este respinsă', (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField).at(2), '20');

    // Activează reducerea manuală.
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    await tester.enterText(find.byType(TextField).last, '150');

    await tester.tap(find.text('Calculează Prețul Final & Cost Total'));
    await tester.pump();

    expect(find.text('Procentul trebuie să fie între 0% și 100%.'), findsOneWidget);
  });
}
