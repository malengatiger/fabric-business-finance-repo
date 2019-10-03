package com.aftarobot.testbfn.api;

import android.content.Context;
import android.util.Log;

import com.aftarobot.testbfn.data.GovtEntity;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.io.IOException;
import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class NetworkListAPI {
    public void getGovtEntities(final GovtEntityListener listener) {
        Call<List<GovtEntity>> call = apiService.getGovtEntities();
        Log.w(TAG, "calling ... " + call.request().url().url().toString());
        call.enqueue(new Callback<List<GovtEntity>>() {
            @Override
            public void onResponse(Call<List<GovtEntity>> call, Response<List<GovtEntity>> response) {
                if (response.isSuccessful()) {
                    List<GovtEntity> list = response.body();
                    Log.i(TAG, "getBanks returns: ".concat(G.toJson(list)));
                    listener.onResponse(response.body());

                } else {
                    try {
                        Log.e(TAG, "onResponse: things are fucked up!: ".concat(response.message())
                                .concat(" code: ".concat(String.valueOf(response.code())).concat(" body: ")
                                        .concat(response.errorBody().string())));
                        listener.onError(response.errorBody().string());
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }

            @Override
            public void onFailure(Call<List<GovtEntity>> call, Throwable t) {
                Log.e(TAG, "onFailure: ", t);
                listener.onError("call failed");
            }
        });
    }
    private ApiInterface apiService;
    private Context context;
    public interface GovtEntityListener {
        void onResponse(List<GovtEntity> entities);
        void onError(String message);
    }

    public NetworkListAPI(Context ctx) {
        context = ctx;
        apiService = APIClient.getClient(ctx).create(ApiInterface.class);
    }

    public static final String TAG = NetworkAPI.class.getSimpleName();
    public static final Gson G = new GsonBuilder().setPrettyPrinting().create();
}
