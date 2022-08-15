package com.meeting.example.common;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.Rect;
import android.os.Handler;
import android.os.Handler.Callback;
import android.os.Message;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;
import android.widget.Toast;

import com.cloudroom.cloudroomvideosdk.CRMeetingCallback;
import com.cloudroom.cloudroomvideosdk.CloudroomVideoMeeting;
import com.cloudroom.cloudroomvideosdk.MediaUIView;
import com.cloudroom.cloudroomvideosdk.model.CRVIDEOSDK_ERR_DEF;
import com.cloudroom.cloudroomvideosdk.model.MEDIA_STATE;
import com.cloudroom.cloudroomvideosdk.model.MEDIA_STOP_REASON;
import com.cloudroom.cloudroomvideosdk.model.MediaInfo;
import com.cloudroom.cloudroomvideosdk.model.MixerCotent;
import com.cloudroom.cloudroomvideosdk.model.Size;
import com.example.meetingdemo.R;
import com.meeting.DemoApp;
import com.meeting.example.tool.Tools;
import com.meeting.example.tool.UITool;

import java.util.ArrayList;

@SuppressLint({"InlinedApi", "DefaultLocale"})
public class MediaShareView extends PageView {

    private static final String TAG = "VideoView";

    private static final int UPDATE_VIDEO_SIZE = 0;
    protected Handler mMainHandler = new Handler(new Callback() {

        @Override
        public boolean handleMessage(Message msg) {
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

    private MediaUIView mMediaUIView = null;
    private TextView mSizeTV = null;
    private TextView tvVideoName = null;
    private View mMediaShareOPtionView = null;
    private String videoPath = "";
    private SeekBar mSeekBar = null;
    private SeekBar mVolumeSeekBar = null;
    private ImageView mPauseBtn = null;
    private ImageView mPlayBtn = null;
    private Button mPlayBtn2 = null;
    private Button mStopBtn = null;
    private TextView mTimeTV = null;
    private View mMediaOptionView = null;
    private CheckBox mPauseEndCB = null;
    private CheckBox mPlayLocalCB = null;
    private boolean isLocalMedia = false;
    private LinearLayout llBtn = null;
    private ImageView ivPlay = null;
    private boolean isMyShare = false;

    public MediaShareView(Context context) {
        super(context);
        init();
    }

    public MediaShareView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.layout_media_view, this);
        mMediaUIView = (MediaUIView) findViewById(R.id.view_yuv_mediashare);
        mSizeTV = (TextView) findViewById(R.id.tv_size);
        tvVideoName = (TextView) findViewById(R.id.tvVideoName);
        mMediaShareOPtionView = findViewById(R.id.view_media_share_option);
        llBtn = findViewById(R.id.llBtn);
        mMediaOptionView = findViewById(R.id.view_media_option);
        mSeekBar = (SeekBar) findViewById(R.id.sb_media_time);
        mPauseBtn = (ImageView) findViewById(R.id.btn_media_pause);
        mPlayBtn = (ImageView) findViewById(R.id.btn_media_play);
        mPlayBtn2 = (Button) findViewById(R.id.btnPlay);
        mStopBtn = (Button) findViewById(R.id.btnStop);
        mTimeTV = (TextView) findViewById(R.id.tv_media_time);
        ivPlay = findViewById(R.id.ivPaly);
        mPauseEndCB = (CheckBox) findViewById(R.id.cb_pase_end);
        mPlayLocalCB = (CheckBox) findViewById(R.id.cb_play_local);
        mSeekBar.setOnSeekBarChangeListener(mPosSeekBarChangeListener);

        mVolumeSeekBar = (SeekBar) findViewById(R.id.sb_media_volume);
        mVolumeSeekBar.setOnSeekBarChangeListener(mVolumeSeekBarChangeListener);

        CloudroomVideoMeeting.getInstance()
                .registerCallback(mCRMeetingCallback);

        // 显示视频需要启用hardwareAccelerated，某些设备会导致控件花屏，需要把不需要使用硬件加速的控件关闭硬件加速功能
        mSizeTV.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
        mMediaShareOPtionView.setLayerType(View.LAYER_TYPE_SOFTWARE, null);

        mMediaOptionView.setOnTouchListener(new OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                return true;
            }
        });
    }

    private boolean mTrackingTouch = false;

    private OnSeekBarChangeListener mPosSeekBarChangeListener = new OnSeekBarChangeListener() {

        @Override
        public void onStopTrackingTouch(SeekBar seekBar) {
            mTrackingTouch = false;
            int progress = seekBar.getProgress();
            CloudroomVideoMeeting.getInstance().setMediaPlayPos(progress);
        }

        @Override
        public void onStartTrackingTouch(SeekBar seekBar) {
            mTrackingTouch = true;
        }

        @Override
        public void onProgressChanged(SeekBar seekBar, int progress,
                                      boolean fromUser) {
        }
    };

    private OnSeekBarChangeListener mVolumeSeekBarChangeListener = new OnSeekBarChangeListener() {

        @Override
        public void onStopTrackingTouch(SeekBar seekBar) {
        }

        @Override
        public void onStartTrackingTouch(SeekBar seekBar) {
        }

        @Override
        public void onProgressChanged(SeekBar seekBar, int progress,
                                      boolean fromUser) {
            CloudroomVideoMeeting.getInstance().setMediaVolume(progress);
        }
    };

    @Override
    public boolean onViewClick(View v, int vID) {
        if (vID == R.id.btn_open_file) {
            openVideoFile();
            return true;
        } else if (vID == R.id.btn_open_url) {
//			showInputUrl();
            return true;
        } else if (vID == R.id.btn_media_pause) {
            CloudroomVideoMeeting.getInstance().pausePlayMedia(true);
            mPauseBtn.setVisibility(View.GONE);
            mPlayBtn.setVisibility(View.VISIBLE);
            return true;
        } else if (vID == R.id.btn_media_play) {
            CloudroomVideoMeeting.getInstance().pausePlayMedia(false);
            mPauseBtn.setVisibility(View.VISIBLE);
            mPlayBtn.setVisibility(View.GONE);
            return true;
        } else if (vID == R.id.btnPlay) {
            videoPlay(videoPath);
            return true;
        } else if (vID == R.id.btn_media_stop || vID == R.id.btnStop) {
            CloudroomVideoMeeting.getInstance().stopPlayMedia();
            return true;
        } else if (vID == R.id.btn_media_catch) {
            String pathFileName = String.format("%s/media_%s.jpg",
                    DemoApp.SDK_DATA_PATH, Tools.getCurrentTimeStr());
            mMediaUIView.savePicToFile(pathFileName, CompressFormat.JPEG);
            UITool.showPicDialog(getContext(), pathFileName);
            return true;
        } else if (vID == R.id.view_yuv_mediashare) {
            if (ivPlay.getVisibility() != View.VISIBLE &&
                    mMediaShareOPtionView.getVisibility() != View.VISIBLE && isMyShare) {
                CloudroomVideoMeeting.getInstance().pausePlayMedia(true);
            }
        } else if (vID == R.id.ivPaly) {
            if (isMyShare) {
                CloudroomVideoMeeting.getInstance().pausePlayMedia(false);
                ivPlay.setVisibility(View.GONE);
            }
        }
        return false;
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_GET_VIDEO) {
            if (resultCode == Activity.RESULT_OK) {
                String path = Tools.getPathFromUri(getContext(), data.getData());
                Log.i(TAG, "onActivityResult:" + data.getData() + " path:"
                        + path);
                if (!TextUtils.isEmpty(path)) {
                    tvVideoName.setText(path);
                    videoPath = path;
                } else {
                    Toast.makeText(getContext(), "获取视频失败", Toast.LENGTH_LONG).show();
                }
            }
            return true;
        }
        return false;
    }

    private void videoPlay(String path) {
        if (path == null || path.isEmpty()) {
            Toast.makeText(getContext(), "地址不能为空", Toast.LENGTH_LONG).show();
            return;
        }
        boolean pauseEnd = mPauseEndCB.isChecked();
        boolean playLocal = mPlayLocalCB.isChecked();
        isLocalMedia = true;
        CloudroomVideoMeeting.getInstance().startPlayMedia(path, false, pauseEnd);
    }

    private void updateVideoSize() {
        mMainHandler.sendEmptyMessageDelayed(UPDATE_VIDEO_SIZE, 1000);
        if (mSizeTV.getVisibility() != View.VISIBLE) {
            return;
        }
        int w = mMediaUIView.getPicWidth();
        int h = mMediaUIView.getPicHeight();
        mSizeTV.setText("" + w + "X" + h);
    }

    public static final int REQUEST_CODE_GET_VIDEO = 100;

    private void openVideoFile() {
        Tools.getFile((Activity) getContext(), "video/*", REQUEST_CODE_GET_VIDEO);

//		String filePath = DemoApp.SDK_DATA_PATH + "/test_media.mp4";
//		filePath = "/sdcard/1080P60fps_2.mp4";
//		boolean pauseEnd = mPauseEndCB.isChecked();
//		boolean playLocal = mPlayLocalCB.isChecked();
//		CloudroomVideoMeeting.getInstance().startPlayMedia(filePath, playLocal,
//				pauseEnd);
    }

	/*private void showInputUrl() {
		Activity activity = null;
		Context context = getContext();
		if (context instanceof Activity) {
			activity = (Activity) context;
		}
		if (activity == null) {
			return;
		}
		UITool.showInputDialog(activity, context.getString(R.string.input_url),
				"rtmp://58.200.131.2:1935/livetv/hunantv",
				new InputDialogCallback() {

					@Override
					public void onInput(String url) {
						CloudroomVideoMeeting.getInstance().startPlayMedia(url,
								false);
					}

					@Override
					public void onCancel() {

					}
				});
	}*/

    private int mTotalTime = 0;

    private CRMeetingCallback mCRMeetingCallback = new CRMeetingCallback() {

        @Override
        public void enterMeetingRslt(CRVIDEOSDK_ERR_DEF code) {
            if (code != CRVIDEOSDK_ERR_DEF.CRVIDEOSDK_NOERR) {
                return;
            }
        }

        @Override
        public void notifyMediaOpened(int totalTime, Size picSZ) {
            mTotalTime = totalTime;
            mSeekBar.setMax(totalTime);
            mVolumeSeekBar.setProgress(200);
            updateView();
            updateTime(0);
        }

        @Override
        public void notifyMediaPause(String userid, boolean bPause) {
            if (userid.equals(CloudroomVideoMeeting.getInstance().getMyUserID())){
                ivPlay.setImageResource(R.mipmap.play);
            }else {
                ivPlay.setImageResource(R.mipmap.pause);
            }
            if (bPause){
                ivPlay.setVisibility(View.VISIBLE);
            }else {
                ivPlay.setVisibility(View.GONE);
            }
        }

        @Override
        public void notifyMediaStart(String userid) {
            String myUserID = CloudroomVideoMeeting.getInstance().getMyUserID();
            /*mMediaOptionView
                    .setVisibility(userid.equals(myUserID) ? View.VISIBLE
                            : View.GONE);*/
            mMediaUIView.setVisibility(View.VISIBLE);
            isMyShare = myUserID.equals(userid);
            mMainHandler.sendEmptyMessageDelayed(UPDATE_VIDEO_SIZE, 1000);
            updateView();
            mPlayBtn2.setVisibility(View.GONE);
            mStopBtn.setVisibility(View.VISIBLE);
            if (!isLocalMedia) {
                llBtn.setVisibility(View.GONE);
                mMediaShareOPtionView.setVisibility(View.GONE);
            }
        }

        @Override
        public void notifyMediaStop(String userid, MEDIA_STOP_REASON reason) {
            mMediaUIView.setVisibility(View.GONE);
            mMainHandler.removeMessages(UPDATE_VIDEO_SIZE);
            updateView();
            mPlayBtn2.setVisibility(View.VISIBLE);
            mStopBtn.setVisibility(View.GONE);
            isLocalMedia = false;
            llBtn.setVisibility(View.VISIBLE);
            ivPlay.setVisibility(View.GONE);
            mMediaShareOPtionView.setVisibility(View.VISIBLE);
        }

        private int mLastTime = 0;

        @Override
        public void notifyMediaData(String userid, int curPos) {
            String myUserID = CloudroomVideoMeeting.getInstance().getMyUserID();
            if (!userid.equals(myUserID)) {
                return;
            }
            if (!(curPos - mLastTime >= 1000 || curPos >= mTotalTime)) {
                return;
            }
            updateTime(curPos);
        }

    };

    private void updateTime(int curPos) {
        if (!mTrackingTouch) {
            mSeekBar.setProgress(curPos);
        }
        int totalTimeSec = mTotalTime / 1000;
        mTimeTV.setVisibility(totalTimeSec < 1 ? View.INVISIBLE : View.VISIBLE);
        mSeekBar.setVisibility(totalTimeSec < 1 ? View.INVISIBLE : View.VISIBLE);
        int curSec = curPos / 1000;
        String text = String.format("%02d:%02d/%02d:%02d", curSec / 60,
                curSec % 60, totalTimeSec / 60, totalTimeSec % 60);
        mTimeTV.setText(text);
    }

    private void updateView() {
        MediaInfo info = CloudroomVideoMeeting.getInstance().getMediaInfo();
        boolean isMediaStarted = info != null
                && !TextUtils.isEmpty(info.mediaName);
        mMediaShareOPtionView.setVisibility(isMediaStarted ? View.GONE
                : View.VISIBLE);
        if (mTotalTime <= 0) {
            mPauseBtn.setVisibility(View.GONE);
            mPlayBtn.setVisibility(View.GONE);
        } else {
            boolean pause = info.state == MEDIA_STATE.MEDIA_PAUSE;
            mPauseBtn.setVisibility(pause ? View.GONE : View.VISIBLE);
            mPlayBtn.setVisibility(pause ? View.VISIBLE : View.GONE);
        }
        if (mPageCallback != null) {
            mPageCallback.uiContentChanged();
        }
    }

    @Override
    public void addMixerCotents(Size recSize, boolean bLocalMixer,
                                ArrayList<MixerCotent> contents) {
        MediaInfo info = CloudroomVideoMeeting.getInstance().getMediaInfo();
        boolean isMediaStarted = info != null
                && !TextUtils.isEmpty(info.mediaName);
        if (!isMediaStarted) {
            return;
        }
        MixerCotent content = MixerCotent.createMediaContent(new Rect(0, 0,
                recSize.width, recSize.height));
        content.bKeepAspectRatio = true;
        contents.add(content);
    }

}
