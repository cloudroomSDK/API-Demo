using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;


public class MediaPlayPage : MonoBehaviour
{
    private CRVSDKMain g_sdkMain = null;

    private Button mPlayPause = null;
    private Button mStopBtn = null;
    private Text mMediaDuration = null;
    private Slider mSldDuration = null;
    private Slider mSldVolume = null;
    private MediaUI mMediaUI = null;
    private GameObject mOperGrps = null;
    private int mTotalSec = 0;
    private bool mPlayByMe = false;

    void Awake()
    {
        g_sdkMain = MeetingPage.g_sdkMain;

        mOperGrps = GameObject.Find("MediaOperGrps");
        mPlayPause = GameObject.Find("PlayPauseBtn").GetComponent<Button>();
        mPlayPause.onClick.AddListener(OnPlayPauseClicked);
        mStopBtn = GameObject.Find("StopBtn").GetComponent<Button>();
        mStopBtn.onClick.AddListener(OnStopMediaClicked);
        mMediaDuration = GameObject.Find("txtDuration").GetComponent<Text>();
        mSldDuration = GameObject.Find("sldDuration").GetComponent<Slider>();
        mSldDuration.onValueChanged.AddListener(OnDurationChanged);
        mSldDuration.minValue = 0;
        mSldDuration.wholeNumbers = true;
        mSldVolume = GameObject.Find("sldVolume").GetComponent<Slider>();
        mSldVolume.onValueChanged.AddListener(OnVolumeChanged);
        mSldVolume.minValue = 0;
        mSldVolume.maxValue = 255;
        mSldVolume.wholeNumbers = true;

        mOperGrps.SetActive(false);

        GameObject go = GameObject.Find("riMedia");
        go.transform.localScale = new Vector3(3.84f, 2.16f, 1f);
        mMediaUI = go.AddComponent<MediaUI>();
        mMediaUI.SetSDKMain(g_sdkMain);
        mMediaUI.onFrameTsChanged += notifyPlayPosChanged;
        mMediaUI.SetEnableRender(false);

        int mediaVol = g_sdkMain.getSDKMeeting().getMediaVolume();
        mSldVolume.value = mediaVol;
    }

    public void OnMediaOpened(int totalTime, int w, int h)
    {
        Debug.Log("notify media opened, total time: " + totalTime);
        mTotalSec = totalTime / 1000;
        mSldDuration.maxValue = mTotalSec;
        mSldDuration.SetValueWithoutNotify(0);
        UpdateDuration(0, totalTime);
    }

    public void OnMediaStart(string userID)
    {
        Debug.Log("notify media start, user: " + userID);
        mPlayByMe = (userID == MeetingPage.mMyUserId);
        mOperGrps.SetActive(mPlayByMe);
        if (mPlayByMe)
        {
            OnMediaPause(MeetingPage.mMyUserId, false);
        }
        mMediaUI.SetEnableRender(true);
    }

    public void OnMediaStop(string userID, CRVSDK_MEDIA_STOPREASON reason)
    {
        mOperGrps.SetActive(false);
        mMediaUI.SetEnableRender(false);
        mPlayByMe = false;
    }

    public void OnMediaPause(string userID, bool bPause)
    {
        if (bPause)
        {
            mPlayPause.GetComponentInChildren<Text>().text = "暂停";
        }
        else
        {
            mPlayPause.GetComponentInChildren<Text>().text = "播放";
        }
    }

    private void notifyPlayPosChanged(long pts)
    {
        if(!mPlayByMe)
            return;

        int playSec = (int)(pts / 1000);
        mSldDuration.SetValueWithoutNotify(playSec);
        UpdateDuration(playSec, mTotalSec);
    }

    private void UpdateDuration(int playSec, int totalSec)
    {
        TimeSpan playTs = TimeSpan.FromSeconds(playSec);
        TimeSpan totalTs = TimeSpan.FromSeconds(totalSec);
        bool showHour = (totalTs.Hours > 0);
        string strFmt = showHour ? "hh\\:mm\\:ss" : "mm\\:ss";
        mMediaDuration.text = string.Format("{0}/{1}", playTs.ToString(strFmt), totalTs.ToString(strFmt));
    }

    public void OnPlayPauseClicked()
    {
        sdkMediaInfo mInfo = g_sdkMain.getSDKMeeting().getMediaInfo();
        bool bPlaying = (mInfo._state == CRVSDK_MEDIA_STATE.CRVSDK_MEDIAST_PLAYING);
        g_sdkMain.getSDKMeeting().pausePlayMedia(bPlaying);
    }

    public void OnStopMediaClicked()
    {
        g_sdkMain.getSDKMeeting().stopPlayMedia();
    }

    public void OnDurationChanged(float value)
    {
        int playMs = (int)value * 1000;
        g_sdkMain.getSDKMeeting().setMediaPlayPos(playMs);
    }

    public void OnVolumeChanged(float value)
    {
        g_sdkMain.getSDKMeeting().setMediaVolume((int)value);
    }
}
