using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;


public class MediaPlayPage : MonoBehaviour
{
    private CRVSDKMain g_sdkMain = null;

    private Button mRefresh = null;
    private Button mPlayPause = null;
    private Button mStopBtn = null;
    private Text mMediaPlayInfo = null;
    private Dropdown mDDMediaFile = null;
    private Text mMediaDuration = null;
    private Slider mSldDuration = null;
    private Slider mSldVolume = null;
    private MediaUI mMediaUI = null;
    private GameObject mOperGrps = null;
    private string mMediaPath;
    private int mTotalSec = 0;
    private bool mPlayByMe = false;

    void Awake()
    {
        g_sdkMain = MeetingPage.g_sdkMain;
        g_sdkMain.getSDKMeeting().onStartPlayMediaFail += startPlayMediaFail;
        g_sdkMain.getSDKMeeting().notifyMediaOpened += notifyMediaOpened;
        g_sdkMain.getSDKMeeting().notifyMediaStart += notifyMediaStart;
        g_sdkMain.getSDKMeeting().notifyMediaStop += notifyMediaStop;
        g_sdkMain.getSDKMeeting().notifyMediaPause += notifyMediaPause;

        mOperGrps = GameObject.Find("MediaOperGrps");
        Debug.Log("MediaOperGrps--1, is null: " + (mOperGrps == null));
        mRefresh = GameObject.Find("RefreshBtn").GetComponent<Button>();
        mRefresh.onClick.AddListener(OnRefreshClicked);
        mPlayPause = GameObject.Find("PlayPauseBtn").GetComponent<Button>();
        mPlayPause.onClick.AddListener(OnPlayPauseClicked);
        mStopBtn = GameObject.Find("StopBtn").GetComponent<Button>();
        mStopBtn.onClick.AddListener(OnStopMediaClicked);
        mMediaPlayInfo = GameObject.Find("txtMediaInfo").GetComponent<Text>();
        mMediaDuration = GameObject.Find("txtDuration").GetComponent<Text>();
        mDDMediaFile = GameObject.Find("ddMediaFile").GetComponent<Dropdown>();
        mDDMediaFile.onValueChanged.AddListener(OnMediaFileChanged);
        mSldDuration = GameObject.Find("sldDuration").GetComponent<Slider>();
//         mSldDuration.onValueChanged.AddListener(OnDurationChanged);
        mSldDuration.minValue = 0;
        mSldVolume = GameObject.Find("sldVolume").GetComponent<Slider>();
        mSldVolume.onValueChanged.AddListener(OnVolumeChanged);
        mSldVolume.minValue = 0;
        mSldVolume.maxValue = 255;

        mMediaPath = Path.Combine(System.Environment.CurrentDirectory, "Media");
        if (!Directory.Exists(mMediaPath))
        {
            Directory.CreateDirectory(mMediaPath);
        }
        mMediaPlayInfo.text = "Please put media file in path: " + mMediaPath;
        OnRefreshClicked();

        mOperGrps.SetActive(false);
        Debug.Log("MediaOperGrps--2, is null: " + (mOperGrps == null));

        GameObject go = GameObject.Find("RawImage");
        go.transform.localScale = new Vector3(3.2f, 1.8f, 1f);
        mMediaUI = go.AddComponent<MediaUI>();
        mMediaUI.SetSDKMain(g_sdkMain);
        mMediaUI.onPlayPosChanged += notifyPlayPosChanged;
        mMediaUI.SetEnableRender(false);

        int mediaVol = g_sdkMain.getSDKMeeting().getMediaVolume();
        mSldVolume.value = mediaVol;
    }

    void OnDisable()
    {
        g_sdkMain.getSDKMeeting().onStartPlayMediaFail -= startPlayMediaFail;
        g_sdkMain.getSDKMeeting().notifyMediaOpened -= notifyMediaOpened;
        g_sdkMain.getSDKMeeting().notifyMediaStart -= notifyMediaStart;
        g_sdkMain.getSDKMeeting().notifyMediaStop -= notifyMediaStop;
        g_sdkMain.getSDKMeeting().notifyMediaPause -= notifyMediaPause;
        if (mPlayByMe)
        {
            g_sdkMain.getSDKMeeting().stopPlayMedia();
            mPlayByMe = false;
        }
    }

    private void startPlayMediaFail(CRVSDK_ERR_DEF sdkErr)
    {
        mMediaPlayInfo.text = "Start play media fail, error: " + sdkErr;
        mOperGrps.SetActive(false);
        mMediaUI.SetEnableRender(false);
    }

    private void notifyMediaOpened(int totalTime, int w, int h)
    {
        Debug.Log("notify media opened, total time: " + totalTime);
        mTotalSec = totalTime / 1000;
        mSldDuration.maxValue = mTotalSec;
        mSldDuration.value = 0;
        UpdateDuration(0, totalTime);
    }

    private void notifyMediaStart(string userID)
    {
        Debug.Log("notify media start, user: " + userID);
        mPlayByMe = (userID == MeetingPage.mMyUserId);
        if (mPlayByMe)
        {
            Debug.Log("MediaOperGrps--3, is null: " + (mOperGrps == null));
            mOperGrps.SetActive(true);
            notifyMediaPause(MeetingPage.mMyUserId, false);
        }
        mMediaUI.SetEnableRender(true);
    }

    private void notifyMediaStop(string userID, CRVSDK_MEDIA_STOPREASON reason)
    {
        mOperGrps.SetActive(false);
        Debug.Log("MediaOperGrps--4, is null: " + (mOperGrps == null));
        mMediaUI.SetEnableRender(false, false);
        mPlayByMe = false;
    }

    private void notifyMediaPause(string userID, bool bPause)
    {
        if (bPause)
        {
            mPlayPause.GetComponentInChildren<Text>().text = "Pause";
        }
        else
        {
            mPlayPause.GetComponentInChildren<Text>().text = "Play";
        }
    }

    private void notifyPlayPosChanged(long pts)
    {
        if(!mPlayByMe)
            return;

        float playSec = (float)(pts / 1000);
        mSldDuration.value = playSec;
        UpdateDuration((int)playSec, mTotalSec);
    }

    private void UpdateDuration(int playSec, int totalSec)
    {
        TimeSpan playTs = TimeSpan.FromSeconds(playSec);
        TimeSpan totalTs = TimeSpan.FromSeconds(totalSec);
        bool showHour = (totalTs.Hours > 0);
        string strFmt = showHour ? "hh\\:mm\\:ss" : "mm\\:ss";
        mMediaDuration.text = string.Format("{0}/{1}", playTs.ToString(strFmt), totalTs.ToString(strFmt));
    }

    public void OnRefreshClicked()
    {
        mDDMediaFile.ClearOptions();

        List<string> medias = new List<string>();
        medias.Add("None");

        List<string> supportExts = new List<string>{ ".wav", ".mp3", ".avi", ".mp4", ".mkv", ".mov", ".wmv", ".flv" };
        var allFiles = Directory.GetFiles(mMediaPath);
        foreach (var file in allFiles)
        {
            if(supportExts.Contains(Path.GetExtension(file).ToLower()))
            {
                medias.Add(Path.GetFileName(file));
            }
        }
        mDDMediaFile.AddOptions(medias);
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

    public void OnMediaFileChanged(int value)
    {
        if (value == 0)
            return;
        string mediaFile = Path.Combine(mMediaPath, mDDMediaFile.options[value].text);
        g_sdkMain.getSDKMeeting().startPlayMedia(mediaFile);
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

    public void OnExitMediaPlayClicked()
    {
        StartCoroutine(UnloadMediaPlayScene());
    }

    public IEnumerator UnloadMediaPlayScene()
    {
        AsyncOperation async = SceneManager.UnloadSceneAsync("MediaPlayScene");
        yield return async;
    }
}
