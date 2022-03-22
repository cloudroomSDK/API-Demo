package com.example.cloudroomvideosdk;

import android.content.Context;
import android.view.View;
import android.widget.*;
import com.cloudroom.cloudroomvideosdk.ScreenShareUIView;
import io.flutter.plugin.platform.PlatformView;

public class CloudroomScreenShareView implements PlatformView {

  // SDK的视频显示控件
  private ScreenShareUIView screenShareUIView = null;

  CloudroomScreenShareView(Context context) {
    this.screenShareUIView = new ScreenShareUIView(context);
  }
  
  public ScreenShareUIView getScreenShareUIView() {
    return this.screenShareUIView;
  }

  @Override
  public View getView() {
    return this.screenShareUIView;
  }

  @Override
  public void dispose() {
    this.screenShareUIView = null;
  }
}
