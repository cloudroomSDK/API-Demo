package com.meeting.example.common;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Toast;

import androidx.constraintlayout.widget.ConstraintLayout;

import com.cloudroom.cloudroomvideosdk.CRMeetingCallback;
import com.cloudroom.cloudroomvideosdk.CloudroomVideoMeeting;
import com.cloudroom.cloudroomvideosdk.CloudroomVideoSDK;
import com.cloudroom.cloudroomvideosdk.model.CRVIDEOSDK_ERR_DEF;
import com.cloudroom.cloudroomvideosdk.model.MIXER_OUTPUT_TYPE;
import com.cloudroom.cloudroomvideosdk.model.MIXER_STATE;
import com.cloudroom.cloudroomvideosdk.model.MixerCfg;
import com.cloudroom.cloudroomvideosdk.model.MixerCotent;
import com.cloudroom.cloudroomvideosdk.model.MixerOutPutCfg;
import com.cloudroom.cloudroomvideosdk.model.MixerOutputInfo;
import com.cloudroom.cloudroomvideosdk.model.Size;
import com.cloudroom.cloudroomvideosdk.model.UsrVideoId;
import com.cloudroom.tool.AndroidTool;
import com.example.meetingdemo.R;
import com.meeting.DemoApp;
import com.meeting.example.tool.CRLog;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

@SuppressLint({"SimpleDateFormat", "DefaultLocale", "NewApi"})
public class MixerView extends LinearLayout implements OnClickListener {

    private static final String TAG = "MixerView";
    private static final String KEY_MIXERID = "KEY_ANDROID_MIXERID";
    private Button mStartBtn = null;
    private Button mStopBtn = null;
    private Button mStartBtn2 = null;
    private Button mStopBtn2 = null;
    private EditText mEtName = null;
    private ConstraintLayout localLayout = null;
    private MixerCfg mMixerCfg = null;
    private int mMeetID = 0;
    private UsrVideoId mCurUsrVideoId = null;
    private boolean mBMixerFile = true;
    private boolean mBLocal = false;
    private boolean isRecordLocal = false;
    private boolean mMixering = false;
    private String mLocalName = "";
    private List<UsrVideoId> mUsrVideoIdList = new ArrayList<>();

    public MixerView(Context context) {
        super(context);
        init();
    }

    public MixerView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    @Override
    protected void finalize() throws Throwable {
        if (!CloudroomVideoSDK.getInstance().isInitSuccess()) {
            return;
        }
        CloudroomVideoMeeting.getInstance().unregisterCallback(
                mCRMeetingCallback);
    }

    private void init() {
        inflate(getContext(), R.layout.layout_mixer_view, this);
        mStartBtn = findViewById(R.id.btnStart);
        mStopBtn = findViewById(R.id.btnStop);
        mStartBtn2 = findViewById(R.id.btnStart2);
        mStopBtn2 = findViewById(R.id.btnStop2);
        localLayout = findViewById(R.id.localLayout);
        mEtName = findViewById(R.id.etName);
        mLocalName = getTimeStr();
        mEtName.setText(mLocalName);
        CloudroomVideoMeeting.getInstance().registerCallback(mCRMeetingCallback);
        // 显示视频需要启用hardwareAccelerated，某些设备会导致控件花屏，需要把不需要使用硬件加速的控件关闭硬件加速功能
        setLayerType(View.LAYER_TYPE_SOFTWARE, null);
    }

    private String getTimeStr() {
        SimpleDateFormat format = new SimpleDateFormat("yyyyMMddHHmmss");
        Date date = new Date(System.currentTimeMillis());
        return format.format(date);
    }

    @Override
    public void onClick(View v) {
        int vID = v.getId();
        if (vID == R.id.btnStart || vID == R.id.btnStart2) {
            startRecord(isRecordLocal);
        } else if (vID == R.id.btnStop || vID == R.id.btnStop2) {
            stopRecord();
        }
    }

    public void setRecordType(boolean local) {
        isRecordLocal = local;
        if (isRecordLocal) {
            localLayout.setVisibility(View.VISIBLE);
        } else {
            mStartBtn2.setVisibility(View.VISIBLE);
            updateSvrRecordState(CloudroomVideoMeeting.getInstance().getSvrMixerState(), "");
        }
    }

    public void setMeetID(int meetID) {
        this.mMeetID = meetID;
    }

    private void startRecord(boolean isLocalRecord) {
        String inputName = mEtName.getText().toString();
        if (isLocalRecord && inputName.isEmpty()) {
            Toast.makeText(getContext(), "请输入文件名称", Toast.LENGTH_SHORT).show();
            return;
        }
        if (inputName.equals(mLocalName)) {
            inputName = getTimeStr();
            mLocalName = inputName;
            mEtName.setText(inputName);
        }
        // 从设置获取录制参数，如分辨率、帧率等
        MixerCfg mixerCfg = new MixerCfg();
        mixerCfg.defaultQP = 28;
        mixerCfg.frameRate = 15;
        mixerCfg.bitRate = 350000;
        mixerCfg.dstResolution = new Size(640, 360);
        //
        // if (getResources().getConfiguration().orientation ==
        // Configuration.ORIENTATION_PORTRAIT) {
        // mixerCfg.dstResolution = new Size(mixerCfg.dstResolution.height,
        // mixerCfg.dstResolution.width);
        // }

        MixerOutPutCfg outputCfg = new MixerOutPutCfg();
        // 设置录制文件是否加密
        outputCfg.encryptType = 0;
        // 录制文件名称
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss");
        Date date = new Date(System.currentTimeMillis());
        if (mBMixerFile) {
            outputCfg.type = MIXER_OUTPUT_TYPE.MIXOT_FILE;
            String fileName = String.format("%s_Android_%d.mp4",
                    format.format(date), mMeetID);
            if (isLocalRecord) {
                fileName = inputName + ".mp4";
                outputCfg.fileName = String.format("%s/%s",
                        DemoApp.SDK_DATA_PATH, fileName);
            } else {
                String serverDir = fileName.substring(0, 10);
                outputCfg.fileName = String.format("/%s/%s",
                        serverDir, fileName);
                outputCfg.isUploadOnRecording = true;
                outputCfg.serverPathFileName = outputCfg.fileName;
            }
        } else {
            outputCfg.type = MIXER_OUTPUT_TYPE.MIXOT_LIVE;
            outputCfg.liveUrl = "rtmp://pub.cloudroom.com/live/5519_v81394349_1?bizid=5519&txSecret=963bd0fafe2c41e9e4f88041fc49e169&txTime=66D67200&record=mp4&record_interval=5400";
        }

        // 录制的图像内容
        ArrayList<MixerCotent> contents = getMixerContents(mixerCfg);

        ArrayList<MixerOutPutCfg> cfgs = new ArrayList<MixerOutPutCfg>();
        cfgs.add(outputCfg);

        if (isLocalRecord) {
            if (!startLocalRecord(mixerCfg, contents, cfgs)) {
                return;
            }
        } else {
            if (!startSvrRecord(mixerCfg, contents, cfgs)) {
                return;
            }
        }
        mMixerCfg = mixerCfg;
        // mMixerOutPutCfg = outputCfg;
        mMixering = true;
        mBLocal = isLocalRecord;
//		mMixerCfgView.setVisibility(View.INVISIBLE);
        if (isLocalRecord) {
            mStartBtn.setVisibility(View.INVISIBLE);
            mStopBtn.setVisibility(View.VISIBLE);
        } else {
            mStartBtn2.setVisibility(View.GONE);
            mStopBtn2.setVisibility(View.VISIBLE);
        }
    }

    private ArrayList<MixerCotent> getMixerContents(MixerCfg mixerCfg) {
        ArrayList<MixerCotent> contents = new ArrayList<MixerCotent>();
//        mContentCallback.addMixerCotents(mixerCfg.dstResolution, mBLocal, contents);
        Log.i(TAG, "getMixerContents 0 :" + contents.size());
        if (mCurUsrVideoId == null) {
            Toast.makeText(getContext(), "无摄像头信息", Toast.LENGTH_SHORT).show();
        }
        //参会者列表
        if (mCurUsrVideoId != null && mixerCfg != null) {
            contents.add(0, MixerCotent.createVideoContent(CloudroomVideoMeeting.getInstance().getMyUserID(),
                    mCurUsrVideoId.videoID, new Rect(0, 0, mixerCfg.dstResolution.width,
                            mixerCfg.dstResolution.height)));
        }
        int addHeight = (int) (mixerCfg.dstResolution.height * 0.3);
        int addWidth = (addHeight*9)/16;
        int desWidth = mixerCfg.dstResolution.width;
        int desHeight = mixerCfg.dstResolution.height;
        for (int i = 0; i < mUsrVideoIdList.size(); i++) {
            if (i <9) {
                int gap = 3;
                UsrVideoId user = mUsrVideoIdList.get(i);
                if (!user.userId.equals(CloudroomVideoMeeting.getInstance().getMyUserID())) {
                    Rect rect = null;
                    if (i < 3) {
                        int top = gap * (i + 1) + addHeight * i;
                        rect = new Rect(desWidth - gap - addWidth,
                                top,
                                desWidth - gap,
                                desHeight - top-addHeight*(3-i-1));
                    } else if (i < 6) {
                        int top = gap * (i - 3 + 1) + addHeight * (i - 3);
                        rect = new Rect(desWidth - gap * 2 - addWidth * 2,
                                top,
                                desWidth - gap - addWidth,
                                desHeight - top-addHeight*(6-i-1));
                    }else {
                        int top = gap * (i - 6 + 1) + addHeight * (i - 6);
                        rect = new Rect(desWidth - gap * 2 - addWidth * 2,
                                top,
                                desWidth - gap - addWidth,
                                desHeight - top-addHeight*(9-i-1));
                    }
                    contents.add(MixerCotent.createVideoContent(user.userId, user.videoID, rect));
                }
            }
        }
        // 添加录制时间戳
        int timeHeight = (mixerCfg.dstResolution.width > mixerCfg.dstResolution.height ? mixerCfg.dstResolution.height
                : mixerCfg.dstResolution.width) / 10;
        int timeWidth = timeHeight * 10;
        contents.add(MixerCotent.createTimeStampContent(new Rect(6, 6, timeWidth,
                timeHeight)));
        contents.add(MixerCotent.createTextContent("测试文字", new Rect(0, 0,
                AndroidTool.px2dip(getContext(), 360),
                AndroidTool.px2dip(getContext(), 100))));
        Log.i(TAG, "getMixerContents 1 :" + contents.size());
        return contents;
    }

    private boolean startLocalRecord(MixerCfg mixerCfg,
                                     ArrayList<MixerCotent> contents, ArrayList<MixerOutPutCfg> cfgs) {
        // 开始录制
        if (CloudroomVideoMeeting.getInstance().createLocMixer(KEY_MIXERID,
                mixerCfg, contents) != CRVIDEOSDK_ERR_DEF.CRVIDEOSDK_NOERR) {
            CRLog.debug(TAG, "createLocMixer fail");
            return false;
        }
        if (CloudroomVideoMeeting.getInstance().addLocMixerOutput(KEY_MIXERID,
                cfgs) != CRVIDEOSDK_ERR_DEF.CRVIDEOSDK_NOERR) {
            CRLog.debug(TAG, "addLocMixerOutput fail");
            return false;
        }
        return true;
    }

    private boolean startSvrRecord(MixerCfg mixerCfg,
                                   ArrayList<MixerCotent> contents,
                                   ArrayList<MixerOutPutCfg> outputCfgs) {

        HashMap<String, MixerCfg> mixerCfgs = new HashMap<String, MixerCfg>();
        mixerCfgs.put(KEY_MIXERID, mixerCfg);

        HashMap<String, ArrayList<MixerOutPutCfg>> mixerOutputCfgs = new HashMap<String, ArrayList<MixerOutPutCfg>>();
        mixerOutputCfgs.put(KEY_MIXERID, outputCfgs);

        HashMap<String, ArrayList<MixerCotent>> mixerContents = new HashMap<String, ArrayList<MixerCotent>>();
        mixerContents.put(KEY_MIXERID, contents);

        CRVIDEOSDK_ERR_DEF errCode = CloudroomVideoMeeting.getInstance()
                .startSvrMixer(mixerCfgs, mixerContents, mixerOutputCfgs);
        if (errCode != CRVIDEOSDK_ERR_DEF.CRVIDEOSDK_NOERR) {
            CRLog.debug(TAG, "startSvrMixer fail, errCode:" + errCode);
            String err = errCode.toString();
            Toast.makeText(getContext(), getContext().getResources().getIdentifier(err,
                    "string", getContext().getPackageName()), Toast.LENGTH_SHORT).show();
            return false;
        }
        return true;

      /*  //单流录制接口测试
        try {
            String myUserID = CloudroomVideoMeeting.getInstance().getMyUserID();
//                JSONArray mutiCfg = new JSONArray();
//
//                JSONObject mp4Obj = new JSONObject();
//                mp4Obj.put("id", "mp4");
//                mp4Obj.put("streamTypes", 3);
//                JSONObject cfg = new JSONObject();
//                cfg.put("width", 1280);
//                cfg.put("height", 720);
//                cfg.put("frameRate", 15);
//                cfg.put("bitRate", 2000*1000);
//                cfg.put("defaultQP", 18);
//                mp4Obj.put("cfg", cfg);
//                mutiCfg.put(mp4Obj);
//
//                JSONObject wav1Obj = new JSONObject();
//                wav1Obj.put("id", "wav1");
//                wav1Obj.put("streamTypes", 1);
//                JSONObject acfg1 = new JSONObject();
//                acfg1.put("channelType", 0);
//                acfg1.put("audioFormat", 2);
//                wav1Obj.put("acfg", acfg1);
//                mutiCfg.put(wav1Obj);
//
//                JSONObject wav2Obj = new JSONObject();
//                wav2Obj.put("id", "mp4");
//                wav2Obj.put("streamTypes", 3);
//                JSONObject acfg2 = new JSONObject();
//                acfg2.put("channelType", 0);
//                acfg2.put("audioFormat", 2);
//                wav2Obj.put("acfg", acfg2);
//                mutiCfg.put(wav2Obj);

            String mutiCfg = "[\n" +
                    "    {\n" +
                    "        \"id\": \"mp4\",\n" +
                    "        \"streamTypes\": 3,\n" +
                    "        \"cfg\": {\n" +
                    "            \"width\": 1280,\n" +
                    "            \"height\": 720,\n" +
                    "            \"frameRate\": 15,\n" +
                    "            \"bitRate\": 2000000,\n" +
                    "            \"defaultQP\": 18\n" +
                    "        }\n" +
                    "    },\n" +
                    "    {\n" +
                    "        \"id\": \"wav1\",\n" +
                    "        \"streamTypes\": 1,\n" +
                    "        \"acfg\": {\n" +
                    "            \"channelType\": 0,\n" +
                    "            \"audioFormat\": 2\n" +
                    "        }\n" +
                    "    }\n" +
                    "]";

            String mutiContent = String.format("[\n" +
                    "                        {\n" +
                    "                                \"id\": \"mp4\",\n" +
                    "                        \"content\": [\n" +
                    "                {\n" +
                    "                    \"type\": 0,\n" +
                    "                        \"left\": 0,\n" +
                    "                        \"top\": 0,\n" +
                    "                        \"width\": 1280,\n" +
                    "                        \"height\": 720,\n" +
                    "                        \"param\": {\n" +
                    "                    \"camid\": \"%s.-1\"\n" +
                    "                },\n" +
                    "                    \"keepAspectRatio\": 1\n" +
                    "                }\n" +
                    "        ]\n" +
                    "    },\n" +
                    "                {\n" +
                    "                    \"id\": \"wav1\",\n" +
                    "                        \"content\": [\n" +
                    "                    {\n" +
                    "                        \"type\": 9,\n" +
                    "                            \"param\": {\n" +
                    "                        \"uid\": \"%s\"\n" +
                    "                    }\n" +
                    "                    }\n" +
                    "        ]\n" +
                    "                }\n" +
                    "]", myUserID, myUserID);


            String mutiOutputs = String.format("[\n" +
                    "                        {\n" +
                    "                                \"id\": \"mp4\",\n" +
                    "                        \"output\": [\n" +
                    "                {\n" +
                    "                    \"type\": 0,\n" +
                    "                        \"filename\": \"/2022-01-05/%s_%d_mp4.mp4\"\n" +
                    "                }\n" +
                    "        ]\n" +
                    "    },\n" +
                    "                {\n" +
                    "                    \"id\": \"wav1\",\n" +
                    "                        \"output\": [\n" +
                    "                    {\n" +
                    "                        \"type\": 0,\n" +
                    "                            \"filename\": \"/2022-01-05/%s_%d_wav1.wav\"\n" +
                    "                    }\n" +
                    "        ]\n" +
                    "                }\n" +
                    "]", myUserID, System.currentTimeMillis(), myUserID, System.currentTimeMillis());

            CloudroomVideoMeeting.getInstance().startSvrMixer(mutiCfg, mutiContent, mutiOutputs);
        } catch (Exception e) {
            return false;
        }
        return true;*/
    }

    public void updateMixerContents(UsrVideoId usrVideoId, List<UsrVideoId> usrVideoIdList) {
        mCurUsrVideoId = usrVideoId;
        mUsrVideoIdList.clear();
        mUsrVideoIdList.addAll(usrVideoIdList);
        if (!mMixering) {
            return;
        }
        // 录制的图像内容
        ArrayList<MixerCotent> contents = getMixerContents(mMixerCfg);
        if (mBLocal) {
            CloudroomVideoMeeting.getInstance().updateLocMixerContent(
                    KEY_MIXERID, contents);
        } else {
            HashMap<String, ArrayList<MixerCotent>> mixerContents = new HashMap<String, ArrayList<MixerCotent>>();
            mixerContents.put(KEY_MIXERID, contents);
            CloudroomVideoMeeting.getInstance().updateSvrMixerContent(
                    mixerContents);
        }
    }

    public void stopRecord() {
        if (mBLocal) {
            CloudroomVideoMeeting.getInstance().destroyLocMixer(KEY_MIXERID);
        } else {
            CloudroomVideoMeeting.getInstance().stopSvrMixer();
        }
        mMixering = false;
        if (isRecordLocal) {
            mStartBtn.setVisibility(View.VISIBLE);
            mStopBtn.setVisibility(View.GONE);
        } else {
            mStartBtn2.setVisibility(View.VISIBLE);
            mStopBtn2.setVisibility(View.GONE);
        }
    }

    private CRMeetingCallback mCRMeetingCallback = new CRMeetingCallback() {

        @Override
        public void locMixerOutputInfo(String mixerID, String nameOrUrl,
                                       MixerOutputInfo info) {
            Log.i(TAG, "locMixerOutputInfo mixerID:" + mixerID + " nameOrUrl:"
                    + nameOrUrl + " info:" + info);
//            Toast.makeText(getContext(), "locMixerOutputInfo mixerID:" + mixerID + " nameOrUrl:"
//                    + nameOrUrl + " info:" + info, Toast.LENGTH_SHORT).show();
        }

        @Override
        public void startSvrMixerFailed(CRVIDEOSDK_ERR_DEF err) {
            Log.i(TAG, "startSvrMixerFailed:" + err);
//            Toast.makeText(getContext(), "startSvrMixerFailed:" + err, Toast.LENGTH_SHORT).show();
        }

        @Override
        public void locMixerStateChanged(String mixerID, MIXER_STATE state) {
            Log.i(TAG, "locMixerStateChanged mixerID:" + mixerID + " state:"
                    + state);
//            Toast.makeText(getContext(), "locMixerStateChanged mixerID:" + mixerID + " state:"
//                    + state, Toast.LENGTH_SHORT).show();
        }

        @Override
        public void svrMixerCfgChanged() {
            Log.i(TAG, "svrMixerCfgChanged");
//            Toast.makeText(getContext(), "svrMixerCfgChanged", Toast.LENGTH_SHORT).show();
        }

        @Override
        public void svrMixerOutputInfo(MixerOutputInfo info) {
            Log.i(TAG, "svrMixerOutputInfo info:" + info);
//            Toast.makeText(getContext(), "svrMixerOutputInfo info:" + info, Toast.LENGTH_SHORT).show();
        }

        @Override
        public void svrMixerStateChanged(String operatorID, MIXER_STATE state,
                                         CRVIDEOSDK_ERR_DEF err) {
            Log.i(TAG, "svrMixerStateChanged operatorID:" + operatorID
                    + " state:" + state + " err:" + err);
            updateSvrRecordState(state, operatorID);
//            Toast.makeText(getContext(), "svrMixerStateChanged operatorID:" + operatorID
//                    + " state:" + state + " err:" + err, Toast.LENGTH_SHORT).show();
        }

    };

    private void updateSvrRecordState(MIXER_STATE state, String id) {
        if (state == MIXER_STATE.MIXER_NULL || state == MIXER_STATE.MIXER_STOPPING ||
                id.equals(CloudroomVideoMeeting.getInstance().getMyUserID())) {
            mStartBtn2.setClickable(true);
            mStartBtn2.setBackground(getResources().getDrawable(R.drawable.shape_corner_blue));
        } else {
            mStartBtn2.setClickable(false);
            mStartBtn2.setBackground(getResources().getDrawable(R.drawable.shape_corner));
        }
    }

}
