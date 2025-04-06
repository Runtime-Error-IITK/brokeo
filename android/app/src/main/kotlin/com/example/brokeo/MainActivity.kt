package com.example.brokeo

import android.Manifest
import android.content.BroadcastReceiver
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.ContactsContract
import android.telephony.SmsMessage
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val SMS_CHANNEL = "sms_platform"
    private val CONTACTS_CHANNEL = "com.example.contacts/fetch"
    private val CONTACTS_PERMISSION_CODE = 1001
    private lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // SMS Method Channel
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL)

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

        // Contacts Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CONTACTS_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getContacts") {
                if (hasContactsPermission()) {
                    val contacts = getContacts()
                    if (contacts != null) {
                        result.success(contacts)
                    } else {
                        result.error("UNAVAILABLE", "Contacts not available.", null)
                    }
                } else {
                    requestContactsPermission()
                    result.error("PERMISSION_DENIED", "Contacts permission not granted.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun hasContactsPermission(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestContactsPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_CONTACTS), CONTACTS_PERMISSION_CODE)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == CONTACTS_PERMISSION_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission granted, you can notify the Flutter side if needed.
            }
        }
    }

    private fun getContacts(): List<Map<String, String>>? {
        val contacts = mutableListOf<Map<String, String>>()
        val contentResolver: ContentResolver = contentResolver
        val cursor: Cursor? = contentResolver.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
            null,
            null,
            null,
            null
        )

        cursor?.use {
            while (it.moveToNext()) {
                val name = it.getString(it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME))
                val phoneNumber = it.getString(it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER))

                val contact = mapOf("name" to name, "phone" to phoneNumber)
                contacts.add(contact)
            }
        }
        return contacts
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