# Lab 1 PAM — Calculator consum combustibil

Aplicație Flutter care calculează consumul mediu de combustibil al unui
automobil și costul final al combustibilului cu reducere aplicată.

## Funcționalități

**1. Consum mediu**
- Introducerea distanței parcurse (km) și a combustibilului consumat (litri)
- Calcul după formula `(litri / km) * 100` → rezultat în L/100 km
- Validare: ambele valori trebuie să fie numerice și mai mari decât 0

**2. Cost și reducere**
- Introducerea prețului per litru (MDL)
- Reducere presetată din meniu derulant (0%, 5%, 10%, 15%, 20%, 25%)
- Sau reducere manuală, activată prin bifă, validată în intervalul 0–100%
- Afișează prețul inițial, reducerea per litru, prețul final per litru,
  iar dacă sunt completate și litrii — costul total și distanța parcursă

## Widget-uri folosite

`MaterialApp`, `Scaffold`, `AppBar`, `SingleChildScrollView`, `Column`, `Row`,
`Card`, `Padding`, `SizedBox`, `Container`, `TextField` cu `TextEditingController`,
`DropdownButton`, `Checkbox`, `ElevatedButton.icon`, `Text`, `Icon`.

Aplicația este structurată pe un `StatelessWidget` (configurarea temei) și un
`StatefulWidget` cu starea calculelor, actualizată prin `setState()`.

## Rulare

```bash
flutter pub get
flutter run
```

## Verificare

```bash
flutter analyze   # fără erori de lint
flutter test      # 6 teste de widget
```

## Structură

```
lib/main.dart          — întreaga aplicație (UI + logica de calcul)
test/widget_test.dart  — teste de widget pentru ambele fluxuri
```
