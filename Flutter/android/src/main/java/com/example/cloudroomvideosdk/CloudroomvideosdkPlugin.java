package com.example.cloudroomvideosdk;

import android.content.Context;
import androidx.annotation.NonNull;
import com.example.cloudroomvideosdk.CloudroomPlatformViewFactory;
import com.example.cloudroomvideosdk.CloudroomSDKMethod;
import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;

public class CloudroomvideosdkPlugin
  implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {

  private static String TAG = "CloudroomVideoSDK";
  private MethodChannel channel;
  private EventChannel eventChannel;
  private EventChannel.EventSink eventSink;
  private Context context;
  private Class<?> cloudroomSDKMethods;
  private final HashMap<String, Method> methodHashMap = new HashMap<>();

  public CloudroomvideosdkPlugin() {
    try {
      this.cloudroomSDKMethods =
        Class.forName("com.example.cloudroomvideosdk.CloudroomSDKMethod");
    } catch (ClassNotFoundException e) {
      Log.e(TAG, "ClassNotFoundException");
      throw new RuntimeException(e);
    }
  }

  @Override
  public void onAttachedToEngine(
    @NonNull FlutterPluginBinding flutterPluginBinding
  ) {
    channel =
      new MethodChannel(
        flutterPluginBinding.getBinaryMessenger(),
        "cr_flutter_sdk"
      );
    channel.setMethodCallHandler(this);

    EventChannel eventChannel = new EventChannel(
      flutterPluginBinding.getFlutterEngine().getDartExecutor(),
      "cr_flutter_sdk_event_handler"
    );
    eventChannel.setStreamHandler(this);

    context = flutterPluginBinding.getApplicationContext();

    // Register platform view factory
    flutterPluginBinding
      .getPlatformViewRegistry()
      .registerViewFactory(
        "cr_flutter_sdk_view",
        CloudroomPlatformViewFactory.getInstance()
      );
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    eventSink = events;
  }

  @Override
  public void onCancel(Object arguments) {
    eventSink = null;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Log.e(TAG, "method：" + call.method);
    String callMethod = call.method;
    try {
      Method method = methodHashMap.get(callMethod);
      if (method == null) {
        if (callMethod.equals("init")) {
          method =
            this.cloudroomSDKMethods.getMethod(
                callMethod,
                MethodCall.class,
                Result.class,
                Context.class,
                EventChannel.EventSink.class
              );
        } else {
          method =
            this.cloudroomSDKMethods.getMethod(callMethod, MethodCall.class, Result.class);
        }
        methodHashMap.put(callMethod, method);
      }

      if (callMethod.equals("init")) {
        method.invoke(null, call, result, context, eventSink);
      } else {
        method.invoke(null, call, result);
      }
    } catch (NoSuchMethodException e) {
      Log.e(TAG, "NoSuchMethodException");
      result.notImplemented();
    } catch (IllegalAccessException e) {
      Log.e(TAG, "IllegalAccessException");
      result.notImplemented();
    } catch (InvocationTargetException e) {
      Log.e(TAG, "InvocationTargetException");
      result.notImplemented();
    }
  }
}
