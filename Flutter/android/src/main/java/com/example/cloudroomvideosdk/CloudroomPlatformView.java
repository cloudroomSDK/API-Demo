package com.example.cloudroomvideosdk;

import android.content.Context;
import android.view.View;
import android.widget.*;
import com.cloudroom.cloudroomvideosdk.VideoUIView;
import io.flutter.plugin.platform.PlatformView;

public class CloudroomPlatformView implements PlatformView {

  // SDK的视频显示控件
  private VideoUIView videoUIView = null;

  CloudroomPlatformView(Context context) {
    this.videoUIView = new VideoUIView(context);
  }
  
  public VideoUIView getVideoUIView() {
    return this.videoUIView;
  }

  @Override
  public View getView() {
    return this.videoUIView;
  }

  @Override
  public void dispose() {
    this.videoUIView = null;
  }
}
