using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

[Serializable]
public class Serialization<T>
{
    [SerializeField]
    List<T> target;
    public List<T> ToList() { return target; }

    public Serialization(List<T> target)
    {
        this.target = target;
    }
}

[Serializable]
public class VideoCfg
{
    public string size;
    public int fps;
    public int maxbps;
    public int qp_min;
    public int qp_max;

    public VideoCfg()
    {
        fps = -1;
        maxbps = -1;
        qp_min = -1;
        qp_max = -1;
    }
}

[Serializable]
public class RecordParams
{
    public int width;
    public int height;
    public int frameRate;
    public int bitRate;
    public int defaultQP;
    public int gop;

    public RecordParams(int w, int h, int fps, int bps, int qp, int tmpgop)
    {
        width = w;
        height = h;
        frameRate = fps;
        bitRate = bps;
        defaultQP = qp;
        gop = tmpgop;
    }
}

[Serializable]
public class ContentParam
{
    public string camid;
    public ContentParam() {}
}

[Serializable]
public class RecordContent
{
    public int type;
    public int left;
    public int top;
    public int width;
    public int height;
    public ContentParam param;
    public int keepAspectRatio;

    public RecordContent()
    {
        type = (int)CRVSDK_MIXER_CONTENT_TYPE.CRVSDK_MIXCONT_VIDEO;
        left = 0;
        top = 0;
        width = 0;
        height = 0;
        keepAspectRatio = 0;
    }
}

[Serializable]
public class MixerOutputCfg
{
    public int type;
    public string filename;

    public MixerOutputCfg()
    {
        type = (int)CRVSDK_MIXER_OUTPUT_TYPE.CRVSDK_MIXER_OUTPUT_FILE;
    }
}

[Serializable]
public class MixerOutputInfo
{
    public int state;
    public int duration;
    public int fileSize;
    public int errCode;

    public MixerOutputInfo()
    {
        state = 0;
        duration = 0;
        fileSize = 0;
        errCode = 0;
    }
}

[Serializable]
public class CloudMixerOwner
{
    public string owner;
    public string ID;
    public CloudMixerOwner() { }
}

[Serializable]
public class CloudMixerInfo
{
    public int state;
    public string cfg;
    public CloudMixerInfo()
    {
        state = 0;
    }
}

[Serializable]
public class VideoFileCfg
{
    public string svrPathName;
    public int vWidth;
    public int vHeight;
    public int mixedLayout;
    public List<RecordContent> layoutConfig;
    public VideoFileCfg()
    {
        vWidth = 0;
        vHeight = 0;
        mixedLayout = 0;
    }
}

[Serializable]
public class CloudMixerCfg
{
    public int mode;
    public VideoFileCfg videoFileCfg;
    public CloudMixerCfg()
    {
        mode = 0;
    }
}

[Serializable]
public class CloudMixerErr
{
    public int err;
    public string errDesc;
    public CloudMixerErr()
    {
        err = 0;
    }
}

[Serializable]
public class CloudMixerOutputInfo
{
    public int state;
    public string errDesc;
    public CloudMixerOutputInfo()
    {
        state = 0;
    }
}

public class MeetingPage
{
    private CRVSDKMain g_sdkMain;

    private string mMyUserId;
    private int mMeetingId = 0;

    private List<sdkUserVideoID> mWatchList = new List<sdkUserVideoID>();
    private List<VideoUI> mVideoUIs = new List<VideoUI>();

    private GameObject mAudioSetPanel = null;
    private Dropdown mDDMicSet = null;
    private Dropdown mDDSpeakerSet = null;
    private Slider mMicVol = null;
    private Slider mSpkVol = null;
    private GameObject mVideoSetPanel = null;
    private Dropdown mDDCameraSet = null;
    private Dropdown mDDResolutionSet = null;
    private Dropdown mDDFpsSet = null;
    private GameObject mLocRecPanel = null;
    private InputField mIFLocRecPath = null;
    private Dropdown mDDLocRecRes = null;
    private Dropdown mDDLocRecFmt = null;
    private Button mStartLocRec = null;
    private Button mStopLocRec = null;
    private Text mLocRecInfo = null;
    private GameObject mSvrRecPanel = null;
    private Dropdown mDDSvrRecRes = null;
    private Dropdown mDDSvrRecFmt = null;
    private Button mStartSvrRec = null;
    private Button mStopSvrRec = null;
    private Text mSvrRecInfo = null;

    private static List<RecordParams> sRecordParams = new List<RecordParams>
    {
        new RecordParams(640, 360,	15,	350 * 1000,	 18, 15*15),	//标清
        new RecordParams(848, 480,	15,	500 * 1000,	 18, 15*15),	//高清
        new RecordParams(1280,720,	15,	1000 * 1000, 18, 15*15)	    //超清
    };

    //Local Record ID
    private string  TEST_LocRec_ID = "loc_record";
    //For Record
    private int VIDEO_WALL_SPACE = 2;
    private string mLocRecPath = null;
    private string mLocRecordFile;
    private int mLocRecWidth = 0;
    private int mLocRecHeight = 0;
    private string mSvrMixerID;
    private int mSvrRecWidth = 0;
    private int mSvrRecHeight = 0;

    private sdkLoginDat mLoginData = new sdkLoginDat();
    private string mIniFile = null;
    public string AppIniFile
    {
        get
        {
            return mIniFile;
        }
    }

    enum UISTATE
    {
        NOTLOGIN,
        LOGINING,
        LOGINSUCCESS,
        ENTERMEETING,
        INMEETING,
    }
    private UISTATE mState = UISTATE.NOTLOGIN;

    #region Callbacks
    private void loginRslt(CRVSDK_ERR_DEF sdkErr, string cookie)
    {
        if (sdkErr != CRVSDK_ERR_DEF.CRVSDKERR_NOERR)
        {
            BackToNotLogin("Login failed, sdkErr: " + sdkErr.ToString());
            return;
        }
        mState = UISTATE.LOGINSUCCESS;

        if (0 == mMeetingId)
        {
            g_sdkMain.createMeeting();
        }
        else
        {
            mState = UISTATE.ENTERMEETING;
            g_sdkMain.getSDKMeeting().enterMeeting(mMeetingId);
        }
    }
    private void notifyLineOff(CRVSDK_ERR_DEF sdkErr)
    {
        ClearVideoUI();
        if (SceneManager.GetActiveScene().name == "MeetingScene")
        {
            SceneManager.sceneLoaded += OnLoadSceneFinished;
            SceneManager.LoadScene("LoginScene", LoadSceneMode.Single);
        }
        BackToNotLogin("notify line off, error: " + sdkErr);
    }
    private void createMeetingSuccess(int meetId, string cookie)
    {
        mMeetingId = meetId;
        GameObject ifGo = GameObject.Find("ifMeetingID");
        ifGo.GetComponent<InputField>().text = mMeetingId.ToString();
        mState = UISTATE.ENTERMEETING;
        g_sdkMain.getSDKMeeting().enterMeeting(mMeetingId);
    }
    private void createMeetingFail(CRVSDK_ERR_DEF sdkErr, string cookie)
    {
        Debug.Log("create meeting fail, error: " + sdkErr);
        BackToNotLogin("Create meeting failed, sdkErr: " + sdkErr.ToString());
    }
    private void destroyMeetingRslt(CRVSDK_ERR_DEF sdkErr, string cookie)
    {
        Debug.Log("destroy meeting rslt: " + sdkErr);
    }

    private void enterMeetingRslt(CRVSDK_ERR_DEF sdkErr)
    {
        if (CRVSDK_ERR_DEF.CRVSDKERR_NOERR != sdkErr)
        {
            BackToNotLogin("Enter meeting failed, sdkErr: " + sdkErr.ToString());
            return;
        }

        INIParser parser = new INIParser();
        parser.Open(mIniFile);
        parser.WriteValue("UserCfg", "lastRoomId", mMeetingId.ToString());
        parser.Close();

        mState = UISTATE.INMEETING;
        SceneManager.sceneLoaded += OnLoadSceneFinished;
        SceneManager.LoadScene("MeetingScene", LoadSceneMode.Single);
    }

    private void notifyMeetingStopped()
    {
        ClearVideoUI();
        SceneManager.sceneLoaded += OnLoadSceneFinished;
        SceneManager.LoadScene("LoginScene", LoadSceneMode.Single);
        BackToNotLogin("Meeting has stopped");
    }

    private void notifyUserEnterMeeting(string userId)
    {
        sdkUserVideoID uInfo = new sdkUserVideoID(userId);
        VideoUI vUI = FindFreeVideoUI();
        if (null != vUI)
        {
            vUI.UserInfo = uInfo;
            sdkMeetingMember mem = g_sdkMain.getSDKMeeting().getMemberInfo(userId);
            if (mem._videoStatus == CRVSDK_VSTATUS.CRVSDK_VST_OPEN)
            {
                vUI.SetEnableRender(true);
            }
        }

        if (!mWatchList.Contains(uInfo))
        {
            mWatchList.Add(uInfo);
            UpdateWatchVideos();
        }
        OnTimeUpdateLocRecContent();
        OnTimeUpdateSvrRecContent();
    }

    private void notifyUserLeftMeeting(string userId)
    {
        sdkUserVideoID uInfo = new sdkUserVideoID(userId);

        VideoUI vUI = FindVideoUI(uInfo);
        if (null != vUI)
        {
            vUI.SetEnableRender(false);
            vUI.ClearUserInfo();
        }

        if (mWatchList.Contains(uInfo))
        {
            mWatchList.Remove(uInfo);
            UpdateWatchVideos();
        }
        OnTimeUpdateLocRecContent();
        OnTimeUpdateSvrRecContent();
    }

    private void notifyMicStatusChanged(string userID, CRVSDK_ASTATUS oldStatus, CRVSDK_ASTATUS newStatus, string oprUserID)
    {
        Debug.Log("notify user: " + userID + " mic status change from " + oldStatus + " to " + newStatus);
    }

    private void notifyVideoStatusChanged(string userID, CRVSDK_VSTATUS oldStatus, CRVSDK_VSTATUS newStatus, string oprUserID)
    {
        sdkUserVideoID uInfo = new sdkUserVideoID(userID);
        VideoUI vUI = FindVideoUI(uInfo);
        if (null != vUI)
        {
            bool camOpen = (newStatus == CRVSDK_VSTATUS.CRVSDK_VST_OPEN);
            if (camOpen != vUI.IsEnableRender())
            {
                vUI.SetEnableRender(camOpen);
            }
        }
        OnTimeUpdateLocRecContent();
        OnTimeUpdateSvrRecContent();
    }

    private void notifyLocMixerStateChanged(string mixerID, CRVSDK_MIXER_STATE state)
    {
        if (mixerID != TEST_LocRec_ID)
            return;
        if (null == mLocRecPanel || !mLocRecPanel.activeSelf)
            return;

        UpdateLocRecUI();
    }

    private void notifyLocMixerOutputInfo(string mixerID, string nameOrUrl, string outputInfo)
    {
        if (mixerID != TEST_LocRec_ID)
            return;
        if (null == mLocRecPanel || !mLocRecPanel.activeSelf)
            return;

        MixerOutputInfo oInfo = JsonUtility.FromJson<MixerOutputInfo>(outputInfo);
        if (oInfo.state == 2)
        {
            string strInfo = string.Format("Filename: {0}\nDuration: {1} Seconds\nSize: {2} Bytes", Path.GetFileName(nameOrUrl), oInfo.duration / 1000, oInfo.fileSize);
            mLocRecInfo.text = strInfo;
        }
        else if (oInfo.state == 3)
        {
            string strInfo = string.Format("Filename: {0}\nException: {1}", Path.GetFileName(nameOrUrl), oInfo.errCode);
            mLocRecInfo.text = strInfo;
        }
    }

    private void createCloudMixerFailed(string mixerID, CRVSDK_ERR_DEF sdkErr)
    {
        if (mSvrMixerID != mixerID)
            return;
        if (null == mSvrRecPanel || !mSvrRecPanel.activeSelf)
            return;

        UpdateSvrRecUI();
        if (sdkErr != CRVSDK_ERR_DEF.CRVSDKERR_NOERR)
        {
            string strInfo = "Create cloud mixer failed, err: " + sdkErr;
            mSvrRecInfo.text = strInfo;
            return;
        }
    }

    private void notifyCloudMixerStateChanged(string mixerID, CRVSDK_MIXER_STATE state, string exParam, string operUserID)
    {
        if (mSvrMixerID != mixerID)
            return;
        if (null == mSvrRecPanel || !mSvrRecPanel.activeSelf)
            return;

        UpdateSvrRecUI();
        if (state == CRVSDK_MIXER_STATE.CRVSDK_MIXER_NULL)
        {
            CloudMixerErr exParams = JsonUtility.FromJson<CloudMixerErr>(exParam);
            //录制异常
            if (null != exParams && exParams.err != 0)
            {
                string strInfo = "Record failed, errCode: " + exParams.err + ", errDesc：" + exParams.errDesc;
                mSvrRecInfo.text = strInfo;
                return;
            }
        }
    }

    private void notifyCloudMixerOutputInfoChanged(string mixerID, string jsonStr)
    {
        if (mSvrMixerID != mixerID)
            return;
        if (null == mSvrRecPanel || !mSvrRecPanel.activeSelf)
            return;

        //文件输出信息
        CloudMixerOutputInfo outputInfo = JsonUtility.FromJson<CloudMixerOutputInfo>(jsonStr);
        CRVSDK_CLOUDMIXER_OUTPUT_STATE fileState = (CRVSDK_CLOUDMIXER_OUTPUT_STATE)outputInfo.state;
        switch (fileState)
        {
        case CRVSDK_CLOUDMIXER_OUTPUT_STATE.CRVSDK_CLOUDMO_RUNNING:
        case CRVSDK_CLOUDMIXER_OUTPUT_STATE.CRVSDK_CLOUDMO_STOPPED:
            break;
        case CRVSDK_CLOUDMIXER_OUTPUT_STATE.CRVSDK_CLOUDMO_FAIL:
            {
                string strInfo = "Cloud record failed: " + outputInfo.errDesc;	
                mSvrRecInfo.text = strInfo;
            }
            break;
        case CRVSDK_CLOUDMIXER_OUTPUT_STATE.CRVSDK_CLOUDMO_UPLOADING:
            break;
        case CRVSDK_CLOUDMIXER_OUTPUT_STATE.CRVSDK_CLOUDMO_UPLOADED:
            //上传完成
            {
                INIParser parser = new INIParser();
                parser.Open(mIniFile);
                int httpType = parser.ReadValue("UserCfg", "httpType", 0);
                string server = parser.ReadValue("UserCfg", "server", "");
                parser.Close();
                string protocol = (httpType == (int)CRVSDK_WEBPROTOCOL.CRVSDK_WEBPTC_HTTP) ? "http://" : "https://";
                string recUrl = protocol + server + "/mgr/sdk/";
                mSvrRecInfo.text = recUrl;
            }
            break;
        case CRVSDK_CLOUDMIXER_OUTPUT_STATE.CRVSDK_CLOUDMO_UPLOADFAIL:
            {
                string strInfo = "Upload file failed: " + outputInfo.errDesc;	
                mSvrRecInfo.text = strInfo;
            }
            break;
        default:
            break;
        }
    }
    #endregion

    private void InitCallback()
    {
        if (null == g_sdkMain)
            return;

        g_sdkMain.onLoginRslt = loginRslt;
        g_sdkMain.notifyLineOff = notifyLineOff;
        g_sdkMain.onCreateMeetingSuccess = createMeetingSuccess;
        g_sdkMain.onCreateMeetingFail = createMeetingFail;
        g_sdkMain.onDestroyMeetingRslt = destroyMeetingRslt;
        g_sdkMain.getSDKMeeting().onEnterMeetingRslt = enterMeetingRslt;
        g_sdkMain.getSDKMeeting().notifyMeetingStopped = notifyMeetingStopped;
        g_sdkMain.getSDKMeeting().notifyUserEnterMeeting = notifyUserEnterMeeting;
        g_sdkMain.getSDKMeeting().notifyUserLeftMeeting = notifyUserLeftMeeting;
        g_sdkMain.getSDKMeeting().notifyMicStatusChanged = notifyMicStatusChanged;
        g_sdkMain.getSDKMeeting().notifyVideoStatusChanged = notifyVideoStatusChanged;
        g_sdkMain.getSDKMeeting().notifyLocMixerStateChanged = notifyLocMixerStateChanged;
        g_sdkMain.getSDKMeeting().notifyLocMixerOutputInfo = notifyLocMixerOutputInfo;
        g_sdkMain.getSDKMeeting().onCreateCloudMixerFailed = createCloudMixerFailed;
        g_sdkMain.getSDKMeeting().notifyCloudMixerStateChanged = notifyCloudMixerStateChanged;
        g_sdkMain.getSDKMeeting().notifyCloudMixerOutputInfoChanged = notifyCloudMixerOutputInfoChanged;
    }

    private LoginPage mLoginPage;
    public MeetingPage(LoginPage loginPage)
    {
        mLoginPage = loginPage;
    }

    public void init()
    {
        if (null != g_sdkMain)
        {
            Debug.Log("CRVSDKMain already exist!");
            return;
        }

        string sdkAppPath = System.Environment.CurrentDirectory;
        g_sdkMain = CRVSDKMain.create(sdkAppPath);
        if (null == g_sdkMain)
        {
            Debug.Log("Create SDK failed");
#if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
#else
            Application.Quit();
#endif
        }

        if (null == mIniFile)
        {
            mIniFile = Path.Combine(System.Environment.CurrentDirectory, "APIDemo.ini");
        }
        if (null == mLocRecPath)
        {
            mLocRecPath = Path.Combine(System.Environment.CurrentDirectory, "record");
        }

        ResetLoginData();
        ReadLoginData();
        InitCallback();
    }

    public void uninit()
    {
        if (null != g_sdkMain)
        {
            g_sdkMain.uninitSDK();
            g_sdkMain = null;
        }
    }

    public void UpdateLoginData(sdkLoginDat loginDat)
    {
        mLoginData = loginDat;
        WriteLoginData();
    }

    private void ReadLoginData()
    {
        INIParser parser = new INIParser();
        parser.Open(mIniFile);
        mLoginData._serverAddr = parser.ReadValue("UserCfg", "server", mLoginData._serverAddr);
        mLoginData._webProtocol = (CRVSDK_WEBPROTOCOL)parser.ReadValue("UserCfg", "httpType", (int)mLoginData._webProtocol);
        mLoginData._sdkAuthType = (CRVSDK_AUTHTYPE)parser.ReadValue("UserCfg", "authType", (int)mLoginData._sdkAuthType);
        mLoginData._appID = parser.ReadValue("UserCfg", "crAcnt", mLoginData._appID);
        mLoginData._md5_appSecret = parser.ReadValue("UserCfg", "crPswd", mLoginData._md5_appSecret);
        mLoginData._token = parser.ReadValue("UserCfg", "token", mLoginData._token);
        parser.Close();
    }

    public void WriteLoginData()
    {
        INIParser parser = new INIParser();
        parser.Open(mIniFile);
        parser.WriteValue("UserCfg", "server", mLoginData._serverAddr);
        parser.WriteValue("UserCfg", "httpType", (int)mLoginData._webProtocol);
        parser.WriteValue("UserCfg", "authType", (int)mLoginData._sdkAuthType);
        parser.WriteValue("UserCfg", "crAcnt", mLoginData._appID);
        parser.WriteValue("UserCfg", "crPswd", mLoginData._md5_appSecret);
        parser.WriteValue("UserCfg", "token", mLoginData._token);
        parser.Close();
    }

    public void ResetLoginData()
    {
        mLoginData._serverAddr = "sdk.cloudroom.com";
        mLoginData._webProtocol = CRVSDK_WEBPROTOCOL.CRVSDK_WEBPTC_HTTP;
        mLoginData._sdkAuthType = CRVSDK_AUTHTYPE.CRVSDK_AUTHTP_SECRET;
        mLoginData._appID = "";
        mLoginData._md5_appSecret = "";
        mLoginData._token = "";
    }

    public sdkLoginDat GetLoginData()
    {
        return mLoginData;
    }

    public void LoginAndJoinMeeting(string userId, int meetId)
    {
        if (mState != UISTATE.NOTLOGIN)
            return;

        mMyUserId = userId;
        mMeetingId = meetId;
        mState = UISTATE.LOGINING;

        sdkLoginDat tmpData = new sdkLoginDat();
        tmpData._appID = mLoginData._appID;
        tmpData._md5_appSecret = mLoginData._md5_appSecret;
        tmpData._sdkAuthType = mLoginData._sdkAuthType;
        tmpData._serverAddr = mLoginData._serverAddr;
        tmpData._token = mLoginData._token;
        tmpData._webProtocol = mLoginData._webProtocol;
        tmpData._userAuthCode = mLoginData._userAuthCode;
        if (tmpData._appID.Length == 0)
        {
            tmpData._appID = AccountInfo.TEST_AppID;
        }
        if (tmpData._md5_appSecret.Length == 0)
        {
            tmpData._md5_appSecret = CommonTools.MakeMd5(AccountInfo.TEST_AppScret);
        }
        tmpData._userID = userId;
        tmpData._nickName = userId;
        g_sdkMain.login(tmpData);
    }

    public void BackToNotLogin(string tips)
    {
        if (mState >= UISTATE.ENTERMEETING)
        {
            g_sdkMain.getSDKMeeting().exitMeeting();
        }
        if (mState >= UISTATE.LOGINING)
        {
            g_sdkMain.logout();
        }

        mState = UISTATE.NOTLOGIN;
        mLoginPage.SetButtonsEnable(true);
        if (tips.Length > 0)
            mLoginPage.ShowTipPanel(tips);
    }

    public VideoUI MakeVideoUI(string objName, int index)
    {
        GameObject go = new GameObject();
        if (go == null)
            return null;

        go.name = objName;

        go.AddComponent<RawImage>();
        GameObject canvas = GameObject.Find("MeetingCanvas");
        if (canvas != null)
        {
            go.transform.SetParent(canvas.transform);
        }

        int videoWidth = 360;
        int videoHeight = 198;
        Rect canvasRt = canvas.GetComponent<Canvas>().pixelRect;
        float xPos = 120 - canvasRt.width / 2f + videoWidth / 2f + index % 3 * 360;
        float yPos = canvasRt.height / 2f - videoHeight / 2f - index / 3 * 198;
        go.transform.localPosition = new Vector3(xPos, yPos, 0);
        go.transform.localScale = new Vector3(3.2f, 1.8f, 1f);

        VideoUI vUI = go.AddComponent<VideoUI>();
        vUI.SetSDKMain(g_sdkMain);
        vUI.SetEnableRender(false);
        return vUI;
    }

    private void ClearVideoUI()
    {
        foreach (var vUI in mVideoUIs)
        {
            vUI.SetEnableRender(false);
            UnityEngine.Object.Destroy(vUI, 0.2f);
        }
        mVideoUIs.Clear();
    }

    public VideoUI FindVideoUI(sdkUserVideoID uID)
    {
        foreach (var vUI in mVideoUIs)
        {
            sdkUserVideoID tmpID = vUI.UserInfo;
            if (tmpID._userID == uID._userID && tmpID._videoID == uID._videoID)
            {
                return vUI;
            }
        }

        return null;
    }

    public VideoUI FindFreeVideoUI()
    {
        foreach (var vUI in mVideoUIs)
        {
            sdkUserVideoID tmpID = vUI.UserInfo;
            if (tmpID._userID == null || tmpID._userID.Length == 0)
            {
                return vUI;
            }
        }
        return null;
    }

    private void HideAllVideoUI()
    {
        foreach (var obj in mVideoUIs)
        {
            obj.gameObject.SetActive(false);
        }
    }

    private void RestoreVideoUI()
    {
        foreach (var obj in mVideoUIs)
        {
            if (obj.IsEnableRender())
            {
                obj.gameObject.SetActive(true);
            }
        }
    }

    void OnLoadSceneFinished(Scene scene, LoadSceneMode mode)
    {
        if (scene.name == "MeetingScene")
        {
            mLoginPage.SetLoginPanelVisible(false);

            Text txtRoomId = GameObject.Find("txtRoomId").GetComponent<Text>();
            txtRoomId.text = "Meeting ID\n" + mMeetingId.ToString();

            Button btnExitMeet = GameObject.Find("ExitMeetingBtn").GetComponent<Button>();
            btnExitMeet.onClick.AddListener(OnExitMeetBtnClicked);
            Button btnMic = GameObject.Find("MicBtn").GetComponent<Button>();
            btnMic.onClick.AddListener(OnMicBtnClicked);
            Button btnCam = GameObject.Find("CameraBtn").GetComponent<Button>();
            btnCam.onClick.AddListener(OnCamBtnClicked);
            Button btnAudioSet = GameObject.Find("AudioSetBtn").GetComponent<Button>();
            btnAudioSet.onClick.AddListener(OnAudioSetClicked);
            Button btnExitAudioSet = GameObject.Find("ExitAudioSetBtn").GetComponent<Button>();
            btnExitAudioSet.onClick.AddListener(OnExitAudioSetClicked);
            Button btnVideoSet = GameObject.Find("VideoSetBtn").GetComponent<Button>();
            btnVideoSet.onClick.AddListener(OnVideoSetClicked);
            Button btnExitVideoSet = GameObject.Find("ExitVideoSetBtn").GetComponent<Button>();
            btnExitVideoSet.onClick.AddListener(OnExitVideoSetClicked);
            Button btnLocRec = GameObject.Find("LocRecordBtn").GetComponent<Button>();
            btnLocRec.onClick.AddListener(OnLocRecClicked);
            Button btnExitLocRec = GameObject.Find("ExitLocRecBtn").GetComponent<Button>();
            btnExitLocRec.onClick.AddListener(OnExitLocRecClicked);
            Button btnSvrRec = GameObject.Find("SvrRecordBtn").GetComponent<Button>();
            btnSvrRec.onClick.AddListener(OnSvrRecClicked);
            Button btnExitSvrRec = GameObject.Find("ExitSvrRecBtn").GetComponent<Button>();
            btnExitSvrRec.onClick.AddListener(OnExitSvrRecClicked);

            // audio set panel
            mAudioSetPanel = GameObject.Find("AudioSetPanel");
            mDDMicSet = GameObject.Find("ddMic").GetComponent<Dropdown>();
            mDDSpeakerSet = GameObject.Find("ddSpeaker").GetComponent<Dropdown>();
            mMicVol = GameObject.Find("sliderMic").GetComponent<Slider>();
            mMicVol.minValue = 0;
            mMicVol.maxValue = 255;
            mSpkVol = GameObject.Find("sliderSpk").GetComponent<Slider>();
            mSpkVol.minValue = 0;
            mSpkVol.maxValue = 255;
            mAudioSetPanel.SetActive(false);

            // video set panel
            mVideoSetPanel = GameObject.Find("VideoSetPanel");
            mDDCameraSet = GameObject.Find("ddCamera").GetComponent<Dropdown>();
            mDDResolutionSet = GameObject.Find("ddResolution").GetComponent<Dropdown>();
            mDDFpsSet = GameObject.Find("ddFps").GetComponent<Dropdown>();
            mVideoSetPanel.SetActive(false);

            // local record panel
            mLocRecPanel = GameObject.Find("LocRecordPanel");
            mIFLocRecPath = GameObject.Find("ifLocRecPath").GetComponent<InputField>();
            mDDLocRecRes = GameObject.Find("ddLocRecRes").GetComponent<Dropdown>();
            mDDLocRecRes.value = 2;
            mDDLocRecFmt = GameObject.Find("ddLocRecFmt").GetComponent<Dropdown>();
            mStartLocRec = GameObject.Find("StartLocRecBtn").GetComponent<Button>();
            mStartLocRec.onClick.AddListener(OnStartLocRecClicked);
            mStopLocRec = GameObject.Find("StopLocRecBtn").GetComponent<Button>();
            mStopLocRec.onClick.AddListener(OnStopLocRecClicked);
            mLocRecInfo = GameObject.Find("txtLocRecInfo").GetComponent<Text>();
            mLocRecPanel.SetActive(false);

            // server record panel
            mSvrRecPanel = GameObject.Find("SvrRecordPanel");
            mDDSvrRecRes = GameObject.Find("ddSvrRecRes").GetComponent<Dropdown>();
            mDDSvrRecRes.value = 2;
            mDDSvrRecFmt = GameObject.Find("ddSvrRecFmt").GetComponent<Dropdown>();
            mStartSvrRec = GameObject.Find("StartSvrRecBtn").GetComponent<Button>();
            mStartSvrRec.onClick.AddListener(OnStartSvrRecClicked);
            mStopSvrRec = GameObject.Find("StopSvrRecBtn").GetComponent<Button>();
            mStopSvrRec.onClick.AddListener(OnStopSvrRecClicked);
            mSvrRecInfo = GameObject.Find("txtSvrRecInfo").GetComponent<Text>();
            mSvrRecPanel.SetActive(false);

            for (int i = 0; i < 9; i++)
            {
                VideoUI vUI = MakeVideoUI("VideoUI_" + (i + 1).ToString(), i);
                if (!ReferenceEquals(vUI, null))
                {
                    mVideoUIs.Add(vUI);
                }
            }

            sdkUserVideoID uInfo = new sdkUserVideoID(mMyUserId);
            VideoUI myUI = FindFreeVideoUI();
            if (null != myUI)
            {
                myUI.UserInfo = uInfo;
            }

            g_sdkMain.getSDKMeeting().openMic(mMyUserId);
            g_sdkMain.getSDKMeeting().openVideo(mMyUserId);

            mWatchList.Clear();
            mWatchList.Add(uInfo);

            MeetingMemberList allMembers = g_sdkMain.getSDKMeeting().getAllMembers();
            for (var obj = allMembers.First; obj != null; )
            {
                sdkMeetingMember mem = obj.Value;
                if (mem._userId != mMyUserId)
                {
                    sdkUserVideoID otherID = new sdkUserVideoID(mem._userId);
                    mWatchList.Add(otherID);
                    VideoUI vUI = FindFreeVideoUI();
                    if (vUI != null)
                    {
                        vUI.UserInfo = otherID;
                        if (mem._videoStatus == CRVSDK_VSTATUS.CRVSDK_VST_OPEN)
                        {
                            vUI.SetEnableRender(true);
                        }
                    }
                }
                obj = obj.Next;
            }
            UpdateWatchVideos();
        }
        else if (scene.name == "LoginScene")
        {
            mLoginPage.SetLoginPanelVisible(true);
        }
        SceneManager.sceneLoaded -= OnLoadSceneFinished;
    }

    private void UpdateWatchVideos()
    {
        UserVideoIDList uList = new UserVideoIDList();
        for (int i = 0; i < mWatchList.Count; i++)
        {
            uList.Add(mWatchList[i]);
        }
        g_sdkMain.getSDKMeeting().setWatchVideos(uList);
    }

    void OnExitMeetBtnClicked()
    {
        ClearVideoUI();
        SceneManager.sceneLoaded += OnLoadSceneFinished;
        SceneManager.LoadScene("LoginScene", LoadSceneMode.Single);
        BackToNotLogin("");
    }

    void OnMicBtnClicked()
    {
        sdkMeetingMember memInfo = g_sdkMain.getSDKMeeting().getMemberInfo(mMyUserId);
        if (memInfo._audioStatus == CRVSDK_ASTATUS.CRVSDK_AST_OPEN)
        {
            g_sdkMain.getSDKMeeting().closeMic(mMyUserId);
        }
        else
        {
            g_sdkMain.getSDKMeeting().openMic(mMyUserId);
        }
    }

    void OnCamBtnClicked()
    {
        sdkMeetingMember memInfo = g_sdkMain.getSDKMeeting().getMemberInfo(mMyUserId);
        if (memInfo._videoStatus == CRVSDK_VSTATUS.CRVSDK_VST_OPEN)
        {
            g_sdkMain.getSDKMeeting().closeVideo(mMyUserId);
        }
        else
        {
            g_sdkMain.getSDKMeeting().openVideo(mMyUserId);
        }
    }

    void OnAudioSetClicked()
    {
        HideAllVideoUI();
        SetupAudioSetPanel();
        mAudioSetPanel.SetActive(true);
    }

    void SetupAudioSetPanel()
    {
        mDDMicSet.ClearOptions();
        List<string> micList = new List<string>();
        AudioDevInfoList micDevs = g_sdkMain.getSDKMeeting().getAudioMics();
        if (null != micDevs && micDevs.Count > 0)
        {
            micList.Add("System Default");
            foreach(var obj in micDevs)
            {
                micList.Add(obj._name + ":" + obj._id);
            }
        }
        mDDMicSet.AddOptions(micList);

        mDDSpeakerSet.ClearOptions();
        List<string> spkList = new List<string>();
        AudioDevInfoList spkDevs = g_sdkMain.getSDKMeeting().getAudioSpks();
        if (null != spkDevs && spkDevs.Count > 0)
        {
            spkList.Add("System Default");
            foreach(var obj in spkDevs)
            {
                spkList.Add(obj._name + ":" + obj._id);
            }
        }
        mDDSpeakerSet.AddOptions(spkList);

        sdkAudioCfg aCfg = g_sdkMain.getSDKMeeting().getAudioCfg();
        string curMic = aCfg._micGuid;
        if (curMic.Length > 0 && mDDMicSet.options.Count > 0)
        {
            int micIdx = 0;
            foreach (var obj in mDDMicSet.options)
            {
                if (obj.text.EndsWith(curMic))
                {
                    mDDMicSet.value = micIdx;
                    break;
                }
                micIdx++;
            }
        }
        string curSpk = aCfg._spkGuid;
        if (curSpk.Length > 0 && mDDSpeakerSet.options.Count > 0)
        {
            int spkIdx = 0;
            foreach (var obj in mDDSpeakerSet.options)
            {
                if (obj.text.EndsWith(curSpk))
                {
                    mDDSpeakerSet.value = spkIdx;
                    break;
                }
                spkIdx++;
            }
        }

        int micVol = g_sdkMain.getSDKMeeting().getMicVolume();
        int spkVol = g_sdkMain.getSDKMeeting().getSpkVolume();
        mMicVol.value = micVol;
        mSpkVol.value = spkVol;
    }

    void OnExitAudioSetClicked()
    {
        sdkAudioCfg aCfg = g_sdkMain.getSDKMeeting().getAudioCfg();
        if (mDDMicSet.options.Count > 0)
        {
            string micStr = mDDMicSet.options[mDDMicSet.value].text;
            if (micStr == "System Default")
            {
                aCfg._micGuid = "";
            }
            else
            {
                string[] splitStr = micStr.Split(":");
                if (splitStr.Length > 1)
                {
                    aCfg._micGuid = splitStr[splitStr.Length - 1];
                }
            }
        }
        else
        {
            aCfg._micGuid = "";
        }
        if (mDDSpeakerSet.options.Count > 0)
        {
            string spkStr = mDDSpeakerSet.options[mDDSpeakerSet.value].text;
            if (spkStr == "System Default")
            {
                aCfg._spkGuid = "";
            }
            else
            {
                string[] splitStr = spkStr.Split(":");
                if (splitStr.Length > 1)
                {
                    aCfg._spkGuid = splitStr[splitStr.Length - 1];
                }
            }
        }
        else
        {
            aCfg._spkGuid = "";
        }
        g_sdkMain.getSDKMeeting().setAudioCfg(aCfg);
        g_sdkMain.getSDKMeeting().setMicVolume((int)mMicVol.value);
        g_sdkMain.getSDKMeeting().setSpkVolume((int)mSpkVol.value);

        mAudioSetPanel.SetActive(false);
        RestoreVideoUI();
    }

    void OnVideoSetClicked()
    {
        HideAllVideoUI();
        SetupVideoSetPanel();
        mVideoSetPanel.SetActive(true);
    }

    void SetupVideoSetPanel()
    {
        mDDCameraSet.ClearOptions();
        List<string> videoOptions = new List<string>();
        VideoDevInfoList allVideos = g_sdkMain.getSDKMeeting().getAllVideoInfo(mMyUserId);
        int defCamId = g_sdkMain.getSDKMeeting().getDefaultVideo(mMyUserId);
        int camIdx = 0;
        int camSel = 0;
        if (allVideos.Count <= 0)
        {
            videoOptions.Add("Null");
        }
        else
        {
            foreach (var vInfo in allVideos)
            {
                videoOptions.Add(vInfo._devName + "_" + vInfo._videoID.ToString());
                if (defCamId == vInfo._videoID)
                {
                    camSel = camIdx;
                }
                camIdx++;
            }
        }
        mDDCameraSet.AddOptions(videoOptions);
        mDDCameraSet.value = camSel;

        string strVCfg = g_sdkMain.getSDKMeeting().getVideoCfg();
        VideoCfg vCfg = JsonUtility.FromJson<VideoCfg>(strVCfg);
        if (vCfg.fps >= 24) mDDFpsSet.value = 2;
        else if (vCfg.fps >= 15) mDDFpsSet.value = 1;
        else mDDFpsSet.value = 0;

        int findHeight = 360;
        string[] resolutionList = vCfg.size.Split('*');
        if (resolutionList.Length >= 2)
        {
            findHeight = Convert.ToInt32(resolutionList[1]);
        }
        if (findHeight >= 1080) mDDResolutionSet.value = 3;
        else if (findHeight >= 720) mDDResolutionSet.value = 2;
        else if (findHeight >= 480) mDDResolutionSet.value = 1;
        else mDDResolutionSet.value = 0;
    }

    void OnExitVideoSetClicked()
    {
        VideoCfg newCfg = new VideoCfg();
        newCfg.fps = Convert.ToInt32(mDDFpsSet.options[mDDFpsSet.value].text);

        int resVal = mDDResolutionSet.value;
        if (resVal == 0) newCfg.size = "640*360";
        else if (resVal == 1) newCfg.size = "856*480";
        else if (resVal == 2) newCfg.size = "1280*720";
        else if (resVal == 3) newCfg.size = "1920*1080";
        g_sdkMain.getSDKMeeting().setVideoCfg(JsonUtility.ToJson(newCfg));

        string camName = mDDCameraSet.options[mDDCameraSet.value].text;
        if ("Null" != camName)
        {
            string[] camInfo = camName.Split('_');
            if (camInfo.Length > 1)
            {
                int videoId = Convert.ToInt32(camInfo[camInfo.Length - 1]);
                g_sdkMain.getSDKMeeting().setDefaultVideo(videoId);
            }
        }

        mVideoSetPanel.SetActive(false);
        RestoreVideoUI();
    }

    void OnLocRecClicked()
    {
        HideAllVideoUI();

        INIParser parser = new INIParser();
        parser.Open(mIniFile);
        string defPath = parser.ReadValue("UserCfg", "recordPath", mLocRecPath);
        mIFLocRecPath.text = defPath;
        parser.Close();

        UpdateLocRecUI();

        mLocRecPanel.SetActive(true);
    }

    void UpdateLocRecUI()
    {
        CRVSDK_MIXER_STATE state = g_sdkMain.getSDKMeeting().getLocMixerState(TEST_LocRec_ID);
	    mStartLocRec.gameObject.SetActive(state != CRVSDK_MIXER_STATE.CRVSDK_MIXER_RUNNING);
	    mStopLocRec.gameObject.SetActive(state == CRVSDK_MIXER_STATE.CRVSDK_MIXER_RUNNING);
        mStartLocRec.interactable = !(state == CRVSDK_MIXER_STATE.CRVSDK_MIXER_STARTING || state == CRVSDK_MIXER_STATE.CRVSDK_MIXER_STOPPING);
        mStopLocRec.interactable = !(state == CRVSDK_MIXER_STATE.CRVSDK_MIXER_STARTING || state == CRVSDK_MIXER_STATE.CRVSDK_MIXER_STOPPING);
    }

    void OnExitLocRecClicked()
    {
        mLocRecPanel.SetActive(false);
        RestoreVideoUI();
    }

    void OnStartLocRecClicked()
    {
        mLocRecInfo.text = "";
        //录制配置
        RecordParams recParam = sRecordParams[mDDLocRecRes.value];
        string mixerCfg = JsonUtility.ToJson(recParam);

        //录制内容
        List<RecordContent> mixerContents = getRecordContents(recParam.width, recParam.height);
        string jsonList = JsonUtility.ToJson(new Serialization<RecordContent>(mixerContents));
        jsonList = jsonList.Substring(jsonList.IndexOf(':') + 1);
        jsonList = jsonList.Substring(0, jsonList.Length - 1);

        //创建混图器
        CRVSDK_ERR_DEF err = g_sdkMain.getSDKMeeting().createLocMixer(TEST_LocRec_ID, mixerCfg, jsonList);
        if (err != CRVSDK_ERR_DEF.CRVSDKERR_NOERR)
        {
            string strInfo = "start local record fail, err: " + err;
            mLocRecInfo.text = strInfo;
            return;
        }

        //录制输出
        DateTime dt = DateTime.Now;
        string recordFileBaseName = "LoginPage_" + mMeetingId.ToString() + string.Format("_{0:yyyy-MM-dd_hh-mm-ss}", dt);
        string suffix = mDDLocRecFmt.options[mDDLocRecFmt.value].text;
        mLocRecordFile = Path.Combine(mIFLocRecPath.text, recordFileBaseName) + "." + suffix;
        List<MixerOutputCfg> outCfgs = new List<MixerOutputCfg>();
        MixerOutputCfg moCfg = new MixerOutputCfg();
        moCfg.type = (int)CRVSDK_MIXER_OUTPUT_TYPE.CRVSDK_MIXER_OUTPUT_FILE;//录制文件
        moCfg.filename = mLocRecordFile;//文件名称
        outCfgs.Add(moCfg);
        string mixerOutput = JsonUtility.ToJson(new Serialization<MixerOutputCfg>(outCfgs));
        mixerOutput = mixerOutput.Substring(mixerOutput.IndexOf(':') + 1);
        mixerOutput = mixerOutput.Substring(0, mixerOutput.Length - 1);
        err = g_sdkMain.getSDKMeeting().addLocMixerOutput(TEST_LocRec_ID, mixerOutput);
        if (err != CRVSDK_ERR_DEF.CRVSDKERR_NOERR)
        {
            string strInfo = "update local record fail, err: " + err;
            mLocRecInfo.text = strInfo;
            g_sdkMain.getSDKMeeting().destroyLocMixer(TEST_LocRec_ID);
            return;
        }

        mLocRecWidth = recParam.width;
        mLocRecHeight = recParam.height;
    }

    private void OnTimeUpdateLocRecContent()
    {
        if (g_sdkMain.getSDKMeeting().getLocMixerState(TEST_LocRec_ID) == CRVSDK_MIXER_STATE.CRVSDK_MIXER_NULL)
            return;

        List<RecordContent> mixerContents = getRecordContents(mLocRecWidth, mLocRecHeight);
        string jsonList = JsonUtility.ToJson(new Serialization<RecordContent>(mixerContents));
        jsonList = jsonList.Substring(jsonList.IndexOf(':') + 1);
        jsonList = jsonList.Substring(0, jsonList.Length - 1);
        CRVSDK_ERR_DEF err = g_sdkMain.getSDKMeeting().updateLocMixerContent(TEST_LocRec_ID, jsonList);
        if (err != CRVSDK_ERR_DEF.CRVSDKERR_NOERR)
        {
            string strInfo = "Update local record content fail, err: " + err;
            mLocRecInfo.text = strInfo;
            return;
        }
    }

    void OnStopLocRecClicked()
    {
        if(g_sdkMain.getSDKMeeting().getLocMixerState(TEST_LocRec_ID) == CRVSDK_MIXER_STATE.CRVSDK_MIXER_NULL)
            return;

        g_sdkMain.getSDKMeeting().rmLocMixerOutput(TEST_LocRec_ID, mLocRecordFile);
        g_sdkMain.getSDKMeeting().destroyLocMixer(TEST_LocRec_ID);
    }

    void OnSvrRecClicked()
    {
        HideAllVideoUI();
        UpdateSvrRecUI();
        mSvrRecPanel.SetActive(true);
    }

    void UpdateSvrRecUI()
    {
        CRVSDK_MIXER_STATE state = getSvrRecordState();
        mStartSvrRec.gameObject.SetActive(state != CRVSDK_MIXER_STATE.CRVSDK_MIXER_RUNNING);
        mStopSvrRec.gameObject.SetActive(state == CRVSDK_MIXER_STATE.CRVSDK_MIXER_RUNNING);
        mStartSvrRec.interactable = !(state == CRVSDK_MIXER_STATE.CRVSDK_MIXER_STARTING || state == CRVSDK_MIXER_STATE.CRVSDK_MIXER_STOPPING);
        mStopSvrRec.interactable = !(state == CRVSDK_MIXER_STATE.CRVSDK_MIXER_STARTING || state == CRVSDK_MIXER_STATE.CRVSDK_MIXER_STOPPING);
    }

    private string getMyCloudMixerID()
    {
        string strJosnInfos = g_sdkMain.getSDKMeeting().getAllCloudMixerInfo();
        strJosnInfos = "{\"target\":" + strJosnInfos + "}";
        List<CloudMixerOwner> mixerList = JsonUtility.FromJson<Serialization<CloudMixerOwner>>(strJosnInfos).ToList();
        foreach(var obj in mixerList)
        {
            if(obj.owner == mMyUserId)
            {
                return obj.ID;
            }
        }

        return "";
    }


    private CRVSDK_MIXER_STATE getSvrRecordState()
    {
        CRVSDK_MIXER_STATE state = CRVSDK_MIXER_STATE.CRVSDK_MIXER_NULL;
        if (null != mSvrMixerID && mSvrMixerID.Length > 0)
        {
            string strJosnMixerInfo = g_sdkMain.getSDKMeeting().getCloudMixerInfo(mSvrMixerID);
            CloudMixerInfo mixerInfo = JsonUtility.FromJson<CloudMixerInfo>(strJosnMixerInfo);
            state = (CRVSDK_MIXER_STATE)mixerInfo.state;
            
            CloudMixerCfg cmc = JsonUtility.FromJson<CloudMixerCfg>(mixerInfo.cfg);
            VideoFileCfg vfc = cmc.videoFileCfg;
            mSvrRecWidth = vfc.vWidth;
            mSvrRecHeight = vfc.vHeight;
        }
        return state;
    }

    void OnStartSvrRecClicked()
    {
        mSvrRecInfo.text = "";
        RecordParams recParam = sRecordParams[mDDSvrRecRes.value];

        CloudMixerCfg mixerCfg = new CloudMixerCfg();
        mixerCfg.mode = 0;//合流模式
        DateTime dt = DateTime.Now;
        string recordFileBaseName = "LoginPage_" + mMeetingId.ToString() + string.Format("_{0:yyyy-MM-dd_hh-mm-ss}", dt);
        string suffix = mDDSvrRecFmt.options[mDDSvrRecFmt.value].text;
        string svrFilePath = string.Format("/{0}/{1}.{2}", dt.ToString("yyyy-MM-dd"), recordFileBaseName, suffix);
        VideoFileCfg vfc = new VideoFileCfg();
        vfc.svrPathName = svrFilePath;
        vfc.vWidth = recParam.width;//视频宽
        vfc.vHeight = recParam.height;//视频高
        vfc.mixedLayout = 1;//自定义布局
        vfc.layoutConfig = getRecordContents(recParam.width, recParam.height);//布局内容
        mixerCfg.videoFileCfg = vfc;

        string rsltMixerID = g_sdkMain.getSDKMeeting().createCloudMixer(JsonUtility.ToJson(mixerCfg));
        mSvrRecWidth = recParam.width;
        mSvrRecHeight = recParam.height;
        mSvrMixerID = rsltMixerID;
    }

    private void OnTimeUpdateSvrRecContent()
    {
        CRVSDK_MIXER_STATE state = getSvrRecordState();
        if (state < CRVSDK_MIXER_STATE.CRVSDK_MIXER_STARTING || state > CRVSDK_MIXER_STATE.CRVSDK_MIXER_PAUSED)
            return;

        CloudMixerCfg mixerCfg = new CloudMixerCfg();
        VideoFileCfg vfc = new VideoFileCfg();
        vfc.layoutConfig = getRecordContents(mSvrRecWidth, mSvrRecHeight);
        mixerCfg.videoFileCfg = vfc;
        string cfg = JsonUtility.ToJson(mixerCfg);
        CRVSDK_ERR_DEF err = g_sdkMain.getSDKMeeting().updateCloudMixerContent(mSvrMixerID, cfg);
        if (err != CRVSDK_ERR_DEF.CRVSDKERR_NOERR)
        {
            string strInfo = "Update cloud record content failed, err: " + err;
            mSvrRecInfo.text = strInfo;
            return;
        }
    }

    void OnStopSvrRecClicked()
    {
        g_sdkMain.getSDKMeeting().destroyCloudMixer(mSvrMixerID);
    }

    void OnExitSvrRecClicked()
    {
        mSvrRecPanel.SetActive(false);
        RestoreVideoUI();
    }

    private List<RecordContent> getRecordContents(int recWidth, int recHeight)
    {
        List<RecordContent> contents = new List<RecordContent>();
        int contentYPos = 0;

        //按9宫格摆视频来计算位置(以下计算中，位置宽高均为2的倍数，能避免混图之后间隙不均匀现象）
        int videoUIH = ((recHeight - 2 * VIDEO_WALL_SPACE) / 3);
        videoUIH = videoUIH / 2 * 2;
        int videoUIW = (int)(videoUIH * 16 / 9.0 + 0.5);
        videoUIW = videoUIW / 2 * 2;

        //视频墙
        for (int row = 0; row < 3; row++)
        {
            int contentXPos = 0;
            for (int col = 0; col < 3; col++)
            {
                VideoUI videoUI = mVideoUIs[row * 3 + col];
                sdkUserVideoID uID = videoUI.UserInfo;
                ContentParam cParam = new ContentParam();
                cParam.camid = uID._userID + "." + uID._videoID.ToString();

                RecordContent itemVideo = new RecordContent();
                itemVideo.type = (int)CRVSDK_MIXER_CONTENT_TYPE.CRVSDK_MIXCONT_VIDEO;
                itemVideo.left = contentXPos;
                itemVideo.top = contentYPos;
                itemVideo.width = videoUIW;
                itemVideo.height = videoUIH;
                itemVideo.param = cParam;
                itemVideo.keepAspectRatio = 1;
                contents.Add(itemVideo);

                contentXPos += videoUIW + VIDEO_WALL_SPACE;
            }
            contentYPos += videoUIH + VIDEO_WALL_SPACE;
        }

        return contents;
    }
}
