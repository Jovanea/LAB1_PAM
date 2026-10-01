import 'package:flutter/material.dart';

// Punctul de intrare în aplicație
void main() {
  runApp(const FuelCalculatorApp());
}

// 1. CLASA PRINCIPALĂ (StatelessWidget)
// Este doar "cadrul" sau configurarea generală a aplicației (tema, titlul).
// Nu își schimbă starea în timpul rulării.
class FuelCalculatorApp extends StatelessWidget {
  const FuelCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Ascunde eticheta de "DEBUG" din colț
      title: 'Calculator consum combustibil',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // Schema de culori
        useMaterial3: true, // Folosește design-ul modern Material 3
      ),
      home: const MainCalculatorScreen(), // Setează ecranul principal
    );
  }
}

// 2. CLASA ECRANULUI PRINCIPAL (StatefulWidget)
// Este un widget dinamic deoarece conține date care se modifică (starea).
class MainCalculatorScreen extends StatefulWidget {
  const MainCalculatorScreen({super.key});

  @override
  State<MainCalculatorScreen> createState() => _MainCalculatorScreenState();
}

// 3. CLASA DE STARE (_MainCalculatorScreenState)
// Aici se află toate variabilele, controllerele și logica de calcul.
class _MainCalculatorScreenState extends State<MainCalculatorScreen> {

  // --- CONTROLLER-E PENTRU CÂMPURILE DE TEXT ---
  // Preluau și gestionează textul introdus de utilizator în casetele TextField
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _fuelController = TextEditingController();
  final TextEditingController _pricePerLiterController = TextEditingController();
  final TextEditingController _discountTextController = TextEditingController();

  // --- VARIABILE PENTRU STARE (DATE DINAMICE) ---
  String _avgConsumptionResult = ''; // Rezultatul pentru consumul mediu (L/100km)
  double _selectedDiscountPercent = 0.0; // Procentul selectat din Dropdown (implicit 0%)
  bool _useCustomDiscount = false; // Starea Checkbox-ului (true dacă introducem reducere manuală)
  String _discountResult = ''; // Textul final cu rezultatele calculului de preț și reducere

  // --- LOGICA 1: CALCUL CONSUM MEDIU (L / 100 km) ---
  void _calculateFuelConsumption() {
    FocusScope.of(context).unfocus(); // Închide tastatura virtuală la apăsarea pe buton

    // Convertește textul în număr decimal (tryParse evită crash-ul dacă textul nu e număr)
    final double? distance = double.tryParse(_distanceController.text);
    final double? fuel = double.tryParse(_fuelController.text);

    // Validare: verificăm dacă numerele sunt valide și mai mari decât 0
    if (distance == null || fuel == null || distance <= 0 || fuel <= 0) {
      setState(() {
        _avgConsumptionResult = 'Vă rugăm să introduceți valori numerice valide (> 0).';
      });
      return;
    }

    // Formula matematică: (Litri consumați / Distanța în km) * 100
    final double avg = (fuel / distance) * 100;

    // setState() anunță Flutter să re-deseneze ecranul cu noul rezultat
    setState(() {
      _avgConsumptionResult = 'Consum mediu: ${avg.toStringAsFixed(2)} L/100 km';
    });
  }

  // --- LOGICA 2: CALCUL PREȚ FINAL ȘI COST TOTAL ---
  void _calculateDiscount() {
    FocusScope.of(context).unfocus(); // Închide tastatura

    final double? pricePerLiter = double.tryParse(_pricePerLiterController.text);
    final double? distance = double.tryParse(_distanceController.text);
    final double? fuel = double.tryParse(_fuelController.text);

    // Validăm prețul per litru
    if (pricePerLiter == null || pricePerLiter <= 0) {
      setState(() {
        _discountResult = 'Vă rugăm să introduceți un preț valid per litru.';
      });
      return;
    }

    // Stabilim procentul de reducere (din Dropdown sau din câmpul manual)
    double percent = _selectedDiscountPercent;
    if (_useCustomDiscount) {
      final double? customPercent = double.tryParse(_discountTextController.text);
      if (customPercent != null) {
        percent = customPercent;
      } else {
        setState(() {
          _discountResult = 'Introduceți un procent valid de reducere.';
        });
        return;
      }
    }

    // Validăm ca procentul să fie între 0% și 100%
    if (percent < 0 || percent > 100) {
      setState(() {
        _discountResult = 'Procentul trebuie să fie între 0% și 100%.';
      });
      return;
    }

    // Calculăm reducerea în bani pe litru și prețul final pe litru
    final double discountPerLiter = (pricePerLiter * percent) / 100;
    final double finalPricePerLiter = pricePerLiter - discountPerLiter;

    // Calculăm costul total al combustibilului dacă s-au completat și litrii
    String totalCostInfo = '';
    if (fuel != null && fuel > 0) {
      final double totalCost = fuel * finalPricePerLiter;
      totalCostInfo = '\nCost total combustibil (${fuel.toStringAsFixed(1)} L): ${totalCost.toStringAsFixed(2)} MDL';
      if (distance != null && distance > 0) {
        totalCostInfo += '\nDistanță parcursă: ${distance.toStringAsFixed(1)} km';
      }
    }

    // Actualizăm starea cu mesajul final structurat
    setState(() {
      _discountResult =
      'Preț inițial/L: ${pricePerLiter.toStringAsFixed(2)} MDL\n'
          'Reducere (${percent.toStringAsFixed(0)}%): -${discountPerLiter.toStringAsFixed(2)} MDL/L\n'
          'Preț final/L: ${finalPricePerLiter.toStringAsFixed(2)} MDL'
          '$totalCostInfo';
    });
  }

  // --- CURĂȚAREA RESURSELOR ---
  // Eliberează memoria ocupată de controller-e când widget-ul este distrus
  @override
  void dispose() {
    _distanceController.dispose();
    _fuelController.dispose();
    _pricePerLiterController.dispose();
    _discountTextController.dispose();
    super.dispose();
  }

  // --- CONSTRUCȚIA INTERFAȚEI (UI) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bara superioară a aplicației
      appBar: AppBar(
        title: const Text('Calculator consum combustibil'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // Permite derularea pe verticală dacă ecranul este mic (previne erorile de overflow)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ================= SECTIUNEA 1: CARD CONSUM =================
            Card(
              elevation: 4, // Umbră sub card
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. Consum Mediu Automobil',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Câmp 1: Distanța parcursă
                    TextField(
                      controller: _distanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Distanța parcursă (km)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.add_location_alt_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Câmp 2: Litri combustibil
                    TextField(
                      controller: _fuelController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Combustibil consumat (litri)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_gas_station),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Buton 1: Calculează consumul
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _calculateFuelConsumption,
                        icon: const Icon(Icons.calculate),
                        label: const Text('Calculează Consumul'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Bloc afișare rezultat consum (apare doar dacă există rezultat)
                    if (_avgConsumptionResult.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _avgConsumptionResult,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20), // Spațiu între cele două carduri

            // ================= SECTIUNEA 2: CARD PREȚ ȘI REDUCERE =================
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2. Calcul Cost & Reducere',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Câmp 3: Preț pe litru
                    TextField(
                      controller: _pricePerLiterController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Preț combustibil (MDL / litru)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Meniu derulant (DropdownButton) pentru procentele presetate
                    Row(
                      children: [
                        const Text(
                          'Procent reducere:',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<double>(
                          value: _useCustomDiscount ? null : _selectedDiscountPercent,
                          hint: const Text('Custom'),
                          items: const [
                            DropdownMenuItem(value: 0.0, child: Text('0% (Fără reducere)')),
                            DropdownMenuItem(value: 5.0, child: Text('5%')),
                            DropdownMenuItem(value: 10.0, child: Text('10%')),
                            DropdownMenuItem(value: 15.0, child: Text('15%')),
                            DropdownMenuItem(value: 20.0, child: Text('20%')),
                            DropdownMenuItem(value: 25.0, child: Text('25%')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedDiscountPercent = value;
                                _useCustomDiscount = false; // Dezactivează introducerea manuală
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    // Bifă Checkbox pentru reducere manuală
                    Row(
                      children: [
                        Checkbox(
                          value: _useCustomDiscount,
                          onChanged: (val) {
                            setState(() {
                              _useCustomDiscount = val ?? false;
                            });
                          },
                        ),
                        const Text('Introduce alt procent manual'),
                      ],
                    ),

                    // Câmp text opțional (se afișează doar dacă bifa Checkbox este activată)
                    if (_useCustomDiscount) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _discountTextController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Procent reducere (%)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.percent),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Buton 2: Calculează reducerea
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _calculateDiscount,
                        icon: const Icon(Icons.local_offer),
                        label: const Text('Calculează Prețul Final & Cost Total'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Bloc afișare rezultat preț și reducere
                    if (_discountResult.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _discountResult,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}