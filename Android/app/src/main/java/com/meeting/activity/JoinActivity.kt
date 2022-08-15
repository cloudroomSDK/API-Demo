package com.meeting.activity

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import com.example.meetingdemo.R
import com.meeting.example.common.VideoSDKHelper
import com.meeting.example.tool.SPUtils
import kotlinx.android.synthetic.main.activity_join.*
import kotlinx.android.synthetic.main.title_bar.*

/**
 * Created by zjw on 2021/12/9.
 */
class JoinActivity : BaseActivity(), View.OnClickListener {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_join)
        tvTitle.text = intent.getStringExtra("title")
        if (MainActivity.ROOM_SCREEN_SHARE == intent.getIntExtra(MainActivity.ROOM_TYPE, 1)) {
            tvShare.visibility = View.VISIBLE
        }
    }

    override fun onResume() {
        super.onResume()
        val lastMeetId = getSharedPreferences(SPUtils.DATA_NAME, 0).getInt(SPUtils.LAST_MEET_ID, 0)
        if (lastMeetId > 0) {
            etNum.setText(lastMeetId.toString())
            etNum.setSelection(etNum.text.length)
        }
    }

    override fun onClick(p0: View?) {
        if (!VideoSDKHelper.getInstance().isLogin && p0?.id != R.id.ivBack) {
            Toast.makeText(this, "未登录", Toast.LENGTH_SHORT).show()
            finish()
            return
        }
        when (p0?.id) {
            R.id.ivBack -> finish()
            R.id.btnEnter -> enterMeeting()
            R.id.btnCreate -> enterMeetingActivity(
                0,
                "",
                true,
                intent.getIntExtra(MainActivity.ROOM_TYPE, 1)
            )
        }
    }

    private fun enterMeeting() {
        val meetIDStr: String = etNum.text.toString()
        var meetID = -1
        try {
            meetID = meetIDStr.toInt()
        } catch (e: Exception) {
            e.printStackTrace()
        }
        if (meetID < 0 || meetIDStr.length != 8) {
            VideoSDKHelper.getInstance().showToast(R.string.err_meetid_prompt)
            return
        }
        enterMeetingActivity(
            meetID, "", false,
            intent.getIntExtra(MainActivity.ROOM_TYPE, 1)
        )
    }

    private fun enterMeetingActivity(
        meetID: Int, meetPswd: String, createMeeting: Boolean,
        roomType: Int
    ) {
        val intent = Intent(this, MeetingActivity::class.java)
        MeetingActivity.mMeetID = meetID
        MeetingActivity.mMeetPswd = meetPswd
        MeetingActivity.mBCreateMeeting = createMeeting
        MeetingActivity.mRoomType = roomType
        startActivity(intent)
    }
}