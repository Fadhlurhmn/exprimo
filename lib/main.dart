import 'package:flutter/material.dart';
import 'profile.dart';
// import 'importfoto.dart';  // Tambahkan import untuk halaman SelectPhotoPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Exprimo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  // Function to navigate to profile page
  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()), // Pindah ke halaman ProfilePage
    );
  }

  // // Function to navigate to select photo page
  // void _goToSelectPhoto() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => SelectPhotoPage()), // Pindah ke halaman SelectPhotoPage
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20), // Beri jarak sebelum tombol
            ElevatedButton(
              onPressed: _goToProfile, // Pindah ke halaman profil saat tombol ditekan
              child: const Text("Go to Profile"),
            ),
            // const SizedBox(height: 20), // Jarak antara tombol profil dan tombol import foto
            // ElevatedButton(
            //   onPressed: _goToSelectPhoto, // Pindah ke halaman import foto saat tombol ditekan
            //   child: const Text("Go to Import Foto"),
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
