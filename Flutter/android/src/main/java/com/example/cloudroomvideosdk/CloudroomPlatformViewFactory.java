package com.example.cloudroomvideosdk;

import android.content.Context;
import com.google.gson.Gson;
import io.flutter.Log;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.HashMap;
import java.util.Map;

public class CloudroomPlatformViewFactory extends PlatformViewFactory {

  private static CloudroomPlatformViewFactory instance;
  // 视频控件
  private final HashMap<Integer, CloudroomPlatformView> platformViews;
  // 共享视频控件
  private final HashMap<Integer, CloudroomScreenShareView> screenShareViews;
  // 播视频控件
  private final HashMap<Integer, CloudroomMediaView> mediaViews;

  private final Gson gson = new Gson();

  private CloudroomPlatformViewFactory(MessageCodec<Object> createArgsCodec) {
    super(createArgsCodec);
    this.platformViews = new HashMap<>();
    this.screenShareViews = new HashMap<>();
    this.mediaViews = new HashMap<>();
  }

  public static CloudroomPlatformViewFactory getInstance() {
    if (instance == null) {
      synchronized (CloudroomPlatformViewFactory.class) {
        if (instance == null) {
          instance =
            new CloudroomPlatformViewFactory(StandardMessageCodec.INSTANCE);
        }
      }
    }
    return instance;
  }

  @Override
  public PlatformView create(Context context, int viewId, Object args) {
    Map params = gson.fromJson(gson.toJson(args), Map.class);
    String viewType = (String) params.get("viewType");
    if (viewType.equals("mediaview")) {
      CloudroomMediaView view = new CloudroomMediaView(context);
      this.addMediaView(viewId, view);
      return view;
    } else if (viewType.equals("screenshareview")) {
      CloudroomScreenShareView view = new CloudroomScreenShareView(context);
      this.addScreenShareView(viewId, view);
      return view;
    }
    CloudroomPlatformView view = new CloudroomPlatformView(context);
    this.addPlatformView(viewId, view);
    return view;
  }

  public CloudroomPlatformView getPlatformView(int viewID) {
    return this.platformViews.get(viewID);
  }

  private void addPlatformView(int viewID, CloudroomPlatformView view) {
    this.platformViews.put(viewID, view);
  }

  public Boolean destroyPlatformView(int viewID) {
    CloudroomPlatformView platformView = this.platformViews.get(viewID);
    if (platformView == null) {
      return false;
    }
    this.platformViews.remove(viewID);
    return true;
  }

  // 视频共享
  public CloudroomScreenShareView getScreenShareView(int viewID) {
    return this.screenShareViews.get(viewID);
  }

  private void addScreenShareView(int viewID, CloudroomScreenShareView view) {
    this.screenShareViews.put(viewID, view);
  }

  public Boolean destroyScreenShareView(int viewID) {
    CloudroomScreenShareView screenShareView =
      this.screenShareViews.get(viewID);
    if (screenShareView == null) {
      return false;
    }
    this.screenShareViews.remove(viewID);
    return true;
  }

  // 媒体UI
  public CloudroomMediaView getMediaView(int viewID) {
    return this.mediaViews.get(viewID);
  }

  private void addMediaView(int viewID, CloudroomMediaView view) {
    this.mediaViews.put(viewID, view);
  }

  public Boolean destroyMediaView(int viewID) {
    CloudroomMediaView mediaView = this.mediaViews.get(viewID);
    if (mediaView == null) {
      return false;
    }
    this.mediaViews.remove(viewID);
    return true;
  }
}
