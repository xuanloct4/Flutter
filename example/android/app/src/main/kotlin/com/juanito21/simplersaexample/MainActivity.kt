package com.juanito21.simplersaexample

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.Bundle
import android.util.Log

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StringCodec
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.view.FlutterView
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.charset.Charset

class MainActivity() : FlutterActivity() {
    private val CHANNEL = "samples.flutter.io/battery"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        // Method Channels
        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()

                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }

//        receiveMessageChannel()
    receiveBinaryMessage(flutterView)
    }


    private fun receiveMessageChannel() {
        val channel = BasicMessageChannel<String>(flutterView, "foo", StringCodec.INSTANCE)
// Receive messages from Dart and send replies.
        channel.setMessageHandler { message, reply ->
            Log.i("MSG", "Android: Received: $message")
//            reply.reply("Hi from Android")
            sendMessageChannel()
        }
    }

    private fun sendMessageChannel() {
        val channel = BasicMessageChannel<String>(
                flutterView, "foo", StringCodec.INSTANCE)
// Send message to Dart and receive reply.
        channel.send("Sent from Android") { reply ->
            Log.i("MSG", reply)
        }
    }

    private fun receiveBinaryMessage(flutterView: FlutterView) {
        // Receive Binary messaging from Dart
        flutterView.setMessageHandler("foo") { message, reply ->
            message.order(ByteOrder.nativeOrder())
            val x = message.double
            val n = message.int
            Log.i("MSG", "Android: Received: $x and $n")
//            reply.reply(null)
                sendBinaryMessage(flutterView)
        }
    }

    private fun sendBinaryMessage(flutterView: FlutterView) {
        // Send Binary messaging to Dart
        val msg = "Android: Message sent, reply ignored"
        val charSet = Charsets.UTF_8
        val message = Charset.forName("UTF-8").encode(msg)
//        val message = ByteBuffer.allocateDirect(12)
//        message.putDouble(3.1415)
//        message.putInt(123456789)
        flutterView.send("foo", message) { _ ->
            Log.i("MSG", "Android: Message sent, reply ignored")
        }
    }


    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }

        return batteryLevel
    }
}
