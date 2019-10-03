package com.aftarobot.testbfn.api;

import android.content.Context;
import android.net.wifi.SupplicantState;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.util.Log;

public class CheckNet {

    public static String getNetworkName(Context context) {
        WifiManager wifiManager = (WifiManager) context.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        WifiInfo wifiInfo;
        String ssid = null;

        if (wifiManager != null) {
            wifiInfo = wifiManager.getConnectionInfo();
            if (wifiInfo.getSupplicantState() == SupplicantState.COMPLETED) {
                ssid = wifiInfo.getSSID();
            }
            if (ssid == null) {
                //throw new RuntimeException("Network name check failed");
                Log.e("CheckNet", "Network name check failed ---- WTF?" );
            } else {
                Log.e("CheckNet", "check: network:  ".concat(ssid));
            }
        } else {
            Log.e("CheckNet", "getNetworkName: WIFI manager is null" );
        }

        return ssid;
    }
}
