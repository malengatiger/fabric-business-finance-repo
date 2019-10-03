package com.oneconnect.investor;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;
import android.os.Bundle;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.util.HashMap;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StringCodec;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.view.FlutterView;

public class MainActivity extends FlutterActivity {
    static final String CHANNEL_ID = "com.oneconnect.biz.CHANNEL";
    static final String MESSAGE_CHANNEL = "com.oneconnect.biz.CHANNEL/message";
    MethodChannel.Result mResult;
    private BasicMessageChannel<String> messageChannel;
    static FlutterView flutterView;
    static String title;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        flutterView = getFlutterView();
        createNotificationChannel();
        setMessageChannel();


        Log.d(TAG, "onCreate: ########## starting to call Android method ");
        new MethodChannel(getFlutterView(), CHANNEL_ID).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        Log.w(TAG, "onMethodCall: storing result object ............");
                        mResult = result;
                        HashMap<String, String> map = (HashMap<String, String> ) call.arguments;
                        if (call.method.equals("setNotification")) {
                            title = map.get("title");
                            setNotification(map.get("title"), map.get("content"));
                        } else {
                            result.notImplemented();
                        }
                    }


                });
    }
    NotificationManagerCompat notificationManager;
    public static final String EXTRA_NOTIFICATION_ID = "oneconnect.extra";
    private void setNotification(String title, String content) {
        Log.w(TAG, "setNotification: +++++++++++++++++++++++++++++" );
//        Intent snoozeIntent = new Intent(this, TapReceiver.class);
//        snoozeIntent.setAction(Intent.ACTION_DEFAULT);
//        snoozeIntent.putExtra(EXTRA_NOTIFICATION_ID, "NotificationTapped");
//        PendingIntent snoozePendingIntent =
//                PendingIntent.getBroadcast(getApplicationContext(), 0, snoozeIntent, 0);
//        try {
//            NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this, CHANNEL_ID)
//                    .setSmallIcon(android.support.v4.R.drawable.notification_icon_background)
//                    .setContentTitle(title)
//                    .setContentText(content)
//                    .setPriority(NotificationCompat.PRIORITY_HIGH)
//                    .setContentIntent(snoozePendingIntent);
//             notificationManager = NotificationManagerCompat.from(this);
//            mBuilder.setSubText("this is a subtext");
//            notificationManager.notify(1234, mBuilder.build());
//            mResult.success("Notification has been sent, maybe? ....");
//        } catch (Exception e) {
//            mResult.error(e.getMessage(),
//                    "Notification failed", null );
//        }
    }
    private void setMessageChannel() {

        Log.w(TAG, "setMessageChannel: @@@@@@@@@@@@@@@@@@@@@@" );
        messageChannel = new BasicMessageChannel<>(getFlutterView(), MESSAGE_CHANNEL, StringCodec.INSTANCE);
        messageChannel.
                setMessageHandler(new BasicMessageChannel.MessageHandler<String>() {
                    @Override
                    public void onMessage(String s, BasicMessageChannel.Reply<String> reply) {
                        onFlutterMessage();
                        reply.reply("");
                    }
                });

    }

    private void onFlutterMessage() {
        Log.d(TAG, "onFlutterMessage: ..................");
    }

    private void createNotificationChannel() {
        Log.d(TAG, "createNotificationChannel: ###############################");
        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CharSequence name = "BFN Network";
            String description = "The BFN Network Channel";
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, name, importance);
            channel.setDescription(description);
            // Register the channel with the system; you can't change the importance
            // or other notification behaviors after this
            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
    }
//    private void registerReceiver() {
//        registerReceiver(new TapReceiver(), new IntentFilter("tapped"));
//    }

    public static final String TAG = MainActivity.class.getSimpleName();
    public static final Gson G = new GsonBuilder().setPrettyPrinting().create();
}
