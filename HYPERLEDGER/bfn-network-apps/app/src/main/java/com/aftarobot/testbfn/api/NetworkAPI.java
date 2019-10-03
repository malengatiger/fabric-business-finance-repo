package com.aftarobot.testbfn.api;

import android.content.Context;
import android.support.annotation.NonNull;
import android.util.Log;

import com.aftarobot.testbfn.data.Data;
import com.aftarobot.testbfn.data.GovtEntity;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class NetworkAPI {
    private ApiInterface apiService;
    private Context context;

    public NetworkAPI(Context ctx) {
        context = ctx;
        apiService = APIClient.getClient(ctx).create(ApiInterface.class);
    }

    public interface Listener {
        void onResponse(Data data);

        void onError(String message);
    }
    public void addGovtEntity(final GovtEntity govtEntity, final Listener listener) {
        Call<GovtEntity> call = apiService.addGovtEntity(govtEntity);
        call.enqueue(new Callback<GovtEntity>() {
            @Override
            public void onResponse(@NonNull Call<GovtEntity> call, @NonNull Response<GovtEntity> response) {
                if (response.isSuccessful()) {
                    Log.i(TAG, "GovtEntity added: ".concat(govtEntity.getName()));
                    listener.onResponse(response.body());
                } else {
                    Log.e(TAG, "onResponse: ".concat(G.toJson(response.errorBody())));
                    listener.onError("Failed to add GovtEntity");
                }
            }

            @Override
            public void onFailure(@NonNull Call<GovtEntity> call, Throwable t) {
                Log.e(TAG, "onFailure: ", t);
                listener.onError("Failed to add GovtEntity");

            }
        });
    }

    public static final String TAG = NetworkAPI.class.getSimpleName();
    public static final Gson G = new GsonBuilder().setPrettyPrinting().create();
}
