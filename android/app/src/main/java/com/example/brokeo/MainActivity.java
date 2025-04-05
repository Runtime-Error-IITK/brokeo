package com.example.brokeo;

import android.Manifest;
import android.content.ContentResolver;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.os.Build;
import android.provider.ContactsContract;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.contacts/fetch";
    private static final int CONTACTS_PERMISSION_CODE = 1001;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine); // Ensure plugins are registered
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("getContacts")) {
                        if (hasContactsPermission()) {
                            List<Map<String, String>> contacts = getContacts();
                            if (contacts != null) {
                                result.success(contacts);
                            } else {
                                result.error("UNAVAILABLE", "Contacts not available.", null);
                            }
                        } else {
                            requestContactsPermission();
                            result.error("PERMISSION_DENIED", "Contacts permission not granted.", null);
                        }
                    } else {
                        result.notImplemented();
                    }
                }
            );
    }

    private boolean hasContactsPermission() {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
               ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) == PackageManager.PERMISSION_GRANTED;
    }

    private void requestContactsPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.READ_CONTACTS}, CONTACTS_PERMISSION_CODE);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == CONTACTS_PERMISSION_CODE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission granted, you can notify the Flutter side if needed.
            }
        }
    }

    private List<Map<String, String>> getContacts() {
        List<Map<String, String>> contacts = new ArrayList<>();
        ContentResolver contentResolver = getContentResolver();
        Cursor cursor = contentResolver.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
            null,
            null,
            null,
            null
        );

        if (cursor != null) {
            while (cursor.moveToNext()) {
                String name = cursor.getString(
                    cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
                );
                String phoneNumber = cursor.getString(
                    cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
                );

                Map<String, String> contact = new HashMap<>();
                contact.put("name", name);
                contact.put("phone", phoneNumber);
                contacts.add(contact);
            }
            cursor.close();
        }
        return contacts;
    }
}
