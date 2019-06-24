import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simple_rsa/simple_rsa.dart';

import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:synchronized/synchronized.dart';

void main() => runApp(App());

class App extends StatelessWidget {








  @override
  Widget build(BuildContext context) {

    RestDatasource rest = new RestDatasource();
    rest.loginUserNameAndPassword("5932128168", "P@ssw0rd", "password");

    return MaterialApp(
      title: 'Simple RSA Encryption',
      home: Home(),
    );


  }
}





class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}



class NetworkUtil {
  // next three lines makes this class a Singleton
  static NetworkUtil _instance = new NetworkUtil.internal();
  NetworkUtil.internal();
  factory NetworkUtil() => _instance;

  final JsonDecoder _decoder = new JsonDecoder();

  Future<dynamic> get(String url , {Map headersAdd}) {
    var headerDefault = <String , String>{};
    headerDefault['content-type'] = "application/json";
    headerDefault['client_id'] = "A1234567890123456789012345678901";
    headerDefault['client_secret'] = "A123456789012345678901234567890123456789012345678901234567890123";
    headerDefault['channel_id'] = "2";

    if (headersAdd != null && headersAdd.isNotEmpty) {
      headerDefault.addAll(headersAdd);
    }

    return http.get(url,headers: headerDefault).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }


  Future<dynamic> post(String url, {Map headers, body, encoding}) {
    // Config header default
    var headerDefault = <String, String>{};
    headerDefault["content-type"] = "application/json";
    headerDefault["client_id"] = "A1234567890123456789012345678901";
    headerDefault["client_secret"] = "A123456789012345678901234567890123456789012345678901234567890123";
    headerDefault["channel_id"] = "2";
    if(headers.isNotEmpty){
      headerDefault.addAll(headers);
    }

    return http
        .post(url, body: body, headers: headerDefault, encoding: encoding)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }
}



class RestDatasource {
  NetworkUtil _netUtil = new NetworkUtil();
  static final API_AUTHORIZE_AGENT =
      "https://ami-channel-gateway-dev.public.tmn-dev.com/ami-channel-gateway/channel-adapter/v4.4/agents/login";

//  String PublicKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCsfOnDzDh8d7ZvlMnXZaZhVZ5hrU85VhXCAGQNokTVw6NvHbv0sOJF6ttehfsDlokpAy6SMsfuOK2pXVzV6Y4PcFgl8CO5foxv0Xw0BjP8Le6NhDSFfJGzzLNxBiNDtSuE";
  String PublicKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCsfOnDzDh8d7ZvlMnXZaZhVZ5hrU85VhXCAGQNokTVw6NvHbv0sOJF6ttehfsDlokpAy6SMsfuOK2pXVzV6Y4PcFgl8CO5foxv0Xw0BjP8Le6NhDSFfJGzzLNxBiNDtSuE+GSRzggyF/a8YyJP2xOTBEM4Owdoyv4YmjBnl5L0xwIDAQAB";
  // Function login
  Future<AuthorizationResponse> loginUserNameAndPassword(
      String userName, String password, String grandType) async {
    var bodyField = <String, String>{};
    bodyField["grant_type"] = grandType;
    bodyField["username"] = userName;
    bodyField["password"] = "BAn556oSnFT1KHGS4o/bohHM50IGHXb6jlE+cKfrqiBseB/S4wzEaW24Q0wQusrLOkeaeMwfuC4qgvgfMQ84VCcoj9l8icNYzKRWRp44Mt/k7V6ic2TVZ9F8kADp7S2W9DzDwOKx5yg+57ya2QwdKSrZhADnTdWp4qUqDWPJT+A=";
    bodyField["client_id"] = "A1234567890123456789012345678901";
    bodyField["login_type"] = "password";


    bodyField["password"] = await encryptString(password, PublicKey);

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo androidDeviceInfo = await deviceInfo.iosInfo;

    var headerUUID = <String, String>{};
    headerUUID['device_unique_reference'] = androidDeviceInfo.identifierForVendor;
    return _netUtil
        .post(API_AUTHORIZE_AGENT,
        headers: headerUUID, body: json.encode(bodyField))
        .then((dynamic res) {
      print(res.toString());
//      if (res['error']) throw new Exception(res['error_msg']);
      return new AuthorizationResponse.map(res["data"]);
    });
  }

}



class HomeState extends State<Home> {
  static const platform = const MethodChannel('samples.flutter.io/battery');

// Get battery level.
  String _batteryLevel ;


  final PUBLIC_KEY =
      "MIIBITANBgkqhkiG9w0BAQEFAAOCAQ4AMIIBCQKCAQBuAGGBgg9nuf6D2c5AIHc8" +
          "vZ6KoVwd0imeFVYbpMdgv4yYi5obtB/VYqLryLsucZLFeko+q1fi871ZzGjFtYXY" +
          "9Hh1Q5e10E5hwN1Tx6nIlIztrh5S9uV4uzAR47k2nng7hh6vuZ33kak2hY940RSL" +
          "H5l9E5cKoUXuQNtrIKTS4kPZ5IOUSxZ5xfWBXWoldhe+Nk7VIxxL97Tk0BjM0fJ3" +
          "8rBwv3++eAZxwZoLNmHx9wF92XKG+26I+gVGKKagyToU/xEjIqlpuZ90zesYdjV+" +
          "u0iQjowgbzt3ASOnvJSpJu/oJ6XrWR3egPoTSx+HyX1dKv9+q7uLl6pXqGVVNs+/" +
          "AgMBAAE=";

  final PRIVATE_KEY =
      "MIIEoQIBAAKCAQBuAGGBgg9nuf6D2c5AIHc8vZ6KoVwd0imeFVYbpMdgv4yYi5ob" +
          "tB/VYqLryLsucZLFeko+q1fi871ZzGjFtYXY9Hh1Q5e10E5hwN1Tx6nIlIztrh5S" +
          "9uV4uzAR47k2nng7hh6vuZ33kak2hY940RSLH5l9E5cKoUXuQNtrIKTS4kPZ5IOU" +
          "SxZ5xfWBXWoldhe+Nk7VIxxL97Tk0BjM0fJ38rBwv3++eAZxwZoLNmHx9wF92XKG" +
          "+26I+gVGKKagyToU/xEjIqlpuZ90zesYdjV+u0iQjowgbzt3ASOnvJSpJu/oJ6Xr" +
          "WR3egPoTSx+HyX1dKv9+q7uLl6pXqGVVNs+/AgMBAAECggEANG9qC1n8De3TLPa+" +
          "IkNXk1SwJlUUnAJ6ZCi3iyXZBH1Kf8zMATizk/wYvVxKHbF1zTyl94mls0GMmSmf" +
          "J9+Hlguy//LgdoJ9Wouc9TrP7BUjuIivW8zlRc+08lIjD64qkfU0238XldORXbP8" +
          "2BKSQF8nwz97WE3YD+JKtZ4x83PX7hqC9zabLFIwFIbmJ4boeXzj4zl8B7tjuAPq" +
          "R3JNxxKfvhpqPcGFE2Gd67KJrhcH5FIja4H/cNKjatKFcP6qNfCA7e+bua6bL0Cy" +
          "DzmmNSgz6rx6bthcJ65IKUVrJK6Y0sBcNQCAjqZDA0Bs/7ShGDL28REuCS1/udQz" +
          "XyB7gQKBgQCrgy2pvqLREaOjdds6s1gbkeEsYo7wYlF4vFPg4sLIYeAt+ed0kn4N" +
          "dSmtp4FXgGyNwg7WJEveKEW7IEAMQBSN0KthZU4sK9NEu2lW5ip9Mj0uzyUzU4lh" +
          "B+zwKzZCorip/LIiOocFWtz9jwGZPCKC8expUEbMuU1PzlxrytHJaQKBgQCkMEci" +
          "EHL0KF5mcZbQVeLaRuecQGI5JS4KcCRab24dGDt+EOKYchdzNdXdM8gCHNXb8RKY" +
          "NYnHbCjheXHxV9Jo1is/Qi9nND5sT54gjfrHMKTWAtWKAaX55qKG0CEyBB87WqJM" +
          "Ydn7i4Rf0rsRNa1lbxQ+btX14d0xol9313VC5wKBgERD6Rfn9dwrHivAjCq4GXiX" +
          "vr0w2V3adD0PEH+xIgAp3NXP4w0mBaALozQoOLYAOrTNqaQYPE5HT0Hk2zlFBClS" +
          "BfS1IsE4DFYOFiZtZDoClhGch1z/ge2p/ue0+1rYc5HNL4WqL/W0rcMKeYNpSP8/" +
          "lW5xckyn8Jq0M1sAFjIJAoGAQJvS0f/BDHz6MLvQCelSHGy8ZUscm7oatPbOB1xD" +
          "62UGvCPu1uhGfAqaPrJKqTIpoaPqmkSvE+9m4tsEUGErph9o4zqrJqRzT/HAmrTk" +
          "Ew/8PU7eMrFVW9I68GvkNCdVFukiZoY23fpXu9FT1YDW28xrHepFfb1EamynvqPl" +
          "O88CgYAvzzSt+d4FG03jwObhdZrmZxaJk0jkKu3JkxUmav9Zav3fDTX1hYxDNTLi" +
          "dazvUFfqN7wqSSPqajQmMoTySxmLI8gI4qC0QskB4lT1A8OfmjcDwbUzQGam5Kpz" +
          "ymmKJA9DgQpPgEIjHAnw2dUDR+wI/Loywb0AGLIbszseCOlc2Q==";

  final myController = TextEditingController();
  String _stringEncoded = '';

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }


  Text tv = new Text("dsdsd");

  @override
  void initState() {


//    receiveMessageChannel();



receiveBinaryMessage();

//    _getBatteryLevel().then((String lev) {
//        setState(() {
//          _stringEncoded = lev;
//        });
//        });

    super.initState();
  }

  Future<String> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    } on MissingPluginException {
      print('getBatteryLevel not implemented');
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
    return batteryLevel;
  }

  void receiveMessageChannel() async {
    const channel = BasicMessageChannel<String>('foo', StringCodec());
// Receive messages from platform and send replies.
    channel.setMessageHandler((String message) async {
      print('Dart: Received: $message');
      setState(() {
          _stringEncoded = 'Dart: Received: $message';
        });
      return 'Dart: Received: $message';
    });
  }

  void sendMessageChannel() async {
    const channel = BasicMessageChannel<String>('foo', StringCodec());
// Send message to platform and receive reply.
    final String reply = await channel.send('Sent from Dart');
    setState(() {
      _stringEncoded = reply;
    });
    print(reply);
  }


  void receiveBinaryMessage() async {

    const codec = StringCodec();
//// Send message to platform and receive reply.
//    final String reply = codec.decodeMessage(
//      await BinaryMessages.send(
//      'foo',
//      codec.encodeMessage('Hello, world'),
//    ),
//    );
//    print(reply);

// Receive messages from platform and send replies.
    BinaryMessages.setMessageHandler('foo', (ByteData message) async {
      print('Dart: Received: ${codec.decodeMessage(message)}');
      setState(() {
        _stringEncoded = 'Dart: Received: ${codec.decodeMessage(message)}';
      });

//      final ReadBuffer readBuffer = ReadBuffer(message);
//      final double x = readBuffer.getFloat64();
//      final int n = readBuffer.getInt32();
//      print('Dart: Received: $x and $n');
//      setState(() {
//        _stringEncoded = 'Dart: Received: $x and $n';
//      });
//      return null;

    return codec.encodeMessage('Hi from Dart');
    });
  }

  void sendBinaryMessage() async {
    final WriteBuffer buffer = WriteBuffer()
      ..putFloat64(3.1415)
      ..putInt32(12345678);
    final ByteData message = buffer.done();
    await BinaryMessages.send('foo', message);
    print('Message sent, reply ignored');
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: tv,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: new ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: myController,
                decoration: InputDecoration(
                  hintText: "Write the text to be encrypted",
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  child:
                      _stringEncoded.isEmpty ? Text("ENCODE") : Text("DECODE"),
                  color: Colors.yellow,
                  onPressed: () async {
                    String tmp = "";
                    try {
                      if (_stringEncoded.isEmpty) {
                        final text = myController.text;
                        if (text.isNotEmpty) {
                          final tmp = await encryptString(
                              myController.text, PUBLIC_KEY);
                          setState(() {
                            _stringEncoded = tmp;
                            myController.clear();
                          });
                        }
                      } else {
                        tmp = await decryptString(_stringEncoded, PRIVATE_KEY);
                        setState(() {
                          _stringEncoded = "";
                          myController.text = tmp;
                        });
                      }
                    } catch (e) {
                      print(e);
                    }
                  },
                ),
                RaisedButton(
                    child: Text("DECODE"),
                    color: Colors.red,
                    onPressed: () async {
//                      String tmp = "";
//                      if (_stringEncoded.isNotEmpty) {
//                        try {
//                          tmp =
//                              await decryptString(_stringEncoded, PRIVATE_KEY);
//                          setState(() {
//                            _stringEncoded = "";
//                            myController.text = tmp;
//                          });
//                        } catch (e) {
//                          print(e);
//                        }
//                      }

                      sendBinaryMessage();
//                      sendMessageChannel();
                    }),
                RaisedButton(
                  child: Text("RESET"),
                  color: Colors.blue,
                  onPressed: () {
                    setState(() {
                      _stringEncoded = "";
                      myController.clear();
                    });
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.orangeAccent,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Text("STRING ENCODED"),
                      Divider(),
                      Text(_stringEncoded),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class AuthorizationResponse {

  String access_token;
  int access_token_expires_in;
  String token_type;
  String refresh_token;
  int refresh_token_expires_in;
  String correlation_id;
  String  credential_expired_timestamp;
  String error;
  String error_description;
  int failed_login_remaining;

  AuthorizationResponse({
    this.access_token,
    this.access_token_expires_in,
    this.token_type,
    this.refresh_token,
    this.refresh_token_expires_in,
    this.correlation_id,
    this.credential_expired_timestamp,
    this.error,
    this.error_description,
    this.failed_login_remaining
  });


  AuthorizationResponse.map(dynamic obj) {
    this.access_token = obj["access_token"];
    this.access_token_expires_in = obj["access_token_expires_in"];
    this.token_type = obj["token_type"];
    this.refresh_token = obj["refresh_token"];
    this.refresh_token_expires_in = obj["refresh_token_expires_in"];
    this.correlation_id = obj["correlation_id"];
    this.credential_expired_timestamp = obj["credential_expired_timestamp"];
    this.error = obj["error"];
    this.error_description = obj["error_description"];
    this.failed_login_remaining = obj["failed_login_remaining"];
  }

  factory AuthorizationResponse.fromJson(Map<String, dynamic> parsedJson){
    return AuthorizationResponse(
      access_token: parsedJson['access_token'],
      access_token_expires_in : parsedJson['access_token_expires_in'],
      token_type : parsedJson ['token_type'],
      refresh_token: parsedJson['refresh_token'],
      refresh_token_expires_in : parsedJson['refresh_token_expires_in'],
      correlation_id : parsedJson ['correlation_id'],
      credential_expired_timestamp: parsedJson['credential_expired_timestamp'],
      error : parsedJson['error'],
      error_description : parsedJson ['error_description'],
      failed_login_remaining: parsedJson['failed_login_remaining'],
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': access_token,
    'access_token_expires_in': access_token_expires_in,
    'token_type': token_type,
    'refresh_token': refresh_token,
    'refresh_token_expires_in': refresh_token_expires_in,
    'correlation_id': correlation_id,
    'credential_expired_timestamp': credential_expired_timestamp,
    'error': error,
    'error_description': error_description,
    'failed_login_remaining': failed_login_remaining
  };
}