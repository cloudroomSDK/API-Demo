using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;


public class ScreenSharePage : MonoBehaviour
{
    private CRVSDKMain g_sdkMain = null;

    private Text mScreenShareInfo = null;
    private ScreenUI mScreenUI = null;
    private bool mShareByMe = false;

    void Awake()
    {
        g_sdkMain = MeetingPage.g_sdkMain;

        mScreenShareInfo = GameObject.Find("txtScreenInfo").GetComponent<Text>();
        GameObject go = GameObject.Find("riScreen");
        go.transform.localScale = new Vector3(4.16f, 2.34f, 1f);
        mScreenUI = go.AddComponent<ScreenUI>();
        mScreenUI.SetSDKMain(g_sdkMain);
        mScreenUI.SetEnableRender(false);

//         UpdateScreenShareUI();
    }

    void Start()
    {

    }

    public void OnScreenShareStarted(string userID)
    {
        mShareByMe = (userID == MeetingPage.mMyUserId);
        UpdateScreenShareUI();
        if (!mShareByMe)
        {
            mScreenUI.SetEnableRender(true);
        }
    }
    public void OnScreenShareStopped(string oprUserID)
    {
        mShareByMe = false;
        UpdateScreenShareUI();
        mScreenUI.SetEnableRender(false);
    }

    void UpdateScreenShareUI()
    {
        sdkScreenShareInfo screenShareInfo = g_sdkMain.getSDKMeeting().getScreenShareInfo();
        if (null == screenShareInfo)
            return;

        if (screenShareInfo._state != 0)
        {
            mScreenShareInfo.text = screenShareInfo._sharerUserID + " 正在进行共享";
        }
        else
        {
            mScreenShareInfo.text = "屏幕共享未开始";
        }
    }
}
