package com.meeting.activity

import android.annotation.SuppressLint
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Environment
import android.os.Handler
import android.os.Message
import android.preference.PreferenceManager
import android.provider.Settings
import android.text.TextUtils
import android.view.View
import android.widget.Toast
import com.cloudroom.cloudroomvideosdk.CRMgrCallback
import com.cloudroom.cloudroomvideosdk.CloudroomVideoMeeting
import com.cloudroom.cloudroomvideosdk.CloudroomVideoMgr
import com.cloudroom.cloudroomvideosdk.CloudroomVideoSDK
import com.cloudroom.cloudroomvideosdk.model.CRVIDEOSDK_ERR_DEF
import com.cloudroom.cloudroomvideosdk.model.LoginDat
import com.example.meetingdemo.R
import com.meeting.example.common.PermissionManager
import com.meeting.example.common.VideoSDKHelper
import com.meeting.example.tool.SPUtils
import com.tencent.bugly.crashreport.inner.InnerAPI.context
import kotlinx.android.synthetic.main.activity_main.*
import kotlinx.android.synthetic.main.title_bar.*


/**
 * Created by zjw on 2021/12/3.
 */
class MainActivity : BaseActivity(), View.OnClickListener {

    companion object {
        const val ROOM_TYPE = "room_type"
        const val ROOM_AUDIO = 1
        const val ROOM_VIDEO = 2
        const val ROOM_VIDEO_SETTING = 3
        const val ROOM_AUDIO_SETTING = 4
        const val ROOM_SCREEN_SHARE = 5
        const val ROOM_RECORD_LOCAL = 6
        const val ROOM_RECORD_CLOUD = 7
        const val ROOM_video_play = 8
        const val ROOM_IM = 9
        const val USER_IN_MEETING = "USER_IN_MEETING"
    }

    private val MSG_LOGIN = 0
    private var mLoginData: LoginDat? = null
    private var mLoging = false
    private val ACOUNT_RANDOM = ((Math.random() * 9 + 1) * 1000).toInt()

    private val mHandler: Handler = @SuppressLint("HandlerLeak")
    object : Handler() {
        override fun handleMessage(msg: Message) {
            when (msg.what) {
                MSG_LOGIN -> doLogin()
                else -> {
                }
            }
            super.handleMessage(msg)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        ivBack.visibility = View.GONE
        ivSetting.visibility = View.VISIBLE
        tvTitle.text = getString(R.string.app_name)
    }

    override fun onResume() {
        super.onResume()
        checkLogin()
        if (SettingActivity.bSettingChanged) {
            mHandler.removeMessages(MSG_LOGIN)
            mHandler.sendEmptyMessage(MSG_LOGIN)
            VideoSDKHelper.getInstance().logout()
        }
        SettingActivity.bSettingChanged = false
    }

    override fun onRequestPermissionsFinished() {
        super.onRequestPermissionsFinished()
        // 设置呼叫处理对象
        CloudroomVideoMgr.getInstance().registerCallback(mMgrCallback)
        checkLogin()
    }

    private fun checkLogin() {
        if (!VideoSDKHelper.getInstance().isLogin) {
            mLoging = false
            mHandler.removeMessages(MSG_LOGIN)
            mHandler.sendEmptyMessage(MSG_LOGIN)
        }
    }

    private val mMgrCallback: CRMgrCallback = object : CRMgrCallback() {
        // 登陆失败
        override fun loginFail(sdkErr: CRVIDEOSDK_ERR_DEF, cookie: String) {
            mHandler.removeMessages(MSG_LOGIN)
            // 提示登录失败及原因
            VideoSDKHelper.getInstance().showToast(R.string.login_fail, sdkErr)
            // 如果是状态不对导致失败，恢复登录状态到未登陆
            if (sdkErr == CRVIDEOSDK_ERR_DEF.CRVIDEOSDK_LOGINSTATE_ERROR) {
                VideoSDKHelper.getInstance().logout()
                mHandler.sendEmptyMessage(MSG_LOGIN)
            } else {
                mHandler.sendEmptyMessageDelayed(MSG_LOGIN, 10 * 1000.toLong())
            }
            mLoging = false
        }

        // 登陆成功
        override fun loginSuccess(usrID: String, cookie: String) {
            mHandler.removeMessages(MSG_LOGIN)
            // 提示登录成功
            VideoSDKHelper.getInstance().showToast(R.string.login_success)
            VideoSDKHelper.getInstance().nickName = mLoginData?.nickName
            mLoging = false
            val lastMeetId =
                getSharedPreferences(SPUtils.DATA_NAME, 0).getInt(SPUtils.LAST_MEET_ID, 0)
            if (CloudroomVideoMeeting.getInstance()
                    .isUserInMeeting(CloudroomVideoMeeting.getInstance().myUserID)
                && lastMeetId > 0
            ) {
                val intent = Intent(this@MainActivity, MeetingActivity::class.java)
                MeetingActivity.mMeetID = lastMeetId
                MeetingActivity.mMeetPswd = ""
                MeetingActivity.mBCreateMeeting = false
                MeetingActivity.mRoomType =
                    getSharedPreferences(SPUtils.DATA_NAME, 0).getInt(SPUtils.ROOM_TYPE, 1)
                startActivity(intent)
            }
            if (!Environment.isExternalStorageManager()) {
                val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                intent.data = Uri.parse("package:" + context.packageName)
                startActivityForResult(intent, 100)
            }
        }

        override fun lineOff(sdkErr: CRVIDEOSDK_ERR_DEF) {
            // 掉线立即重登
            mHandler.removeMessages(MSG_LOGIN)
            mHandler.sendEmptyMessage(MSG_LOGIN)
            VideoSDKHelper.getInstance().showToast(
                getString(R.string.lineoff),
                sdkErr
            )
            mLoging = false
        }
    }

    // 登陆操作
    private fun doLogin() {
        mHandler.removeMessages(MSG_LOGIN)
        if (mLoging || VideoSDKHelper.getInstance().isLogin) {
            return
        }
        val sharedPreferences = PreferenceManager
            .getDefaultSharedPreferences(this)
        // 获取配置的服务器地址
        val server = sharedPreferences.getString(
            SettingActivity.KEY_SERVER,
            SettingActivity.DEFAULT_SERVER
        )
        // 获取配置的账号密码
        val authAccount = sharedPreferences.getString(
            SettingActivity.KEY_ACCOUNT, SettingActivity.DEFAULT_ACCOUNT
        )
        val authPswd = sharedPreferences.getString(
            SettingActivity.KEY_PSWD,
            SettingActivity.DEFAULT_PSWD
        )
        // 登录私有账号昵称，正式商用建议使用有意义的不重复账号
        val privAcnt = "Android_$ACOUNT_RANDOM"

        // 检查服务器地址是否为空
        if (TextUtils.isEmpty(server)) {
            VideoSDKHelper.getInstance().showToast(R.string.null_server)
            return
        }
        // 检查账号密码是否为空
        if (TextUtils.isEmpty(authAccount)) {
            VideoSDKHelper.getInstance().showToast(R.string.null_account)
            return
        }
        if (TextUtils.isEmpty(authPswd)) {
            VideoSDKHelper.getInstance().showToast(R.string.null_pswd)
            return
        }
        // 检查昵称是否为空
        if (TextUtils.isEmpty(privAcnt)) {
            VideoSDKHelper.getInstance().showToast(R.string.null_nickname)
            return
        }
        doLogin(server!!, authAccount!!, authPswd!!, privAcnt, privAcnt)
    }

    // 登陆操作
    private fun doLogin(
        server: String, authAcnt: String, authPswd: String,
        nickName: String, privAcnt: String
    ) {
        // 设置服务器地址
        CloudroomVideoSDK.getInstance().setServerAddr(server)
        // 登录数据对象
        val loginDat = LoginDat()
        // 昵称
        loginDat.nickName = nickName
        // 第三方账号
        loginDat.privAcnt = privAcnt
        // 登录账号，使用开通SDK的账号
        loginDat.authAcnt = authAcnt
        // 登录密码必须做MD5处理
        loginDat.authPswd = authPswd
        // 执行登录操作
        CloudroomVideoMgr.getInstance().login(loginDat)
        mHandler.removeMessages(MSG_LOGIN)
        mLoginData = loginDat
        mLoging = true
    }

    override fun onClick(p0: View?) {
        if (!VideoSDKHelper.getInstance().isLogin && R.id.ivSetting != p0?.id) {
            VideoSDKHelper.getInstance().showToast(R.string.loging)
            return
        }
        when (p0?.id) {
            R.id.ivSetting -> startActivity(SettingActivity::class.java)
            R.id.btnMicCall -> startJoin(btnMicCall.text.toString(), ROOM_AUDIO)
            R.id.btnVideoCall -> startJoin(btnVideoCall.text.toString(), ROOM_VIDEO)
            R.id.btnMicSetting -> startJoin(btnMicSetting.text.toString(), ROOM_AUDIO_SETTING)
            R.id.btnVideoSetting -> startJoin(btnVideoSetting.text.toString(), ROOM_VIDEO_SETTING)
            R.id.btnScreenShare -> startJoin(btnScreenShare.text.toString(), ROOM_SCREEN_SHARE)
            R.id.btnChat -> startJoin(btnChat.text.toString(), ROOM_IM)
            R.id.btnLocalRecord -> startJoin(btnLocalRecord.text.toString(), ROOM_RECORD_LOCAL)
            R.id.btnCloudRecord -> startJoin(btnCloudRecord.text.toString(), ROOM_RECORD_CLOUD)
            R.id.btnVideoPlay -> startJoin(btnVideoPlay.text.toString(), ROOM_video_play)
        }
    }

    private fun startJoin(title: String, roomType: Int) {
        val intent = Intent(this, JoinActivity::class.java)
        intent.putExtra("title", title)
        intent.putExtra(ROOM_TYPE, roomType)
        startActivity(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        mHandler.removeMessages(MSG_LOGIN)
        CloudroomVideoMgr.getInstance().unregisterCallback(mMgrCallback)
    }
}