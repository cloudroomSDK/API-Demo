using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

[Serializable]
public class ScreenShareBaseCfg
{
    public bool shareSound;
    public int qp;
    public int maxKbps;
}
[Serializable]
public class ShareScreenInfo : ScreenShareBaseCfg
{
    public long monitorID;
}
[Serializable]
public class ShareWindowInfo : ScreenShareBaseCfg
{
    public long catchWnd;
    public bool activateWindow;
    public bool borderHighLight;
    public string highLightColor;
    public string highLightColorForPause;
    public int highLightWidth;
}

public class ScreenShareStatePage : MonoBehaviour
{
    private CRVSDKMain g_sdkMain = null;

    private Button mStartScreenShare = null;
    private Button mStopScreenShare = null;
    private Text mScreenShareInfo = null;
    private GameObject mScrollView = null;
    private Transform mCanvas = null;
    private RectTransform mRtTrans = null;
    private Toggle mAudioBtn = null;
    private Toggle mFluencyBtn = null;
    private GameObject mContent = null;
    private ToggleGroup mTgGrp = null;

    private GameObject mScreenCaptureThumb = null;
    private ScreenCaptureSourceInfoList mScreenList = new ScreenCaptureSourceInfoList();
    private ScreenCaptureSourceInfoList mWindowList = new ScreenCaptureSourceInfoList();

    void Awake()
    {
        g_sdkMain = MeetingPage.g_sdkMain;

        mStartScreenShare = GameObject.Find("StartScreenShareBtn").GetComponent<Button>();
        mStopScreenShare = GameObject.Find("StopScreenShareBtn").GetComponent<Button>();
        mScreenShareInfo = GameObject.Find("txtScreenShareInfo").GetComponent<Text>();
        mAudioBtn = GameObject.Find("tgShareAudio").GetComponent<Toggle>();
        mFluencyBtn = GameObject.Find("tgFluency").GetComponent<Toggle>();

        mScrollView = GameObject.Find("Scroll View");
        mCanvas = GameObject.Find("Canvas").transform;
        mContent = GameObject.Find("Content");
        mRtTrans = mContent.GetComponent<RectTransform>();
        mTgGrp = mContent.GetComponent<ToggleGroup>();
        mTgGrp.allowSwitchOff = true;
        mScrollView.SetActive(false);

        mScreenCaptureThumb = Resources.Load<GameObject>("Prefab/ScreenCaptureThumb");
        if (null == mScreenCaptureThumb)
        {
            Debug.Log("load ScreenCaptureThumb failed");
        }

        UpdateScreenShareUI();
    }

    void Start()
    {
    }

    void UpdateScreenShareUI()
    {
        sdkScreenShareInfo screenShareInfo = g_sdkMain.getSDKMeeting().getScreenShareInfo();
        if (null == screenShareInfo)
            return;

        bool inScreenShare = (screenShareInfo._state != 0);
        mStartScreenShare.gameObject.SetActive(!inScreenShare);
        mStopScreenShare.gameObject.SetActive(inScreenShare);
        mAudioBtn.gameObject.SetActive(!inScreenShare);
        mFluencyBtn.gameObject.SetActive(!inScreenShare);
        if (inScreenShare)
        {
            mScreenShareInfo.text = screenShareInfo._sharerUserID + " 正在进行共享";
        }
        else
        {
            mScreenShareInfo.text = "屏幕共享未开始";
            LoadScreenSourceSelect();
        }
    }

    private void LoadScreenSourceSelect()
    {
        if (mScrollView.activeSelf)
            return;
        if (null == mScreenCaptureThumb)
            return;

        mScrollView.SetActive(true);
        mScreenList = g_sdkMain.getSDKMeeting().getScreenCaptureSources(224, 126, 32, 32, CRVSDK_SCREENCAPTURESOURCE_TYPE.CRVSDK_CAPSOURCE_SCREEN);
        foreach(var sInfo in mScreenList)
        {
            GameObject go = Instantiate(mScreenCaptureThumb, mContent.transform);
            if (null == go)
                break;
            RawImage rawImage = go.GetComponentInChildren<RawImage>();
            rawImage.transform.localScale = new Vector3(3.2f, 1.8f, 1f);
            ScreenCaptureThumbItem render = go.AddComponent<ScreenCaptureThumbItem>();
            render.SetScreenCaptureInfo(sInfo);
            render.SetEnableRender(true);
            go.GetComponent<Toggle>().group = mTgGrp;
        }
        int remind = 3 - (mScreenList.Count % 3);
        for(int i = 0; i < remind; i++)
        {
            GameObject go = Instantiate(mScreenCaptureThumb, mContent.transform);
            if (null == go)
                break;
            Transform operGrp = go.transform.Find("OperGrp");
            RawImage riIcon = operGrp.Find("riIcon").GetComponent<RawImage>();
            riIcon.gameObject.SetActive(false);
            RawImage rawImage = go.GetComponentInChildren<RawImage>();
            rawImage.gameObject.SetActive(false);
            go.GetComponent<Toggle>().interactable = false;
        }
        mWindowList = g_sdkMain.getSDKMeeting().getScreenCaptureSources(224, 126, 32, 32, CRVSDK_SCREENCAPTURESOURCE_TYPE.CRVSDK_CAPSOURCE_WINDOW);
        foreach(var wInfo in mWindowList)
        {
            int thumbWidth = wInfo._thumbImage.getFrmWidth();
            int thumbHeight = wInfo._thumbImage.getFrmHeight();
            GameObject go = Instantiate(mScreenCaptureThumb, mContent.transform);
            if (null == go)
                break;
            RawImage rawImage = go.GetComponentInChildren<RawImage>();
            rawImage.transform.localScale = new Vector3(3.2f, 1.8f, 1f);
            ScreenCaptureThumbItem render = go.AddComponent<ScreenCaptureThumbItem>();
            render.SetScreenCaptureInfo(wInfo);
            render.SetEnableRender(true);
            go.GetComponent<Toggle>().group = mTgGrp;
        }

        StartCoroutine(DelaySetToggle(0.5f, ToggleFirstOn));
        mTgGrp.allowSwitchOff = false;
    }

    void ToggleFirstOn()
    {
        Toggle[] allTgs = mTgGrp.GetComponentsInChildren<Toggle>();
        if (allTgs.Length > 0)
        {
            allTgs[0].isOn = true;
            allTgs[0].onValueChanged.Invoke(true);
        }
    }

    IEnumerator DelaySetToggle(float delay, System.Action func)
    {
        yield return new WaitForSeconds(delay);
        func();
    }

    public void OnStartScreenShareClicked()
    {
        sdkMediaInfo mediaInfo = g_sdkMain.getSDKMeeting().getMediaInfo();
        if (null != mediaInfo && mediaInfo._state != CRVSDK_MEDIA_STATE.CRVSDK_MEDIAST_STOPPED)
        {
            mScreenShareInfo.text = mediaInfo._userID + " 正在播放影音，不能开始屏幕共享";
            return;
        }
        sdkScreenShareInfo screenShareInfo = g_sdkMain.getSDKMeeting().getScreenShareInfo();
        if (null != screenShareInfo && screenShareInfo._state != 0)
        {
            mScreenShareInfo.text = screenShareInfo._sharerUserID + " 正在屏幕共享中，不能开始其他的屏幕共享";
            return;
        }

        Toggle tg = mTgGrp.GetFirstActiveToggle();
        if (null == tg)
        {
            mScreenShareInfo.text = "请选择要共享的内容";
            return;
        }
        ScreenCaptureThumbItem sctItem = tg.gameObject.GetComponent<ScreenCaptureThumbItem>();
        if (null == sctItem)
        {
            mScreenShareInfo.text = "获取共享信息失败";
            return;
        }
        sdkScreenCaptureSourceInfo scsInfo = sctItem.GetScreenCaptureInfo();
        string ssCfg = GetCfgByShareInfo(scsInfo);

        g_sdkMain.getSDKMeeting().setScreenShareCfg(ssCfg);
        g_sdkMain.getSDKMeeting().startScreenShare();
        OnExitScreenShareClicked();
    }

    private string GetCfgByShareInfo(sdkScreenCaptureSourceInfo scsInfo)
    {
        if (scsInfo._type == CRVSDK_SCREENCAPTURESOURCE_TYPE.CRVSDK_CAPSOURCE_SCREEN)
        {
            ShareScreenInfo ssInfo = new ShareScreenInfo();
            ssInfo.monitorID = scsInfo._sourceId;
            ssInfo.shareSound = mAudioBtn.isOn;
            ssInfo.qp = mFluencyBtn.isOn ? 28 : 22;
            ssInfo.maxKbps = mFluencyBtn.isOn ? 1000 : 2000;
            return JsonUtility.ToJson(ssInfo);
        }
        else if (scsInfo._type == CRVSDK_SCREENCAPTURESOURCE_TYPE.CRVSDK_CAPSOURCE_WINDOW)
        {
            ShareWindowInfo swInfo = new ShareWindowInfo();
            swInfo.catchWnd = scsInfo._sourceId;
            swInfo.shareSound = mAudioBtn.isOn;
            swInfo.activateWindow = true;
            swInfo.borderHighLight = true;
            swInfo.highLightColor = "#54DB00";
            swInfo.highLightColorForPause = "#FFC268";
            swInfo.highLightWidth = 5;
            swInfo.qp = mFluencyBtn.isOn ? 28 : 22;
            swInfo.maxKbps = mFluencyBtn.isOn ? 1000 : 2000;
            return JsonUtility.ToJson(swInfo);
        }

        return "";
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
        AsyncOperation async = SceneManager.UnloadSceneAsync("ScreenShareStateScene");
        yield return async;
    }
}
