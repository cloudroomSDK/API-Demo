package com.meeting.example.common;

import android.app.Notification;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.Rect;
import android.os.Handler;
import android.os.Handler.Callback;
import android.os.Message;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.cloudroom.cloudroomvideosdk.CRMeetingCallback;
import com.cloudroom.cloudroomvideosdk.CloudroomVideoMeeting;
import com.cloudroom.cloudroomvideosdk.ScreenShareUIView;
import com.cloudroom.cloudroomvideosdk.model.CRVIDEOSDK_ERR_DEF;
import com.cloudroom.cloudroomvideosdk.model.MixerCotent;
import com.cloudroom.cloudroomvideosdk.model.ScreenShareCfg;
import com.cloudroom.cloudroomvideosdk.model.Size;
import com.cloudroom.screencapture.ScreenCaptureService;
import com.example.meetingdemo.R;
import com.meeting.DemoApp;
import com.meeting.example.tool.Tools;
import com.meeting.example.tool.UITool;

import java.util.ArrayList;

public class ScreenShareView extends PageView {

    private static final String TAG = "ScreenShareView";

    private ScreenShareUIView mScreenShareUIView = null;
    private TextView mSizeTV = null;
    private TextView mTvNum = null;
    private TextView mTvName = null;
    private TextView mTvDpi = null;
    private TextView mTvSharing = null;
    private Button btnCloseMic = null;
    private View mScreenShareOPtionView = null;
    private View mStartBtn = null;
    private View mStopBtn = null;

    public ScreenShareView(Context context) {
        super(context);
        init();
    }

    public ScreenShareView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.layout_screenshare_view, this);
        mScreenShareUIView = (ScreenShareUIView) findViewById(R.id.view_yuv_screenshare);
        mSizeTV = (TextView) findViewById(R.id.tv_size);
        mTvNum = (TextView) findViewById(R.id.tvNum);
        mTvName = (TextView) findViewById(R.id.tvName);
        mTvDpi = (TextView) findViewById(R.id.tvDpi);
        mTvSharing = (TextView) findViewById(R.id.tvSharing);
        mScreenShareOPtionView = findViewById(R.id.view_screen_share_option);
        mStartBtn = findViewById(R.id.btn_start_share);
        mStopBtn = findViewById(R.id.btn_stop_share);
        btnCloseMic = findViewById(R.id.btnCloseMic);

        CloudroomVideoMeeting.getInstance()
                .registerCallback(mCRMeetingCallback);

        // 显示视频需要启用hardwareAccelerated，某些设备会导致控件花屏，需要把不需要使用硬件加速的控件关闭硬件加速功能
        mSizeTV.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
        mScreenShareOPtionView.setLayerType(View.LAYER_TYPE_SOFTWARE, null);

        updateView();
    }

    public void setRoomMsg(int num, String nickname) {
        mTvNum.setText(getContext().getString(R.string.room_num, num));
        mTvName.setText(getContext().getString(R.string.user_name, nickname));
        DisplayMetrics metrics = new DisplayMetrics();
        metrics = getContext().getResources().getDisplayMetrics();
        int width = metrics.widthPixels;
        int height = metrics.heightPixels;
        mTvDpi.setText(getContext().getString(R.string.share_dpi, width
                + "*" + height));
    }

    private static final int UPDATE_VIDEO_SIZE = 0;
    protected Handler mMainHandler = new Handler(new Callback() {

        @Override
        public boolean handleMessage(Message msg) {
            // TODO Auto-generated method stub
            switch (msg.what) {
                case UPDATE_VIDEO_SIZE:
                    updateVideoSize();
                    break;
                default:
                    break;
            }
            return false;
        }
    });

    @Override
    public boolean onViewClick(View v, int vID) {
        if (vID == R.id.btn_start_share) {
            startScreenShare();
            return true;
        } else if (vID == R.id.btn_stop_share) {
           stopScreenShare();
            return true;
        } else if (vID == R.id.btn_screen_catch) {
            String pathFileName = String.format("%s/screen_%s.jpg",
                    DemoApp.SDK_DATA_PATH, Tools.getCurrentTimeStr());
            mScreenShareUIView.savePicToFile(pathFileName, CompressFormat.JPEG);
            UITool.showPicDialog(getContext(), pathFileName);
            return true;
        }
        return false;
    }

    public void stopScreenShare(){
        CloudroomVideoMeeting.getInstance().stopScreenShare();
        mStartBtn.setVisibility(View.VISIBLE);
        mStopBtn.setVisibility(View.GONE);
        mTvSharing.setVisibility(View.GONE);
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        // TODO Auto-generated method stub
        return false;
    }

    private void startScreenShare() {
        ScreenShareCfg cfg = new ScreenShareCfg();
        // 共享帧率
        cfg.maxFps = 12;
        // 共享码率
        cfg.maxBps = 2000 * 1000;
        // 配置共享参数
        CloudroomVideoMeeting.getInstance().setScreenShareCfg(cfg);
        // 开始共享
        /*
         * 注：共享屏幕需要相应授权，请添加下面权限申请界面声明到主配置文件 <activity
         * android:name="com.cloudroom.screencapture.PermissionActivity"
         * android:configChanges=
         * "orientation|uiMode|screenLayout|screenSize|smallestScreenSize|locale|fontScale|keyboard|keyboardHidden|navigation"
         * android:launchMode="singleTop" android:screenOrientation="sensor" >
         * </activity>
         */
        CloudroomVideoMeeting.getInstance().startScreenShare(new ScreenCaptureService.ScreenCallback() {

            @Override
            public void configNotification(Notification.Builder notice) {
                Context context = getContext();
                // 通知图标
                notice.setSmallIcon(R.mipmap.ic_launcher);
                // 通知标题文字
                notice.setContentTitle(context.getString(R.string.app_name));
                // 通知内容
                notice.setContentText(context.getString(R.string.app_name));
                notice.setTicker(context.getString(R.string.app_name));

//				// 通知点击操作，回到通话界面
//				Intent appIntent = new Intent(Intent.ACTION_MAIN);
//				appIntent.addCategory(Intent.CATEGORY_LAUNCHER);
//				appIntent.setComponent(new ComponentName(context.getPackageName(), TalkActivity.this.getLocalClassName()));
//				appIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK
//						| Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED);
//				PendingIntent contentIntent = PendingIntent.getActivity(
//						TalkActivity.this, 0, appIntent, 0);
//				notice.setContentIntent(contentIntent);

//				NotificationsUtils.requestNotification(getContext());
            }
        });

        mStartBtn.setVisibility(View.INVISIBLE);
        mStopBtn.setVisibility(View.VISIBLE);
        mTvSharing.setVisibility(View.VISIBLE);
    }

    private void updateVideoSize() {
        mMainHandler.sendEmptyMessageDelayed(UPDATE_VIDEO_SIZE, 1000);
        if (mSizeTV.getVisibility() != View.VISIBLE) {
            return;
        }
        int w = mScreenShareUIView.getPicWidth();
        int h = mScreenShareUIView.getPicHeight();
        mSizeTV.setText("" + w + "X" + h);
    }

    private CRMeetingCallback mCRMeetingCallback = new CRMeetingCallback() {

        @Override
        public void enterMeetingRslt(CRVIDEOSDK_ERR_DEF code) {
            // TODO Auto-generated method stub
            Log.d(TAG, "enterMeetingRslt:" + code);
            if (code != CRVIDEOSDK_ERR_DEF.CRVIDEOSDK_NOERR) {
                return;
            }
            updateView();
        }

        @Override
        public void notifyScreenShareStarted() {
            // TODO Auto-generated method stub
            Log.d(TAG, "notifyScreenShareStarted");
            updateView();
        }

        @Override
        public void notifyScreenShareStopped() {
            // TODO Auto-generated method stub
            updateView();
            Log.d(TAG, "notifyScreenShareStopped");
        }

        @Override
        public void startScreenShareRslt(CRVIDEOSDK_ERR_DEF sdkErr) {
            // TODO Auto-generated method stub
            Log.d(TAG, "startScreenShareRslt:" + sdkErr);
            if (sdkErr == CRVIDEOSDK_ERR_DEF.CRVIDEOSDK_NOERR) {
                if (mPageCallback != null) {
                    mPageCallback.uiContentChanged();
                }
            } else {
                mStartBtn.setVisibility(View.VISIBLE);
                mStopBtn.setVisibility(View.GONE);
                mTvSharing.setVisibility(View.GONE);
            }
        }

        @Override
        public void stopScreenShareRslt(CRVIDEOSDK_ERR_DEF sdkErr) {
            // TODO Auto-generated method stub
            Log.d(TAG, "stopScreenShareRslt:" + sdkErr);
            if (sdkErr == CRVIDEOSDK_ERR_DEF.CRVIDEOSDK_NOERR) {
                if (mPageCallback != null) {
                    mPageCallback.uiContentChanged();
                }
            } else {

            }
        }

    };

    private void updateView() {
        boolean showShareView = false;
        boolean isScreenShareStarted = CloudroomVideoMeeting.getInstance()
                .isScreenShareStarted();
        if (isScreenShareStarted) {
            String screenSharer = CloudroomVideoMeeting.getInstance()
                    .getScreenSharer();
            String myUserID = CloudroomVideoMeeting.getInstance().getMyUserID();
            if (!myUserID.equals(screenSharer)) {
                showShareView = true;
            }
        }
        mStartBtn.setVisibility(isScreenShareStarted ? View.INVISIBLE : View.VISIBLE);
        mStopBtn.setVisibility(isScreenShareStarted ? View.VISIBLE : View.GONE);
        mTvSharing.setVisibility(isScreenShareStarted ? View.VISIBLE : View.GONE);
        mScreenShareOPtionView.setVisibility(showShareView ? View.GONE
                : View.VISIBLE);

        if (mPageCallback != null) {
            mPageCallback.uiContentChanged();
        }
    }

    @Override
    public void addMixerCotents(Size recSize, boolean bLocalMixer,
                                ArrayList<MixerCotent> contents) {
        // TODO Auto-generated method stub
        boolean isScreenShareStarted = CloudroomVideoMeeting.getInstance()
                .isScreenShareStarted();
        if (!isScreenShareStarted) {
            return;
        }

        String screenSharer = CloudroomVideoMeeting.getInstance()
                .getScreenSharer();
        String myUserID = CloudroomVideoMeeting.getInstance().getMyUserID();
        MixerCotent content = null;
        if (bLocalMixer && myUserID.equals(screenSharer)) {
            content = MixerCotent.createScreenContent(new Rect(0, 0,
                    recSize.width, recSize.height));
        } else {
            content = MixerCotent.createRemoteScreenContent(new Rect(0, 0,
                    recSize.width, recSize.height));
        }
        content.bKeepAspectRatio = true;
        contents.add(content);
    }

}
