package com.example.cloudroomvideosdk;

import android.content.Context;
import android.view.View;
import android.widget.*;
import com.cloudroom.cloudroomvideosdk.MediaUIView;
import io.flutter.plugin.platform.PlatformView;

public class CloudroomMediaView implements PlatformView {

  // SDK的视频显示控件
  private MediaUIView mediaUIView = null;

  CloudroomMediaView(Context context) {
    this.mediaUIView = new MediaUIView(context);
  }
  
  public MediaUIView getMediaUIView() {
    return this.mediaUIView;
  }

  @Override
  public View getView() {
    return this.mediaUIView;
  }

  @Override
  public void dispose() {
    this.mediaUIView = null;
  }
}
