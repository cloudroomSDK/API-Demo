using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;


public class MediaSelectPage : MonoBehaviour
{
    private CRVSDKMain g_sdkMain = null;

    private Button mRefresh = null;
    private Text mMediaPlayInfo = null;
    private Dropdown mDDMediaFile = null;
    private string mMediaPath;

    void Awake()
    {
        g_sdkMain = MeetingPage.g_sdkMain;
        g_sdkMain.getSDKMeeting().onStartPlayMediaFail += startPlayMediaFail;
        g_sdkMain.getSDKMeeting().notifyMediaStart += notifyMediaStart;
        g_sdkMain.getSDKMeeting().notifyMediaStop += notifyMediaStop;

        mRefresh = GameObject.Find("RefreshBtn").GetComponent<Button>();
        mRefresh.onClick.AddListener(OnRefreshClicked);
        mMediaPlayInfo = GameObject.Find("txtMediaInfo").GetComponent<Text>();
        mDDMediaFile = GameObject.Find("ddMediaFile").GetComponent<Dropdown>();
        mDDMediaFile.onValueChanged.AddListener(OnMediaFileChanged);

        mMediaPath = Path.Combine(System.Environment.CurrentDirectory, "Media");
        if (!Directory.Exists(mMediaPath))
        {
            Directory.CreateDirectory(mMediaPath);
        }
        OnRefreshClicked();
        UpdateMediaInfo();
    }

    void OnDisable()
    {
        g_sdkMain.getSDKMeeting().onStartPlayMediaFail -= startPlayMediaFail;
        g_sdkMain.getSDKMeeting().notifyMediaStart -= notifyMediaStart;
        g_sdkMain.getSDKMeeting().notifyMediaStop -= notifyMediaStop;
    }

    private void startPlayMediaFail(CRVSDK_ERR_DEF sdkErr)
    {
        mMediaPlayInfo.text = "播放影音失败，错误：" + sdkErr;
    }

    private void notifyMediaStart(string userID)
    {
        OnExitMediaSelectClicked();
    }

    private void notifyMediaStop(string userID, CRVSDK_MEDIA_STOPREASON reason)
    {
        UpdateMediaInfo();
    }

    private void UpdateMediaInfo()
    {
        sdkScreenShareInfo ssInfo = g_sdkMain.getSDKMeeting().getScreenShareInfo();
        if (ssInfo._state == 1)
        {
            mMediaPlayInfo.text = ssInfo._sharerUserID + " 正在进行屏幕共享";
            mDDMediaFile.interactable = false;
            return;
        }

        sdkMediaInfo mInfo = g_sdkMain.getSDKMeeting().getMediaInfo();
        if (mInfo._state != CRVSDK_MEDIA_STATE.CRVSDK_MEDIAST_STOPPED)
        {
            mMediaPlayInfo.text = mInfo._userID + " 正在共享影音";
            mDDMediaFile.interactable = false;
            return;
        }

        mMediaPlayInfo.text = "请将影音文件放在该路径：" + mMediaPath;
        mDDMediaFile.interactable = true;
    }

    public void OnRefreshClicked()
    {
        mDDMediaFile.ClearOptions();

        List<string> medias = new List<string>();
        medias.Add("未选择");

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

    public void OnMediaFileChanged(int value)
    {
        if (value == 0)
            return;
        string mediaFile = Path.Combine(mMediaPath, mDDMediaFile.options[value].text);
        g_sdkMain.getSDKMeeting().startPlayMedia(mediaFile);
    }

    public void OnExitMediaSelectClicked()
    {
        StartCoroutine(UnloadMediaSelectScene());
    }

    public IEnumerator UnloadMediaSelectScene()
    {
        AsyncOperation async = SceneManager.UnloadSceneAsync("MediaSelectScene");
        yield return async;
    }
}
