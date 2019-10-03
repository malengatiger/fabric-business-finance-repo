package com.aftarobot.testbfn.api;

import com.aftarobot.testbfn.data.GovtEntity;

import java.util.List;

import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.POST;
import retrofit2.http.PUT;
import retrofit2.http.Path;
import retrofit2.http.Query;

/**
 * Created by aubreymalabie on 1/12/18.
 */

public interface ApiInterface {
    @POST("GovtEntity")
    Call<GovtEntity> addGovtEntity (@Body GovtEntity govtEntity);

    @GET("GovtEntity")
    Call<List<GovtEntity>> getGovtEntities();


}
