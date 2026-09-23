
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/socket_io_client.dart';
import 'api_url.dart' show ApiConstant;

///<------------------------- Socket Class ---------------->
typedef SocketService = SocketApi;

class SocketApi {
  // late IO.Socket socket;
  // Factory constructor to return the same static instance every time you create an object.
  factory SocketApi(){
    return _socketApi;
  }

  // An internal private constructor to access it only once for the static instance of the class.
  SocketApi._internal();

  ///<------------------------- Socket Client ---------------->

  static io.Socket socket = io.io(
    ApiConstant.socketUrl,
    io.OptionBuilder().setTransports(['websocket'])
    //   .disableAutoConnect()
    //    .enableForceNewConnection()
    //    .setTimeout(5000)
    //    .setReconnectionDelay(10000)
    //    .enableReconnection()
    // .setQuery(<dynamic, dynamic>{'token': Environment.token})
        .build(),
  );

  ///<------------------------- Socket Initialization ---------------->
  static void init() {
    debugPrint(
        '=============> Socket initialization, connected: ${socket.connected}');
    if (!socket.connected) {
      // socket.connect();
      socket.onConnect((_) {
        debugPrint(
            '==============>>>>>>> Socket Connected ${socket.connected}===============<<<<<<<');
      });

      //<----------------------Listen for new message--------------->

      socket.on('unauthorized', (dynamic data) {
        debugPrint('Unauthorized');
      });
      socket.onError((dynamic error) {
        debugPrint('Socket error: $error');
      });
      socket.onDisconnect((dynamic data) {
        debugPrint('Socket instance disconnected');
      });
    } else {
      debugPrint('Socket instance already connected');
    }
  }

  /// Emit Driver Location for Real-Time Tracking
  static void emitDriverLocation({
    required String driverId,
    required String orderId,
    required double lat,
    required double lng,
    double? heading,
    double? speed,
  }) {
    if (socket.connected) {
      final payload = {
        'driverId': driverId,
        'orderId': orderId,
        'lat': lat,
        'lng': lng,
        if (heading != null) 'heading': heading,
        if (speed != null) 'speed': speed,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      socket.emit('driver_location', payload);
      debugPrint('Emitted driver location: $payload');
    } else {
      debugPrint('Socket not connected. Cannot emit location.');
    }
  }

  static final SocketApi _socketApi = SocketApi._internal();

}