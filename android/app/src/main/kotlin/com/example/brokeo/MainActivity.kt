package com.example.brokeo

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.os.Bundle
import android.telephony.SmsMessage
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "sms_platform"
    private lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        // Register SMS BroadcastReceiver
        val smsReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == "android.provider.Telephony.SMS_RECEIVED") {
                    val bundle = intent.extras
                    if (bundle != null) {
                        val pdus = bundle.get("pdus") as Array<*>
                        for (pdu in pdus) {
                            val smsMessage = SmsMessage.createFromPdu(pdu as ByteArray)
                            val messageBody = smsMessage.messageBody
                            methodChannel.invokeMethod("onSmsReceived", messageBody)
                        }
                    }
                }
            }
        }

        // Register the receiver for SMS_RECEIVED action
        registerReceiver(smsReceiver, IntentFilter("android.provider.Telephony.SMS_RECEIVED"))

        methodChannel.setMethodCallHandler { call, result ->
            if (call.method == "readAllSms") {
                if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_SMS), 1)
                } else {
                    result.success(readAllSms())
                }
            }
        }
    }

    private fun readAllSms(): List<String> {
        val smsList = mutableListOf<String>()
        val uri: Uri = Uri.parse("content://sms")
        val cursor: Cursor? = contentResolver.query(uri, null, null, null, null)

        cursor?.use {
            while (it.moveToNext()) {
                val address = it.getString(it.getColumnIndexOrThrow("address"))
                val body = it.getString(it.getColumnIndexOrThrow("body"))
                smsList.add("From: $address\nMessage: $body")
            }
        }
        return smsList
    }
}