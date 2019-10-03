package com.aftarobot.testbfn.api;

/**
 * Created by aubreymalabie on 1/12/18.
 */

import android.content.Context;
import android.util.Log;

import com.aftarobot.testbfn.BuildConfig;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;


public class APIClient {

    public static final String BASE_URL_DEBUG = "http://192.168.86.238:3003/api/";
    public static final String BASE_URL_RELEASE = "http://192.168.8.100:3003/api/";
    private static Retrofit retrofit = null;
    private static OkHttpClient okHttpClient;


    public static Retrofit getClient() {
        String url;
        if (BuildConfig.DEBUG) {
            url = BASE_URL_DEBUG;
        } else {
            url = BASE_URL_RELEASE;
        }
        return getRetro(url);
    }

    public static Retrofit getClient(Context context) {
        String url;
        if (BuildConfig.DEBUG) {
            url = BASE_URL_DEBUG;
        } else {
            url = BASE_URL_RELEASE;
        }
        String net = CheckNet.getNetworkName(context);
        if (net != null && BuildConfig.DEBUG) {
            if (net.contains("HUAWEI")) {
                url = "http://192.168.8.237:3003/api/";
            }
            if (net.contains("The Wall")) {
                url = "http://192.168.86.238:3003/api/";
            }
        }
        Log.d(TAG, "getClient: url: ".concat(url));
        return getRetro(url);
    }

    private static Retrofit getRetro(String url) {

        okHttpClient = new OkHttpClient();
        okHttpClient.newBuilder()
                .connectTimeout(60, TimeUnit.SECONDS)
                .readTimeout(60, TimeUnit.SECONDS)
                .writeTimeout(60, TimeUnit.SECONDS);

        retrofit = new Retrofit.Builder()
                .baseUrl(url)
                .client(okHttpClient)
                .addConverterFactory(GsonConverterFactory.create())
                .build();


        Log.e(TAG, "getClient: executed ok, have retrofit object .....".concat(retrofit.toString()));
        return retrofit;
    }
    public static final String TAG = APIClient.class.getSimpleName();
    public static final Gson G = new GsonBuilder().setPrettyPrinting().create();
}
