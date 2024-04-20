using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;


public class ScreenSharePage : MonoBehaviour
{
    private CRVSDKMain g_sdkMain = null;

    private Button mStartScreenShare = null;
    private Button mStopScreenShare = null;
    private Text mScreenShareInfo = null;

    void Awake()
    {
        g_sdkMain = MeetingPage.g_sdkMain;
        g_sdkMain.getSDKMeeting().notifyScreenShareStarted = notifyScreenShareStarted;
        g_sdkMain.getSDKMeeting().notifyScreenShareStopped = notifyScreenShareStopped;

        mStartScreenShare = GameObject.Find("StartScreenShareBtn").GetComponent<Button>();
        mStartScreenShare.onClick.AddListener(OnStartScreenShareClicked);
        mStopScreenShare = GameObject.Find("StopScreenShareBtn").GetComponent<Button>();
        mStopScreenShare.onClick.AddListener(OnStopScreenShareClicked);
        mScreenShareInfo = GameObject.Find("txtScreenShareInfo").GetComponent<Text>();

        UpdateScreenShareUI();
    }

    void Start()
    {

    }

    private void notifyScreenShareStarted(string userID)
    {
        UpdateScreenShareUI();
    }
    private void notifyScreenShareStopped(string oprUserID)
    {
        UpdateScreenShareUI();
    }

    void UpdateScreenShareUI()
    {
        sdkScreenShareInfo screenShareInfo = g_sdkMain.getSDKMeeting().getScreenShareInfo();
        if (null == screenShareInfo)
            return;

        bool inScreenShare = (screenShareInfo._state != 0);
        mStartScreenShare.gameObject.SetActive(!inScreenShare);
        mStopScreenShare.gameObject.SetActive(inScreenShare);
        if (inScreenShare)
        {
            mScreenShareInfo.text = screenShareInfo._sharerUserID + " is sharing";
        }
        else
        {
            mScreenShareInfo.text = "Screen-Share not start";
        }
    }

    public void OnStartScreenShareClicked()
    {
        sdkMediaInfo mediaInfo = g_sdkMain.getSDKMeeting().getMediaInfo();
        if (null != mediaInfo && mediaInfo._state != CRVSDK_MEDIA_STATE.CRVSDK_MEDIAST_STOPPED)
        {
            mScreenShareInfo.text = "Already in media share, can not start screen share";
            return;
        }
        sdkScreenShareInfo screenShareInfo = g_sdkMain.getSDKMeeting().getScreenShareInfo();
        if (null != screenShareInfo && screenShareInfo._state != 0)
        {
            mScreenShareInfo.text = "Already in screen share, can not start another";
            return;
        }

        g_sdkMain.getSDKMeeting().startScreenShare();
        OnExitScreenShareClicked();
    }

    public void OnStopScreenShareClicked()
    {
        g_sdkMain.getSDKMeeting().stopScreenShare();
        OnExitScreenShareClicked();
    }

    public void OnExitScreenShareClicked()
    {
        StartCoroutine(UnloadScreenShareScene());
    }

    public IEnumerator UnloadScreenShareScene()
    {
        AsyncOperation async = SceneManager.UnloadSceneAsync("ScreenShareScene");
        yield return async;
    }
}
