import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socket_demo/db.dart';
import 'package:flutter_socket_demo/helper.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketPage extends StatefulWidget {
  @override
  _SocketPageState createState() => _SocketPageState();
}

class _SocketPageState extends State<SocketPage> {
  SocketIO socketIO;
  IO.Socket socket;
  List<String> messages;
  double height, width;
  TextEditingController textController;
  ScrollController scrollController;
  final DBManager dbmanager = new DBManager();
  bool isConnected = false;
  var response;
  var _connectionStatus = 'Unknown';
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    connectivity = new Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _connectionStatus = result.toString();
      print(_connectionStatus);
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
      } else {}
    });
    //Initializing the message list
    messages = List<String>();
    //Initializing the TextEditingController and ScrollController
    textController = TextEditingController();
    scrollController = ScrollController();
    _connectSocket02();
    super.initState();
  }

  // _socketStatus(dynamic data) {
  //   print("Socket status: " + data);
  //   if (data == 'connect') {
  //     setState(() {
  //       isConnected = true;
  //       _reconnectSocket();
  //     });
  //   } else {
  //     setState(() {
  //       isConnected = false;
  //     });
  //     print(isConnected);
  //   }
  // }

  // _messageSentStatus(dynamic data) async {
  //   print("Message Sent Status: " + data);
  // }

  // _connectSocket01() {
  //   //Creating the socket
  //   socketIO = SocketIOManager().createSocketIO(
  //     'https://e890ed14.ngrok.io',
  //     '/',
  //     socketStatusCallback: _socketStatus,
  //   );
  //   //Call init before doing anything with socket
  //   socketIO.init();
  //   //Subscribe to an event to listen to
  //   socketIO.subscribe('receive_message', (msg) async {
  //     print(msg);
  //     var allRows = await dbmanager.getAllRows();
  //     for (var item in allRows) {
  //       int rowId = item.id;
  //       var message = item.message;
  //       var timeStamp = item.timeStamp;
  //       dbmanager
  //           .updateSocketData(rowId, message, 'send', timeStamp)
  //           .then((id) {
  //         print('socket  updated  to Db {$id}');
  //       });
  //     }
  //   });
  //   //Connect to the socket
  //   socketIO.connect();
  // }

  _connectSocket02() {
    socket = IO.io(
      'https://7524cff7.ngrok.io/',
      <String, dynamic>{
        'transports': ['websocket'],
        'query': {
          'token':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjVkZjFjOWJhNjIyMzZlMGNjNmFhMGM2MiIsInVzZXIiOnsiX2lkIjoiNWRmMWM5YmE2MjIzNmUwY2M2YWEwYzYyIiwicGFzc3dvcmQiOiIkMmEkMTAkdS5CcTJ6QkJvbTJQTXk0VW9ENjhET2lIaU4xOWl1UmRQcVpSbTJ6TnVlWVFjYXUvWncvVmkifSwiaWF0IjoxNTg4NzQ1NTk3LCJleHAiOjE1ODg5MTgzOTd9.pLH-D_18ZJkbyFNMwMvX95y1bTxbz8wHuChS2G3T-Iw'
        }
      },
    );
    socket.connect();

    socket.on('connect', (_) {
      print('connect');
    });
    socket.on('catch_v', (data) => print('catch_v ---- $data'));
    socket.on('disconnect', (_) => print('disconnect'));
    // socket.on('fromServer', (response) => response);
  }

  // _reconnectSocket() {
  //   // if (socketIO == null) {
  //   //   _connectSocket01();
  //   // } else {
  //   //   socketIO.connect();
  //   var msg = SharedPreferencesHelper.getMessage();
  //   socketIO.sendMessage(
  //     'chat_message',
  //     json.encode({
  //       'message': msg,
  //     }),
  //   );
  //   // }
  // }

  Widget buildSingleMessage(int index) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.only(bottom: 20.0, left: 20.0),
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          messages[index],
          style: TextStyle(color: Colors.white, fontSize: 15.0),
        ),
      ),
    );
  }

  Widget buildMessageList() {
    return Container(
      height: height * 0.8,
      width: width,
      child: ListView.builder(
        controller: scrollController,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(index);
        },
      ),
    );
  }

  Widget buildChatInput() {
    return Container(
      width: width * 0.7,
      padding: const EdgeInsets.all(2.0),
      margin: const EdgeInsets.only(left: 40.0),
      child: TextField(
        decoration: InputDecoration.collapsed(
          hintText: 'Send a message...',
        ),
        controller: textController,
      ),
    );
  }

  Widget buildSendButton() {
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      onPressed: () {
        //Check if the textfield has text or not
        if (textController.text.isNotEmpty) {
          //Send the message as JSON data to send_message event
          SocketData initSocketData = new SocketData(
            status: 'unsend',
            timeStamp: DateTime.now().toIso8601String(),
            message: textController.text,
          );
          dbmanager.insertForm(initSocketData).then(
            (id) {
              print(
                'intiSocketData Added to Db {$id}',
              );
            },
          );
          // if (isConnected) {
          //   socketIO.sendMessage(
          //       'check',
          //       json.encode({'message': textController.text}),
          //       _messageSentStatus);
          // } else {
          //   SharedPreferencesHelper.setMessage(textController.text);
          // }

          socket.emit(
            'check_v', {'check_v ---message': textController.text},
            //   ack: (data) {
            // print('ack $data');
            // if (data != null) {
            //   print('from server $data');
            // } else {
            //   print("Null");
            // }
            // }
          );
          print(isConnected);
          //Add the message to the list
          this.setState(() => messages.add(textController.text));
          textController.text = '';
          //Scrolldown the list to show the latest message
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 600),
            curve: Curves.ease,
          );
        }
      },
      child: Icon(
        Icons.send,
        size: 30,
      ),
    );
  }

  Widget buildInputArea() {
    return Container(
      height: height * 0.1,
      width: width,
      child: Row(
        children: <Widget>[
          buildChatInput(),
          buildSendButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: height * 0.1),
            buildMessageList(),
            buildInputArea(),
          ],
        ),
      ),
    );
  }
}
