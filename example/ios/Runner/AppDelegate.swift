import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {

        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

        // Method Channels
        let batteryChannel = FlutterMethodChannel(name: "samples.flutter.io/battery",
                                                  binaryMessenger: controller)

batteryChannel.setMethodCallHandler({
  [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
  // Handle battery messages.
  guard call.method == "getBatteryLevel" else {
    result(FlutterMethodNotImplemented)
    return
  }
  self?.receiveBatteryLevel(result: result)
})


receiveMessageChannel(controller :controller)
//sendMessageChannel(controller :controller)



        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }


  private func receiveMessageChannel(controller : FlutterViewController) {
let channel = FlutterBasicMessageChannel(
    name: "foo",
    binaryMessenger: controller,
    codec: FlutterStringCodec.sharedInstance())
// Receive messages from Dart and send replies.
channel.setMessageHandler {
  (message: Any?, reply: FlutterReply) -> Void in
 // os_log("Received: %@", type: .info, message as! String)
  print("Received: \(message as! String)")
  reply("Hi from iOS")
}
  }

    private func sendMessageChannel(controller : FlutterViewController) {
let channel = FlutterBasicMessageChannel(
    name: "foo",
    binaryMessenger: controller,
    codec: FlutterStringCodec.sharedInstance())
// Send message to Dart and receive reply.
channel.sendMessage("Hello, world") {(reply: Any?) -> Void in
 // os_log("%@", type: .info, reply as! String)
   print("\(reply as! String)")
   }
    }

  func receiveBinaryMessage(controller : FlutterViewController) {
// Receive Binary messaging from Dart
controller.setMessageHandlerOnChannel("foo") {
  (message: Data!, reply: FlutterBinaryReply) -> Void in
  let x : Float64 = message.subdata(in: 0..<8)
    .withUnsafeBytes { $0.pointee }
  let n : Int32 = message.subdata(in: 8..<12)
    .withUnsafeBytes { $0.pointee }
  // os_log("Received %f and %d", x, n)
  print("iOS: Received \(x) and \(n)")

  //reply(nil)
  self.sendBinaryMessage(controller: controller)
  }
  }

  func sendBinaryMessage(controller : FlutterViewController) {
  // Send Binary messaging to Dart
    var message = Data(capacity: 12)
    var y : Float64 = 3.1415
    var m : Int32 = 12345678
    message.append(UnsafeBufferPointer(start: &y, count: 1))
    message.append(UnsafeBufferPointer(start: &m, count: 1))
    controller.send(onChannel: "foo", message: message) {(_) -> Void in
      // os_log("Message sent, reply ignored")
      print("iOS: Message sent, reply ignored")
    }
  }

  private func receiveBatteryLevel(result: FlutterResult) {
    let device = UIDevice.current
    device.isBatteryMonitoringEnabled = true
    if device.batteryState == UIDeviceBatteryState.unknown {
      result(FlutterError(code: "UNAVAILABLE",
                          message: "Battery info unavailable",
                          details: nil))
    } else {
      result(Int(device.batteryLevel * 100))
    }
  }
}
