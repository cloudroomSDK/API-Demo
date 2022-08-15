package com.meeting.activity

import android.os.Bundle
import android.preference.PreferenceManager
import android.text.TextUtils
import android.view.View
import com.example.meetingdemo.R
import com.meeting.example.common.VideoSDKHelper
import com.meeting.example.tool.MD5Util
import kotlinx.android.synthetic.main.activity_setting.*
import kotlinx.android.synthetic.main.title_bar.*

/**
 * Created by zjw on 2021/12/7.
 */
class SettingActivity : BaseActivity(), View.OnClickListener {

    companion object{
        const val KEY_SERVER = "server"
        const val KEY_ACCOUNT = "account"
        const val KEY_PSWD = "password"
        const val DEFAULT_SERVER = "sdk.cloudroom.com"
        const val DEFAULT_ACCOUNT = "demo@cloudroom.com"
        val DEFAULT_PSWD: String = com.meeting.example.tool.MD5Util.MD5("123456")
        var bSettingChanged = false
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_setting)
        tvRight.visibility = View.VISIBLE
        tvTitle.text = "设置"
        val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)
        val server = sharedPreferences.getString(KEY_SERVER, DEFAULT_SERVER)
        val account = sharedPreferences.getString(KEY_ACCOUNT, DEFAULT_ACCOUNT)
        val pswd = sharedPreferences.getString(KEY_PSWD, DEFAULT_PSWD)
        etServer.setText(server)
        etServer.setSelection(server?.length ?: 0)
        etAppId.setText(account)
        etSecret.setText(pswd)
    }

    override fun onClick(p0: View?) {
        when (p0?.id) {
            R.id.ivBack -> finish()
            R.id.btnRestore -> {
                etServer.setText(DEFAULT_SERVER)
                etAppId.setText(DEFAULT_ACCOUNT)
                etSecret.setText(DEFAULT_PSWD)
                saveAndFinish()
            }
            R.id.tvRight -> saveAndFinish()
        }
    }

    private fun saveAndFinish() {
        val server: String = etServer.text.toString()
        val account: String = etAppId.text.toString()
        var pswd: String = etSecret.text.toString()
        if (TextUtils.isEmpty(server)) {
            VideoSDKHelper.getInstance().showToast(R.string.null_server)
            return
        }
        if (TextUtils.isEmpty(account)) {
            VideoSDKHelper.getInstance().showToast(R.string.null_account)
            return
        }
        if (TextUtils.isEmpty(pswd)) {
            VideoSDKHelper.getInstance().showToast(R.string.null_pswd)
            return
        }
        val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)
        val oldPswd = sharedPreferences.getString(KEY_PSWD, DEFAULT_PSWD)
        val oldAccount = sharedPreferences.getString(KEY_ACCOUNT, DEFAULT_ACCOUNT)
        val oldServer = sharedPreferences.getString(KEY_SERVER, DEFAULT_SERVER)
        val editor = sharedPreferences.edit()
        if (oldPswd != pswd) {
            // 判断密码是否恢复默认
            if (DEFAULT_PSWD != pswd) {
                pswd = MD5Util.MD5(pswd)
            }
            if (TextUtils.isEmpty(pswd)) {
                editor.remove(KEY_PSWD)
            } else {
                editor.putString(KEY_PSWD, pswd)
            }
            bSettingChanged = true
        }
        if (oldServer != server) {
            if (TextUtils.isEmpty(server)) {
                editor.remove(KEY_SERVER)
            } else {
                editor.putString(KEY_SERVER, server)
            }
            bSettingChanged = true
        }
        if (oldAccount != account) {
            if (TextUtils.isEmpty(account)) {
                editor.remove(KEY_ACCOUNT)
            } else {
                editor.putString(KEY_ACCOUNT, account)
            }
            bSettingChanged = true
        }
        editor.commit()
        finish()
    }
}