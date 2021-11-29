import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:tcp/othermessage.dart';
import 'package:tcp/ownmessage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SubmitPage(),
    );
  }
}

class SubmitPage extends StatefulWidget {
  const SubmitPage({Key? key}) : super(key: key);

  @override
  _SubmitPageState createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  final inputController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(children: [
                    Text(
                      "What is your name?",
                      style: GoogleFonts.poppins(fontSize: 20),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 12),
                        width: 330,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(214, 214, 214, 100),
                            borderRadius: BorderRadius.circular(14.65)),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              hintText: "Do not enter a username with spaces ",
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 11, top: 11, right: 15)),
                          controller: inputController,
                        )),
                    const Padding(padding: EdgeInsets.only(top: 38)),
                    ElevatedButton(
                      onPressed: () async {
                        if (inputController.text.contains(" ")) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text('Username still has space')));
                          return;
                        }
                        final socket =
                            await Socket.connect('34.101.88.159', 3389);
                        print(
                            'Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
                        socket.write(inputController.text);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyHomePage(
                                  title: inputController.text, socket: socket)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 15.0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          'Enter',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    )
                  ]),
                ],
              ),
            ),
          ),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  final Socket socket;

  MyHomePage({Key? key, required this.title, required this.socket})
      : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final inputController = TextEditingController();

  ScrollController scrollcontrol = ScrollController();

  List<String> messageList = [];

  @override
  void dispose() {
    inputController.dispose();
    widget.socket.destroy();
    widget.socket.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              children: <Widget>[
                StreamBuilder(
                    stream: widget.socket,
                    builder: (context, snapshot) {
                      if (snapshot.hasData == false ||
                          String.fromCharCodes(snapshot.data as Uint8List)
                                  .contains("Connected to the server!") ==
                              true) {
                        return Container(
                            height: MediaQuery.of(context).size.height - 300);
                      }
                      String sent =
                          String.fromCharCodes(snapshot.data as Uint8List);
                      messageList.add(sent);
                      return Container(
                          color: const Color.fromRGBO(236, 235, 236, 100),
                          height: MediaQuery.of(context).size.height - 300,
                          child: ListView.builder(
                              controller: scrollcontrol,
                              shrinkWrap: true,
                              itemCount: messageList.length,
                              itemBuilder: (BuildContext context, int index) {
                                String messagerecieved = messageList[index];
                                List<String> messagedisected =
                                    messagerecieved.split(" ");
                                if (messagedisected[0] != "${widget.title}:" &&
                                    messagerecieved.contains(
                                            "Connected to the server") ==
                                        false) {
                                  print(messagedisected[0]);
                                  return OtherMessage(
                                      message: messageList[index]);
                                } else {
                                  return OwnMessage(
                                      message: messageList[index]);
                                }
                              }));
                    }),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 12),
                      width: 330,
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(214, 214, 214, 100),
                          borderRadius: BorderRadius.circular(14.65)),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 5,
                        decoration: const InputDecoration(
                            hintText: 'Enter your message',
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 15, bottom: 11, top: 11, right: 15)),
                        controller: inputController,
                      ),
                    ),
                    IconButton(
                        padding:
                            const EdgeInsets.only(left: 10, right: 12, top: 10),
                        iconSize: 50,
                        onPressed: () {
                          if (messageList.isNotEmpty) {
                            scrollcontrol.animateTo(
                                scrollcontrol.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.easeOut);
                          }
                          String message = inputController.text;
                          widget.socket.write("${widget.title}: " + message);
                          inputController.clear();
                        },
                        icon: SvgPicture.asset('assets/images/SendButton.svg'))
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
