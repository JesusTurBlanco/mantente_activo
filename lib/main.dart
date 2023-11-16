import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mantente Activo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Mantente activo'),
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
  Duration _temporizador =  const Duration(minutes: 0);
  bool _temporizando = true;
  bool _pasaron5 = false;
  late Timer tempo;
  final AudioPlayer player = AudioPlayer();
  final int _limiteSentado = 30;
  final int _limiteActivo = 5;

  @override
  void initState() {
    super.initState();

    _iniReloj();
  }

  void _reseteaTemporizador(){
    _temporizando = !_temporizando;
    if(_temporizando){
      setState(() {
        _temporizador = const Duration();
      });
      _iniReloj();
    }
    else{
      setState(() {
        _temporizador = Duration(minutes: _limiteActivo);
      });
      _iniReloj();
    }
  }

  void _addTempo(){
    final addSegundos = _temporizando ? 1 : -1;
    final limite = _temporizando ? _limiteSentado: 0;
    setState(() {
        final segundos = _temporizador.inSeconds + addSegundos;
        _temporizador = Duration(seconds: segundos);
        _compruebaLim(_temporizador.inMinutes, limite);
    });
  }

  Future<void> _compruebaLim(tem, lim) async {
    if(tem == lim){
      if(_temporizando) {
        tempo.cancel();
        player.setPlayerMode(PlayerMode.mediaPlayer);
        player.play(AssetSource('alerta.wav'));

        _reseteaTemporizador();
      }
      else{
        if(_temporizador.inSeconds == 0) {
          tempo.cancel();
          _pasaron5 = true;
        }
      }
    }
  }

  void _iniReloj(){
    tempo = Timer.periodic( const Duration(seconds: 1), (_) => _addTempo());

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: _temporizando ? Colors.lightBlueAccent.shade100 : Colors.red.shade500,
        title: Text(widget.title),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _temporizando
            ? const Padding(padding: EdgeInsets.all(20),
              child: Text(
                'Estos son los minutos que llevas sentado:',
                style: TextStyle(fontSize: 20),
              ),
            )
            : const Padding(padding: EdgeInsets.all(20),
              child: Text(
                'Empieza a moverte',
                style: TextStyle(fontSize: 20),
                ),
              ),

            buildTiempo(),

        _temporizando
          ?const Padding(padding: EdgeInsets.all(20),
           child: Text(
                  'Cada 30 minutos te avisaremos para que te mantengas activo.',
                  style: TextStyle(fontSize: 15),
                ),
              )
          :const Padding(padding: EdgeInsets.all(20),
            child: Text(
              'Cuando pasen 5 minutos, aparecerá un botón, presiónalo al acabar tus ejercicios.',
              style: TextStyle(fontSize: 15),
            ),
          ),
        if(_pasaron5)
          Padding(padding: const EdgeInsets.all(20),
            child: ElevatedButton(onPressed: () {
            _pasaron5 = false;
            _reseteaTemporizador();
            },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
              'Terminado.',
                style: TextStyle(color: Colors.white),
            ),)),
          ],
        ),
      ),
    );

  }
  Widget buildTiempo() {
    String formatoDigitos(int numero) => numero.toString().padLeft(2, '0');
    final minutos = formatoDigitos(_temporizador.inMinutes.remainder(60));
    final segundos = formatoDigitos(_temporizador.inSeconds.remainder(60));
    int divisor = _temporizando ? 60*_limiteSentado : _limiteActivo*60;
    double valor = _temporizador.inSeconds/divisor;
    Color _color = _temporizando ? Colors.black : Colors.red.shade500;
    Color _colorBorde = _temporizando ? Colors.blue.shade200 : Colors.red.shade500;
    if (_temporizador.inSeconds % 2 == 0 && !_temporizando){
      _colorBorde = Colors.transparent;
    }

    return Column(
          children: <Widget>[
            SizedBox(
              height: 250,
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: valor,
                        semanticsLabel: "Tiempo restante",
                        color: _colorBorde,

                      ),
                    ),
                  ),
                  Center(
                      child: Text(
                    '$minutos:$segundos',
                    style: TextStyle(fontSize: 90, color: _color),
                  ))
                ],
              ),
            )


]);
  }
}
