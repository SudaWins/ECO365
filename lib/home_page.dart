import 'package:flutter/material.dart';
import 'package:ECO365/Services/notifi_service.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // centraliza o título
        title: Text(widget.title, style: const TextStyle(fontSize: 40, fontFamily: 'Titan', color: Color.fromARGB(255, 40, 200, 104))),
      ),
      body: Stack(
        children: [
          // Widgets sobrepostos usando o Stack
          Positioned(
            // ... widget posicionado ...
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              // ... conteúdo do widget posicionado ...
            ),
          ),
          // Conteúdo da tela principal
          Center(
            child: ElevatedButton(
              child: const Text('Mostrar Notificação'),
              onPressed: () {
                NotificationService()
                    .showNotification(title: 'Amostra', body: 'Funciona!');
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin:  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 40, 200, 104), // Cor de fundo da barra de navegação
          borderRadius: BorderRadius.all(Radius.circular(100)), // Bordas arredondadas
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 1,
          ),
          child: GNav(
            //adc propriedades gerais válidas para todos os GButton's
            backgroundColor:
                const Color.fromARGB(255, 40, 200, 104), //cor do fundo da barra GNav
            //color: Colors.blue, //cor do ícone não selecionado, gera um bug de piscar o ícone na hora de trocar de ativo
            tabMargin: const EdgeInsets.only(
              left: 8.0,
              top: 1.0,
              right: 5.0,
              bottom: 1.0,
            ),
            tabBackgroundColor:
                const Color.fromARGB(192, 15, 73, 38), //cor de fundo do botão ativo
            hoverColor: const Color.fromARGB(41, 15, 73, 38),
            gap: 8, //distância entre o texto do GButton e o ícone
            onTabChange: (index) {
              print(index);
            },
            //activeColor: Color.fromARGB(255, 13, 63, 33),
            padding: const EdgeInsets.all(16), //tamanho do bloco GNav
            tabs: const [
              GButton(
                icon: Icons.home,
                //text: "Home",
              ),
              GButton(
                icon: Icons.notifications,
                //text: "Notificações",
              ),
              GButton(
                icon: Icons.map,
                //text: "Mapa",
              ),
              GButton(
                icon: Icons.person,
                //text: "Perfil",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
