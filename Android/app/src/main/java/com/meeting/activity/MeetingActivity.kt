package com.meeting.activity

import android.app.Dialog
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color
import android.os.Bundle
import android.os.CountDownTimer
import android.text.TextUtils
import android.util.Log
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.SeekBar
import android.widget.TextView
import android.widget.Toast
import androidx.recyclerview.widget.LinearLayoutManager
import com.cloudroom.cloudroomvideosdk.CRMeetingCallback
import com.cloudroom.cloudroomvideosdk.CRMgrCallback
import com.cloudroom.cloudroomvideosdk.CloudroomVideoMeeting
import com.cloudroom.cloudroomvideosdk.CloudroomVideoMgr
import com.cloudroom.cloudroomvideosdk.model.*
import com.example.meetingdemo.R
import com.google.gson.Gson
import com.meeting.adapter.IMAdapter
import com.meeting.adapter.MemberVideoAdapter
import com.meeting.example.common.VideoSDKHelper
import com.meeting.example.tool.SPUtils
import com.meeting.example.tool.UITool
import kotlinx.android.synthetic.main.activity_meeting.*
import kotlinx.android.synthetic.main.title_bar.*
import java.util.*

/**
 * Created by zjw on 2021/12/10.
 */
class MeetingActivity : BaseActivity(), View.OnClickListener {

    companion object {
        private const val TAG = "MeetingActivity"
        var mMeetID = 0
        var mMeetPswd = ""
        var mBCreateMeeting = false
        var mRoomType = 1
    }

    private var enterSuccess = false
    private val mImAdapter by lazy { IMAdapter(this) }
    private var mHeadsetReceiver: HeadsetReceiver? = null
    private var mMeetInfo: MeetInfo? = null
    private var btnScreenShareMic: Button? = null
    private var dropDialog: Dialog? = null
    private var resoulationList = arrayListOf<TextView>()
    private val memberVideoAdapter by lazy { MemberVideoAdapter(this) }
    private val memberVideoAdapter2 by lazy { MemberVideoAdapter(this) }
    private val memberVideoAdapter3 by lazy { MemberVideoAdapter(this) }
    private var progressTimer: CountDownTimer? = null
    private var remoteUserId = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (mMeetID <= 0 && !mBCreateMeeting) {
            finish()
            return
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        setContentView(R.layout.activity_meeting)
        btnScreenShareMic = screenShareView.findViewById(R.id.btnCloseMic)
        CloudroomVideoMeeting.getInstance().registerCallback(mMeetingCallback)
        CloudroomVideoMgr.getInstance().registerCallback(mMgrCallback)
        if (mBCreateMeeting) {
            createMeeting()
        } else {
            enterMeeting(mMeetID)
        }
    }

    private fun initView() {
        if (mRoomType == MainActivity.ROOM_AUDIO || mRoomType == MainActivity.ROOM_AUDIO_SETTING) {
            bgAudio.visibility = View.VISIBLE
            if (mRoomType == MainActivity.ROOM_AUDIO) {
                groupMic.visibility = View.VISIBLE
                tvLocalUser.text = CloudroomVideoMeeting.getInstance()
                    .getNickName(CloudroomVideoMeeting.getInstance().myUserID)
            }
            if (mRoomType == MainActivity.ROOM_AUDIO_SETTING) {
                groupMicCollect.visibility = View.VISIBLE
                sbVoice.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
                    override fun onProgressChanged(p0: SeekBar?, p1: Int, p2: Boolean) {
                        tvVoiceValue.text = p1.toString()
                        CloudroomVideoMeeting.getInstance().micVolume = p1
                    }

                    override fun onStartTrackingTouch(p0: SeekBar?) {
                    }

                    override fun onStopTrackingTouch(p0: SeekBar?) {
                    }

                })
            }
        }
        if (mRoomType == MainActivity.ROOM_VIDEO_SETTING) {
            groupVideoSetting.visibility = View.VISIBLE
            resoulationList.add(tv360)
            resoulationList.add(tv480)
            resoulationList.add(tv720)
            resoulationList.add(tv1080)
            refreshVideoSetting()
            sbRate.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
                override fun onProgressChanged(p0: SeekBar?, p1: Int, p2: Boolean) {
                    val cfg = CloudroomVideoMeeting.getInstance().videoCfg
                    cfg.maxbps = p1
                    tvRateValue.text = "${p1}kbps"
                    CloudroomVideoMeeting.getInstance().videoCfg = cfg
                }

                override fun onStartTrackingTouch(p0: SeekBar?) {
                }

                override fun onStopTrackingTouch(p0: SeekBar?) {
                }

            })
            sbFrame.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
                override fun onProgressChanged(p0: SeekBar?, p1: Int, p2: Boolean) {
                    val cfg = CloudroomVideoMeeting.getInstance()
                        .videoCfg
                    cfg.fps = p1
                    tvFrameValue.text = "${p1}fps"
//                    cfg.maxbps = -1
                    CloudroomVideoMeeting.getInstance().videoCfg = cfg
                }

                override fun onStartTrackingTouch(p0: SeekBar?) {
                }

                override fun onStopTrackingTouch(p0: SeekBar?) {
                }

            })
        }
        rvMember.adapter = memberVideoAdapter
        rvMember.layoutManager = LinearLayoutManager(this)
        rvMember2.adapter = memberVideoAdapter2
        rvMember2.layoutManager = LinearLayoutManager(this)
        rvMember3.adapter = memberVideoAdapter3
        rvMember3.layoutManager = LinearLayoutManager(this)
        if (mRoomType == MainActivity.ROOM_VIDEO) {
            groupCamBtn.visibility = View.VISIBLE
        }
        if (mRoomType == MainActivity.ROOM_IM) {
            groupIM.visibility = View.VISIBLE
            rvIm.layoutManager = LinearLayoutManager(this)
            rvIm.adapter = mImAdapter
            updateIMMsg()
        }
        val userId = CloudroomVideoMeeting.getInstance().myUserID
        if (mRoomType == MainActivity.ROOM_RECORD_LOCAL) {
            recordLayout.visibility = View.VISIBLE
            recordLayout.setRecordType(true)
            CloudroomVideoMeeting.getInstance().openMic(userId)
        }
        if (mRoomType == MainActivity.ROOM_RECORD_CLOUD) {
            recordLayout.visibility = View.VISIBLE
            recordLayout.setRecordType(false)
            CloudroomVideoMeeting.getInstance().openMic(userId)
        }
        if (mRoomType == MainActivity.ROOM_video_play) {
            mediaShareView.visibility = View.VISIBLE
        }
        setCamState()
        setMicState(true)
        setSpeakerState()
    }

    private fun refreshVideoSetting() {
        val videoCfg = CloudroomVideoMeeting.getInstance().videoCfg
        sbRate.max = videoCfg.maxbps / 1000
        sbRate.progress = videoCfg.maxbps / 1000
        tvRateValue.text = "${sbRate.progress}kbps"
        sbFrame.progress = videoCfg.fps
        tvFrameValue.text = "${sbFrame.progress}fps"
    }

    override fun onClick(p0: View) {
        when (p0.id) {
            R.id.btnMicStop, R.id.btnMicExit, R.id.btnVideoSettingExit, R.id.ivBack -> exitMeeting()
            R.id.btnMic, R.id.btnMic2, R.id.btnCloseMic -> setMicState()
            R.id.btnSpeaker, R.id.btnSpeaker2 -> {
                CloudroomVideoMeeting.getInstance()
                    .speakerOut = !CloudroomVideoMeeting.getInstance().speakerOut
                setSpeakerState()
            }
            R.id.btnCam -> switchCamera()
            R.id.btnCamOpen -> clickCamOptnBtn()
            R.id.tv360 -> setVideoResolution(360)
            R.id.tv480 -> setVideoResolution(480)
            R.id.tv720 -> setVideoResolution(720)
            R.id.tv1080 -> setVideoResolution(1080)
            R.id.btnSend -> sendMsg()
        }
        if (screenShareView.visibility == View.VISIBLE) {
            screenShareView.onViewClick(p0, p0.id)
        }
        if (recordLayout.visibility == View.VISIBLE) {
            recordLayout.onClick(p0)
        }
        if (mediaShareView.visibility == View.VISIBLE) {
            mediaShareView.onViewClick(p0, p0.id)
        }
    }

    private fun clickCamOptnBtn(open: Boolean = false) {
        val userId = CloudroomVideoMeeting.getInstance().myUserID
        val status = CloudroomVideoMeeting.getInstance()
            .getVideoStatus(userId)
        if (status == VSTATUS.VOPEN || status == VSTATUS.VOPENING) {
            if (!open) {
                CloudroomVideoMeeting.getInstance().closeVideo(userId)
            }
        } else {
            CloudroomVideoMeeting.getInstance().openVideo(userId)
        }
    }

    private fun setMicState(refresh: Boolean = false) {
        val userId = CloudroomVideoMeeting.getInstance().myUserID
        val status = CloudroomVideoMeeting.getInstance()
            .getAudioStatus(userId)
        if (status == ASTATUS.AOPEN || status == ASTATUS.AOPENING) {
            if (refresh) {
                btnMic.text = "关闭麦克风"
                btnMic2.text = "关闭麦克风"
                btnScreenShareMic?.text = "关闭麦克风"
            } else {
                btnMic.text = "打开麦克风"
                btnMic2.text = "打开麦克风"
                btnScreenShareMic?.text = "打开麦克风"
                CloudroomVideoMeeting.getInstance().closeMic(userId)
            }
        } else {
            if (refresh) {
                btnMic.text = "打开麦克风"
                btnMic2.text = "打开麦克风"
                btnScreenShareMic?.text = "打开麦克风"
            } else {
                btnMic.text = "关闭麦克风"
                btnMic2.text = "关闭麦克风"
                btnScreenShareMic?.text = "关闭麦克风"
                CloudroomVideoMeeting.getInstance().openMic(userId)
            }
        }
    }

    private fun setSpeakerState() {
        if (CloudroomVideoMeeting.getInstance().speakerOut) {
            btnSpeaker.text = "切换为听筒"
            btnSpeaker2.text = "切换为听筒"
        } else {
            btnSpeaker.text = "切换为扬声器"
            btnSpeaker2.text = "切换为扬声器"
        }
    }

    // 创建会议
    private fun createMeeting() {
        // 创建会议
        CloudroomVideoMgr.getInstance().createMeeting("Android Meeting", false, TAG)
    }

    // 进入会议
    private fun enterMeeting(meetID: Int) {
        // 进入会议
        VideoSDKHelper.getInstance().enterMeeting(meetID)
        tvTitle.text = getString(R.string.meet_prompt, meetID)
        if (mRoomType == MainActivity.ROOM_RECORD_CLOUD || mRoomType == MainActivity.ROOM_RECORD_LOCAL) {
            recordLayout.setMeetID(meetID)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (mediaShareView.visibility == View.VISIBLE) {
            mediaShareView.onActivityResult(requestCode, resultCode, data)
        }
    }

    private fun setVideoResolution(value: Int) {
        resoulationList.forEach {
            if (it.text.toString() == "${value}P") {
                it.setBackgroundResource(R.drawable.bg_line_blue)
                it.setTextColor(Color.parseColor("#3981FC"))
            } else {
                it.setBackgroundResource(R.drawable.bg_line)
                it.setTextColor(Color.parseColor("#ffffff"))
            }
        }
        videoMy.post {
            val cfg = CloudroomVideoMeeting.getInstance().videoCfg
            cfg.size = when (value) {
                480 -> Size(848, 480)
                720 -> Size(1280, 720)
                1080 -> Size(1920, 1080)
                else -> Size(640, 360)
            }
            cfg.maxbps = -1
            CloudroomVideoMeeting.getInstance().videoCfg = cfg
            refreshVideoSetting()
        }
    }

    // 发送聊天消息
    private fun sendMsg() {
        // 获取输入框内容
        val text: String = etInput.editableText.toString()
        // 检查内容是否为空
        if (TextUtils.isEmpty(text)) {
            VideoSDKHelper.getInstance().showToast(R.string.send_null)
            return
        }
        val map = HashMap<String, String>()
        map["CmdType"] = "IM"
        map["IMMsg"] = text
        val gson = Gson()
        val jsonStr = gson.toJson(map)
        // 发送聊天消息
        CloudroomVideoMeeting.getInstance().sendMeetingCustomMsg(jsonStr, jsonStr)
        // 清空输入框
        etInput.setText("")
    }

    private fun updateIMMsg() {
        mImAdapter.setData(VideoSDKHelper.getInstance().iMmsgList)
        rvIm.scrollToPosition(VideoSDKHelper.getInstance().iMmsgList.size - 1)
    }

    private val mMgrCallback: CRMgrCallback = object : CRMgrCallback() {
        override fun createMeetingFail(sdkErr: CRVIDEOSDK_ERR_DEF, cookie: String) {
            // 创建会议失败，提示并退出界面
            VideoSDKHelper.getInstance().showToast(R.string.create_meet_fail, sdkErr)
            UITool.hideProcessDialog(this@MeetingActivity)
            loginErrCheck(sdkErr)
            finish()
        }

        override fun createMeetingSuccess(meetInfo: MeetInfo, cookie: String) {
            mMeetInfo = meetInfo
            // 创建会议成功直接进入会议
            enterMeeting(meetInfo.ID)
        }

        override fun lineOff(sdkErr: CRVIDEOSDK_ERR_DEF?) {
            Toast.makeText(this@MeetingActivity, "您已掉线，请重新登录", Toast.LENGTH_SHORT).show()
            exitMeeting()
        }
    }

    private fun loginErrCheck(err: CRVIDEOSDK_ERR_DEF) {
        if (err == CRVIDEOSDK_ERR_DEF.CRVIDEOSDK_NOT_LOGIN) {
            VideoSDKHelper.getInstance().logout()
        }
    }

    private val mMeetingCallback: CRMeetingCallback = object : CRMeetingCallback() {
        /**
         * 进入会议结果
         *
         * @param code
         * 结果
         */
        override fun enterMeetingRslt(code: CRVIDEOSDK_ERR_DEF) {
            UITool.hideProcessDialog(this@MeetingActivity)
            progressTimer?.cancel()
            progressTimer == null
            loginErrCheck(code)
            if (dropDialog?.isShowing == true) {
                dropDialog?.dismiss()
            }
            if (code != CRVIDEOSDK_ERR_DEF.CRVIDEOSDK_NOERR) {
                VideoSDKHelper.getInstance().showToast(
                    R.string.enter_fail,
                    code
                )
                exitMeeting()
                return
            }
            enterSuccess = true
            val lastMeetId = if (mMeetID > 0) {
                mMeetID
            } else {
                mMeetInfo?.ID ?: 0
            }
            SPUtils.setPreference(
                this@MeetingActivity,
                SPUtils.DATA_NAME,
                SPUtils.LAST_MEET_ID,
                lastMeetId
            )
            SPUtils.setPreference(
                this@MeetingActivity, SPUtils.DATA_NAME, SPUtils.ROOM_TYPE,
                mRoomType
            )
            enterMeetingSuccess()
            initView()
            watchHeadset()
            VideoSDKHelper.getInstance().showToast(R.string.enter_success)
            // 更新观看视频
            updateWatchVideos()
        }

        override fun micEnergyUpdate(
            userID: String?,
            oldLevel: Int,
            newLevel: Int
        ) {
            val myId = CloudroomVideoMeeting.getInstance().myUserID
            if (userID == myId) {
                progressLocal.progress = newLevel
            } else {
                if (!userID.isNullOrEmpty()) {
                    remoteUserId = userID
                    tvRemoteUser.text = CloudroomVideoMeeting.getInstance().getNickName(userID)
                    progressRemote.progress = newLevel
                }
            }
        }

        override fun meetingDropped() {
            enterSuccess = false
            VideoSDKHelper.getInstance().showToast(R.string.meet_dropped)
            if (dropDialog?.isShowing != true) {
                dropDialog = UITool.showConfirmDialog(this@MeetingActivity, "系统掉线，重新进入？",
                    object : UITool.ConfirmDialogCallback {
                        override fun onOk() {
                            if (enterSuccess) {
                                return
                            }
                            enterMeeting(mMeetID)
                            UITool.showProcessDialog(
                                this@MeetingActivity,
                                getString(R.string.entering)
                            )
                            progressTimer = object : CountDownTimer(10 * 1000, 1000) {
                                override fun onFinish() {
                                    VideoSDKHelper.getInstance().showToast("您已掉线，请重新登录")
                                    exitMeeting()
                                }

                                override fun onTick(p0: Long) {
                                }

                            }
                            progressTimer?.start()
                        }

                        override fun onCancel() {
                            exitMeeting()
                        }
                    })
            }
        }

        override fun meetingStopped() {
            VideoSDKHelper.getInstance().showToast(R.string.meet_stopped)
            exitMeeting()
        }

        override fun notifyIMmsg(fromUserID: String?, text: String?, sendTime: Int) {
            updateIMMsg()
        }

        override fun notifyMeetingCustomMsg(
            fromUserID: String,
            text: String
        ) {
            val gson = Gson()
            val map: Map<String, String> = gson.fromJson<Map<String, String>>(text, Map::class.java)
            if (map.containsKey("CmdType")) {
                if ("IM" != map["CmdType"]) {
                    return
                }
            } else {
                return
            }
            updateIMMsg()
        }

        override fun sendMeetingCustomMsgRslt(
            sdkErr: CRVIDEOSDK_ERR_DEF,
            cookie: String?
        ) {
            if (sdkErr != CRVIDEOSDK_ERR_DEF.CRVIDEOSDK_NOERR) {
                Log.d(TAG, "sendIMmsg fail, sdkErr:$sdkErr")
                return
            }
            Log.d(TAG, "sendIMmsg success")
        }

        override fun defVideoChanged(userID: String, videoID: Short) {
            // 更新观看视频
            updateWatchVideos()
        }

        override fun notifyVideoWallMode(wallMode: VIDEO_WALL_MODE) {
        }

        override fun userEnterMeeting(userID: String) {
            // 更新观看视频
            updateWatchVideos()
        }

        override fun userLeftMeeting(userID: String) {
            // 更新观看视频
            updateWatchVideos()
            if (remoteUserId == userID){
                tvRemoteUser.text = "远端用户"
            }
        }

        override fun videoDevChanged(userID: String) {
            // 更新观看视频
            updateWatchVideos()
        }

        override fun videoStatusChanged(
            userID: String, oldStatus: VSTATUS,
            newStatus: VSTATUS
        ) {
            // 更新观看视频
            updateWatchVideos()
            setCamState()
        }

        override fun audioStatusChanged(userID: String?, oldStatus: ASTATUS?, newStatus: ASTATUS?) {
            setMicState(true)
        }
    }

    private fun updateWatchVideos() {
        if (mRoomType == MainActivity.ROOM_VIDEO ||
            mRoomType == MainActivity.ROOM_VIDEO_SETTING ||
            mRoomType == MainActivity.ROOM_RECORD_LOCAL ||
            mRoomType == MainActivity.ROOM_RECORD_CLOUD
        ) {
            // 更新观看视频
            val watchableVideos = CloudroomVideoMeeting
                .getInstance().watchableVideos
            val memberVideoList = arrayListOf<UsrVideoId>()
            var hasMyVideo = false
            for (usrVideoId in watchableVideos) {
                if (usrVideoId.userId == CloudroomVideoMeeting.getInstance().myUserID) {
                    hasMyVideo = true
                    videoMy.visibility = View.VISIBLE
                    videoMy.usrVideoId = usrVideoId
                } else {
                    memberVideoList.add(usrVideoId)
                }
            }
            if (!hasMyVideo) {
                videoMy.visibility = View.GONE
            } else {
                setVideoResolution(360)
            }
            if (memberVideoList.size > 0) {
                rvMember.visibility = View.VISIBLE
                val list1 = arrayListOf<UsrVideoId>()
                val list2 = arrayListOf<UsrVideoId>()
                val list3 = arrayListOf<UsrVideoId>()
                memberVideoList.forEachIndexed { index, usrVideoId ->
                    if (index > 8) {
                        return@forEachIndexed
                    } else {
                        when {
                            index < 3 -> {
                                list1.add(usrVideoId)
                            }
                            index < 6 -> {
                                list2.add(usrVideoId)
                            }
                            else -> {
                                list3.add(usrVideoId)
                            }
                        }
                    }
                }
                if (list2.size > 0) {
                    rvMember2.visibility = View.VISIBLE
                    memberVideoAdapter2.setData(list2)
                } else {
                    rvMember2.visibility = View.GONE
                }
                if (list3.size > 0) {
                    rvMember3.visibility = View.VISIBLE
                    memberVideoAdapter3.setData(list3)
                } else {
                    rvMember3.visibility = View.GONE
                }
                memberVideoAdapter.setData(list1)
            } else {
                rvMember.visibility = View.GONE
                rvMember2.visibility = View.GONE
                rvMember3.visibility = View.GONE
            }
            if (mRoomType == MainActivity.ROOM_RECORD_LOCAL ||
                mRoomType == MainActivity.ROOM_RECORD_CLOUD
            ) {
                recordLayout.updateMixerContents(videoMy.usrVideoId, watchableVideos)
            }
        }
    }

    // 成功进入会议
    private fun enterMeetingSuccess() {
        // 设置默认值
        val videoCfg = VideoCfg()
        videoCfg.fps = 15
        videoCfg.maxbps = 350000
        videoCfg.minQuality = 22
        videoCfg.maxQuality = 25
        videoCfg.size = Size(640, 360)
        CloudroomVideoMeeting.getInstance().videoCfg = videoCfg
        val myUserID = CloudroomVideoMeeting.getInstance().myUserID
        // 默认使用前置摄像头
        val myVideos = CloudroomVideoMeeting.getInstance()
            .getAllVideoInfo(myUserID)
        for (vInfo in myVideos) {
            if (vInfo.videoName.contains("FRONT")) {
                setCamState(true)
                CloudroomVideoMeeting.getInstance().setDefaultVideo(
                    myUserID,
                    vInfo.videoID
                )
                break
            }
        }
        // // 多档视频实现, 出多档质量的视频流，将带来很大的cpu开销
        // short defaultVideoID = CloudroomVideoMeeting.getInstance()
        // .getDefaultVideo(myUserID);
        // VideoAttributes attr = new VideoAttributes();
        // // 配置第二档视频
        // VideoCfg cfg = new VideoCfg();
        // cfg.fps = 15;
        // cfg.maxbps = -1;
        // cfg.minQuality = 22;
        // cfg.maxQuality = 25;
        // cfg.size = new Size(80, 80);
        // attr.quality2Cfg = cfg;
        // CloudroomVideoMeeting.getInstance().setLocVideoAttributes(
        // defaultVideoID, attr);

        // 打开摄像头
        CloudroomVideoMeeting.getInstance().openVideo(myUserID)
        // //设置摄像头焦距，需要摄像头打开之后才能设置，重新打开摄像头以前的设置失效
        // short videoID = CloudroomVideoMeeting.getInstance().getDefaultVideo(
        // myUserID);
        // String params = CloudroomVideoMeeting.getInstance()
        // .getLocalVideoParams(videoID);
        // Log.d(TAG, "getLocalVideoParams:" + params);
        // CloudroomVideoMeeting.getInstance().setLocalVideoParam(videoID,
        // "zoom",
        // "" + 270);

        // 打开麦克风
        CloudroomVideoMeeting.getInstance().openMic(myUserID)
        setScreenShareMsg()
    }

    private fun setScreenShareMsg() {
        if (mRoomType == MainActivity.ROOM_SCREEN_SHARE) {
            screenShareView.visibility = View.VISIBLE
            val id = if (mMeetInfo != null) {
                mMeetInfo!!.ID
            } else {
                mMeetID
            }
            screenShareView.setRoomMsg(
                id, CloudroomVideoMeeting.getInstance()
                    .getNickName(CloudroomVideoMeeting.getInstance().myUserID)
            )
        }
    }

    private fun switchCamera() {
        val userId = CloudroomVideoMeeting.getInstance().myUserID
        val curDev = CloudroomVideoMeeting.getInstance().getDefaultVideo(
            userId
        )
        val devs = CloudroomVideoMeeting.getInstance()
            .getAllVideoInfo(userId)
        if (devs.size > 1) {
            var info = devs[0]
            var find = false
            for (dev in devs) {
                if (find) {
                    info = dev
                    break
                } else if (dev.videoID == curDev) {
                    find = true
                }
            }
            setCamState(info.videoName.contains("FRONT"))
            CloudroomVideoMeeting.getInstance().setDefaultVideo(
                info.userId,
                info.videoID
            )
        }
    }

    private fun setCamState() {
        val status = CloudroomVideoMeeting.getInstance()
            .getVideoStatus(CloudroomVideoMeeting.getInstance().myUserID)
        if (status == VSTATUS.VOPEN || status == VSTATUS.VOPENING) {
            btnCamOpen.text = "关闭摄像头"
        } else {
            btnCamOpen.text = "开启摄像头"
        }
    }

    private fun setCamState(front: Boolean) {
        if (front) {
            btnCam.text = "后置摄像头"
        } else {
            btnCam.text = "前置摄像头"
        }
    }

    private fun showExitDialog() {
        UITool.showConfirmDialog(this, getString(R.string.exit_meeting),
            object : UITool.ConfirmDialogCallback {
                override fun onOk() {
                    exitMeeting()
                }

                override fun onCancel() {
                }
            })
    }

    private fun exitMeeting() {
        if (recordLayout.visibility == View.VISIBLE) {
            recordLayout.stopRecord()
        }
        // 离开会议
        CloudroomVideoMeeting.getInstance().exitMeeting()
        finish()
    }

    private fun watchHeadset() {
        if (mHeadsetReceiver != null) {
            return
        }
        mHeadsetReceiver = HeadsetReceiver()
        val filter = IntentFilter()
        filter.addAction(Intent.ACTION_HEADSET_PLUG)
        registerReceiver(mHeadsetReceiver, filter)
    }

    private fun unwatchHeadset() {
        if (mHeadsetReceiver == null) {
            return
        }
        unregisterReceiver(mHeadsetReceiver)
        mHeadsetReceiver = null
    }

    private class HeadsetReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val action = intent.action
            Log.d(TAG, "HeadsetReceiver : $action")
            if (intent.hasExtra("state")) {
                val state = intent.getIntExtra("state", 0)
                Log.d(TAG, "HeadsetReceiver state:$state")
                CloudroomVideoMeeting.getInstance().speakerOut = state != 1
                val speakerOut = CloudroomVideoMeeting.getInstance()
                    .speakerOut
                Log.d(TAG, "setSpeakerOut:$speakerOut")
            }
        }
    }

    override fun onBackPressed() {
        exitMeeting()
    }

    override fun onDestroy() {
        super.onDestroy()
        if (screenShareView.visibility == View.VISIBLE) {
            screenShareView.stopScreenShare()
        }
        unwatchHeadset()
        CloudroomVideoMeeting.getInstance().exitMeeting()
        CloudroomVideoMeeting.getInstance().unregisterCallback(mMeetingCallback)
        CloudroomVideoMgr.getInstance().unregisterCallback(mMgrCallback)
        mMeetID = 0
        mMeetPswd = ""
        mBCreateMeeting = false
    }

}