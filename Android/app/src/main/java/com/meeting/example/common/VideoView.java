package com.meeting.example.common;

import android.content.Context;
import android.os.Handler;
import android.util.AttributeSet;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.cloudroom.cloudroomvideosdk.CloudroomVideoMeeting;
import com.cloudroom.cloudroomvideosdk.VideoUIView;
import com.cloudroom.cloudroomvideosdk.model.UsrVideoId;
import com.example.meetingdemo.R;

public class VideoView extends RelativeLayout {

    @SuppressWarnings("unused")
    private static final String TAG = "VideoView";

    protected static Handler mMainHandler = new Handler();

    private VideoUIView mVideoUIView = null;
    private TextView mNickNameTV = null;

    public VideoView(Context context) {
        super(context);
        // TODO Auto-generated constructor stub
        init();
    }

    public VideoView(Context context, AttributeSet attrs) {
        super(context, attrs);
        // TODO Auto-generated constructor stub
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.layout_videoview, this);
        mVideoUIView = (VideoUIView) findViewById(R.id.view_yuv_video);
        mNickNameTV = (TextView) findViewById(R.id.tv_nickname);
        setUsrVideoId(null);
//        setScaleType(VideoUIView.SCALE_TYPE_CENTERCROP);
        // 观看其他档位视频1-3
        // mVideoUIView.setQualityLevel(2);

        // 显示视频需要启用hardwareAccelerated，某些设备会导致控件花屏，需要把不需要使用硬件加速的控件关闭硬件加速功能
        mNickNameTV.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
        findViewById(R.id.view_video_back).setLayerType(
                View.LAYER_TYPE_SOFTWARE, null);
    }

    public void setUsrVideoId(UsrVideoId usrVideoId) {
        if (usrVideoId == null) {
            mVideoUIView.setVisibility(View.GONE);
            mNickNameTV.setVisibility(View.GONE);
        } else {
            mVideoUIView.setVisibility(View.VISIBLE);
            mNickNameTV.setVisibility(View.VISIBLE);
            String nickName = CloudroomVideoMeeting.getInstance().getNickName(
                    usrVideoId.userId);
            mNickNameTV.setText(nickName);
        }
        mVideoUIView.setUsrVideoId(usrVideoId);
        postInvalidate();
    }

    public void setScaleType(int scaleType) {
        mVideoUIView.setScaleType(scaleType);
    }

    public UsrVideoId getUsrVideoId() {
        return mVideoUIView.getUsrVideoId();
    }

    public void resetSufaceView() {
        if (mVideoUIView.getVisibility() == VISIBLE) {
            mVideoUIView.setVisibility(View.INVISIBLE);
            mVideoUIView.setVisibility(View.VISIBLE);
        }
    }
}
