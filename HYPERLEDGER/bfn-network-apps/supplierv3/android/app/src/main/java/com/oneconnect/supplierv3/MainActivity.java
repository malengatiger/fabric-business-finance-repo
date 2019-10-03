package com.oneconnect.supplierv3;

import android.Manifest;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import android.util.Log;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import org.apache.commons.io.FileUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.oneconnect.files/pdf";
    private MethodChannel.Result mResult;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        Log.d(TAG, "onCreate: ########## starting to call Android method ");
        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        Log.w(TAG, "onMethodCall: storing result object ............"  );
                        mResult = result;
                        if (checkPermissions()) {
                            if (call.method.equals("getBatteryLevel")) {
                                startStuff();
                            } else {
                                result.notImplemented();
                            }
                        }

                    }
                });
    }


    private int getBatteryLevel() {
        Log.d(TAG, "getBatteryLevel: ");
        int batteryLevel = -1;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext()).
                    registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }

        return batteryLevel;
    }

    private boolean checkPermissions() {
        if (ContextCompat.checkSelfPermission(this,
                android.Manifest.permission.WRITE_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {

            Log.d(TAG, ".......................onConnected: Requesting external storage  permission");
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE},
                    MY_PERMISSIONS_WRITE_EXTERNAL_STORAGE);
            return false;
        }
        return true;

    }

    public static final Gson G = new GsonBuilder().setPrettyPrinting().create();
    public static final Gson GSON = new Gson();

    public static  final String[] extensions = { "pdf" };
    private void startStuff() {
        List<File> files = new ArrayList<>();
        files.addAll(getImportFiles());

        List<String> paths = new ArrayList<>();
        for (File f : files) {
            paths.add(f.getAbsolutePath());
            Log.w(TAG, "startStuff: path: ".concat(f.getAbsolutePath()));
        }
        Bag bag = new Bag(paths);
        Log.d(TAG, "startStuff: ========== result from disk search:".concat(G.toJson(bag)));
        String m = GSON.toJson(bag);
        assert (mResult != null);
        mResult.success(m);
    }

    private List<File> getImportFiles() {
        Log.w(TAG, "getImportFiles: *****************************" );
        File extDir = Environment.getRootDirectory();
        String state = Environment.getExternalStorageState();

        // TODO check thru all state possibilities
        if (!state.equalsIgnoreCase(Environment.MEDIA_MOUNTED)) {
            Log.e(TAG, "getImportFiles: media is not mounted" );
            return new ArrayList<File>();
        }

        List<File> fileList = getImportFilesOnSD();
        @SuppressWarnings("unchecked")
        Iterator<File> iter = FileUtils.iterateFiles(extDir, extensions, true);

        while (iter.hasNext()) {
            File file = iter.next();
            if (file.getName().startsWith("._")) {
                continue;
            }
            fileList.add(file);
            Log.d(TAG, "getImportFiles: ### disk Import File: " + file.getAbsolutePath());
        }

        Log.i(TAG, "### Import Files in list : " + fileList.size());
        return fileList;
    }

    private List<File> getImportFilesOnSD() {
        Log.d(TAG, "getImportFilesOnSD: #################################### ");
        File extDir = Environment.getExternalStorageDirectory();
        String state = Environment.getExternalStorageState();
        // TODO check thru all state possibilities
        if (!state.equalsIgnoreCase(Environment.MEDIA_MOUNTED)) {
            return new ArrayList<File>();
        }

        List<File> fileList = new ArrayList<File>();
        @SuppressWarnings("unchecked")
        Iterator<File> iter = FileUtils.iterateFiles(extDir, extensions, true);

        while (iter.hasNext()) {
            File file = iter.next();
            if (file.getName().startsWith("._")) {
                continue;
            }
            fileList.add(0, file);
            Log.d(TAG, "getImportFilesOnSD: ### disk Import File: " + file.getAbsolutePath());
        }

        Log.i(TAG, "############### SD Import Files in list : " + fileList.size());
        return fileList;
    }


    static final int MY_PERMISSIONS_WRITE_EXTERNAL_STORAGE = 811;

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        Log.i(TAG, "onRequestPermissionsResult: @@@@@@@@@ grantResults: " + grantResults);
        switch (requestCode) {
            case MY_PERMISSIONS_WRITE_EXTERNAL_STORAGE: {
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    Log.d(TAG, "PERMISSIONS_WRITE_EXTERNAL_STORAGE permission granted");
                    Toast.makeText(getApplicationContext(), "Permission granted", Toast.LENGTH_SHORT).show();
                    startStuff();

                } else {
                    Log.e(TAG, "MY_PERMISSIONS_WRITE_EXTERNAL_STORAGE permission denied");
                    Toast.makeText(getApplicationContext(), "Permission denied", Toast.LENGTH_SHORT).show();
                    finish();

                }
                return;
            }


            // other 'case' lines to check for other
            // permissions this app might request
        }
    }

    private class Bag {
        List<String> paths;

        public Bag(List<String> paths) {
            this.paths = paths;
        }

        public List<String> getPaths() {
            return paths;
        }

        public void setPaths(List<String> paths) {
            this.paths = paths;
        }
    }

    public static final String TAG = MainActivity.class.getSimpleName();
}
