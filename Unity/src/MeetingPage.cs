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
public class VideoEffect
{
    public int degree;

    public VideoEffect()
    {
        degree = 0;
    }
}

[Serializable]
public class ScreenCamera
{
    public int monitorID;

    public ScreenCamera()
    {
        monitorID = 0;
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

public class MeetingPage
{
    public static CRVSDKMain g_sdkMain;

    public static string mMyUserId;
    public static int mMeetingId = 0;

    private List<sdkUserVideoID> mWatchList = new List<sdkUserVideoID>();
    private static List<VideoUI> mVideoUIs = new List<VideoUI>();
    private static bool mInMediaPlay = false;
    private static bool mInScreenShare = false;

    private GameObject mEvtSys = null; 
    private GameObject mScrollView = null;
    private Button mBasicFuncBtn = null;
    private GameObject mBasicFuncGrp = null;
    private Button mAdvFuncBtn = null;
    private GameObject mAdvFuncGrp = null;

    private MediaPlayPage mMediaPlay = null;
    private ScreenSharePage mScreenShare = null;
    private GameObject mVideoWallGO = null;

    private GameObject mTextRawImage = null;

    public static List<RecordParams> sRecordParams = new List<RecordParams>
    {
        new RecordParams(640, 360,	15,	350 * 1000,	 18, 15*15),	//标清
        new RecordParams(848, 480,	15,	500 * 1000,	 18, 15*15),	//高清
        new RecordParams(1280,720,	15,	1000 * 1000, 18, 15*15)	    //超清
    };

    //For Record
    private static int VIDEO_WALL_SPACE = 2;
    public static string mIniFile = null;

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
            BackToNotLogin("登录失败，错误：" + sdkErr.ToString());
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
        BackToLoginScene("掉线，错误：" + sdkErr);
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
        BackToNotLogin("创建房间失败，错误：" + sdkErr.ToString());
    }

    private void enterMeetingRslt(CRVSDK_ERR_DEF sdkErr)
    {
        if (CRVSDK_ERR_DEF.CRVSDKERR_NOERR != sdkErr)
        {
            BackToNotLogin("进入房间失败，错误：" + sdkErr.ToString());
            return;
        }

        CommonTools.WriteIniStr(mIniFile, "UserCfg", "lastRoomId", mMeetingId.ToString());

        mState = UISTATE.INMEETING;
        SceneManager.sceneLoaded += OnLoadSceneFinished;
        SceneManager.LoadScene("MeetingScene", LoadSceneMode.Additive);
    }
    private void notifyMeetingStopped()
    {
        BackToLoginScene("会议已结束");
    }
    private void notifyMeetingDropped(CRVSDK_MEETING_DROPPED_REASON reason)
    {
        BackToLoginScene("已从会议掉线，原因：" + reason);
    }
    private void notifyUserEnterMeeting(string userId)
    {
        sdkMeetingMember mem = g_sdkMain.getSDKMeeting().getMemberInfo(userId);
        List<sdkUserVideoID> uInfos = getUserVideoIDs(userId);
        foreach (var uInfo in uInfos)
        {
            VideoUI vUI = FindVideoUI(uInfo);
            if (null == vUI)
            {
                vUI = FindFreeVideoUI();
            }
            if (null != vUI)
            {
                vUI.UserInfo = uInfo;
                vUI.SetEnableRender(mem._videoStatus == CRVSDK_VSTATUS.CRVSDK_VST_OPEN);
                vUI.SetVisible(mEvtSys.activeSelf);
            }
            if (!mWatchList.Contains(uInfo))
            {
                mWatchList.Add(uInfo);
            }
        }
        UpdateWatchVideos();

        OnTimeUpdateLocRecContent();
        OnTimeUpdateSvrRecContent();
    }
    private void notifyUserLeftMeeting(string userId)
    {
        foreach (var vUI in mVideoUIs)
        {
            if (vUI.UserInfo._userID == userId)
            {
                vUI.SetEnableRender(false);
                vUI.SetVisible(false, false);
                vUI.ClearUserInfo();
            }
        }
        foreach (var uInfo in mWatchList)
        {
            if (uInfo._userID == userId)
            {
                mWatchList.Remove(uInfo);
            }
        }
        UpdateWatchVideos();

        OnTimeUpdateLocRecContent();
        OnTimeUpdateSvrRecContent();
    }
    private void notifyMicStatusChanged(string userID, CRVSDK_ASTATUS oldStatus, CRVSDK_ASTATUS newStatus, string oprUserID)
    {
        bool micOpen = (newStatus == CRVSDK_ASTATUS.CRVSDK_AST_OPEN);
        foreach (var vUI in mVideoUIs)
        {
            if (vUI.UserInfo._userID != userID)
                continue;
            Button btnMic = vUI.transform.Find("OperGrp/MicBtn").gameObject.GetComponent<Button>();
            btnMic.GetComponentInChildren<Text>().text = micOpen ? "音频 开" : "音频 关";
        }
    }
    private void notifyVideoDevChanged(string userID)
    {
        ResetVideoUI();

        OnTimeUpdateLocRecContent();
        OnTimeUpdateSvrRecContent();
    }
    private void notifyVideoStatusChanged(string userID, CRVSDK_VSTATUS oldStatus, CRVSDK_VSTATUS newStatus, string oprUserID)
    {
        bool camOpen = (newStatus == CRVSDK_VSTATUS.CRVSDK_VST_OPEN);
        sdkUserVideoID uInfo = new sdkUserVideoID(userID);
        foreach (var vUI in mVideoUIs)
        {
            if (vUI.UserInfo._userID != userID)
                continue;
            if (camOpen != vUI.IsEnableRender())
            {
                vUI.SetEnableRender(camOpen);
                vUI.SetVisible(mEvtSys.activeSelf, false);
            }
            Button btnCam = vUI.transform.Find("OperGrp/CamBtn").gameObject.GetComponent<Button>();
            btnCam.GetComponentInChildren<Text>().text = camOpen ? "视频 开" : "视频 关";
        }

        OnTimeUpdateLocRecContent();
        OnTimeUpdateSvrRecContent();
    }
    private void startScreenShareRslt(CRVSDK_ERR_DEF sdkErr)
    {
        if (sdkErr == CRVSDK_ERR_DEF.CRVSDKERR_NOERR)
        {
            notifyScreenShareStarted(mMyUserId);
        }
    }
    private void stopScreenShareRslt(CRVSDK_ERR_DEF sdkErr)
    {
        if (sdkErr == CRVSDK_ERR_DEF.CRVSDKERR_NOERR)
        {
            notifyScreenShareStopped(mMyUserId);
        }
    }
    private void notifyScreenShareStarted(string userID)
    {
        if (mEvtSys.activeSelf)
        {
            mScreenShare.gameObject.SetActive(true);
        }
        mScreenShare.OnScreenShareStarted(userID);
        mInScreenShare = true;
        ResetVideoUI();

        OnTimeUpdateLocRecContent();
        OnTimeUpdateSvrRecContent();
    }
    private void notifyScreenShareStopped(string oprUserID)
    {
        if (null != mScreenShare)
        {
            mScreenShare.gameObject.SetActive(false);
            mScreenShare.OnScreenShareStopped(oprUserID);
        }
        mInScreenShare = false;
        ResetVideoUI();

        OnTimeUpdateLocRecContent();
        OnTimeUpdateSvrRecContent();
    }
    private void notifyMediaOpened(int totalTime, int w, int h)
    {
        mMediaPlay.OnMediaOpened(totalTime, w, h);
    }
    private void notifyMediaStart(string userID)
    {
        if (mEvtSys.activeSelf)
        {
            mMediaPlay.gameObject.SetActive(true);
        }
        mMediaPlay.OnMediaStart(userID);
        mInMediaPlay = true;
        ResetVideoUI();

        OnTimeUpdateLocRecContent();
        OnTimeUpdateSvrRecContent();
    }
    private void notifyMediaStop(string userID, CRVSDK_MEDIA_STOPREASON reason)
    {
        if (null != mMediaPlay)
        {
            mMediaPlay.gameObject.SetActive(false);
            mMediaPlay.OnMediaStop(userID, reason);
        }
        mInMediaPlay = false;
        ResetVideoUI();

        OnTimeUpdateLocRecContent();
        OnTimeUpdateSvrRecContent();
    }
    private void notifyMediaPause(string userID, bool bPause)
    {
        mMediaPlay.OnMediaPause(userID, bPause);
    }
    #endregion

    private void InitCallback()
    {
        if (null == g_sdkMain)
            return;

        g_sdkMain.onLoginRslt += loginRslt;
        g_sdkMain.notifyLineOff += notifyLineOff;
        g_sdkMain.onCreateMeetingSuccess += createMeetingSuccess;
        g_sdkMain.onCreateMeetingFail += createMeetingFail;
        g_sdkMain.getSDKMeeting().onEnterMeetingRslt += enterMeetingRslt;
        g_sdkMain.getSDKMeeting().notifyMeetingStopped += notifyMeetingStopped;
        g_sdkMain.getSDKMeeting().notifyMeetingDropped += notifyMeetingDropped;
        g_sdkMain.getSDKMeeting().notifyUserEnterMeeting += notifyUserEnterMeeting;
        g_sdkMain.getSDKMeeting().notifyUserLeftMeeting += notifyUserLeftMeeting;
        g_sdkMain.getSDKMeeting().notifyMicStatusChanged += notifyMicStatusChanged;
        g_sdkMain.getSDKMeeting().notifyVideoDevChanged += notifyVideoDevChanged;
        g_sdkMain.getSDKMeeting().notifyVideoStatusChanged += notifyVideoStatusChanged;
        g_sdkMain.getSDKMeeting().onStartScreenShareRslt += startScreenShareRslt;
        g_sdkMain.getSDKMeeting().onStopScreenShareRslt += stopScreenShareRslt;
        g_sdkMain.getSDKMeeting().notifyScreenShareStarted += notifyScreenShareStarted;
        g_sdkMain.getSDKMeeting().notifyScreenShareStopped += notifyScreenShareStopped;
        g_sdkMain.getSDKMeeting().notifyMediaOpened += notifyMediaOpened;
        g_sdkMain.getSDKMeeting().notifyMediaStart += notifyMediaStart;
        g_sdkMain.getSDKMeeting().notifyMediaStop += notifyMediaStop;
        g_sdkMain.getSDKMeeting().notifyMediaPause += notifyMediaPause;
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

    public void LoginAndJoinMeeting(string userId, int meetId)
    {
        if (mState != UISTATE.NOTLOGIN)
            return;

        mMyUserId = userId;
        mMeetingId = meetId;
        mState = UISTATE.LOGINING;

        sdkLoginDat tmpData = new sdkLoginDat();
        sdkLoginDat loginDat = mLoginPage.GetLoginData();
        tmpData._appID = loginDat._appID;
        tmpData._md5_appSecret = loginDat._md5_appSecret;
        tmpData._sdkAuthType = loginDat._sdkAuthType;
        tmpData._serverAddr = loginDat._serverAddr;
        tmpData._token = loginDat._token;
        tmpData._webProtocol = loginDat._webProtocol;
        tmpData._userAuthCode = loginDat._userAuthCode;
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

    private void BackToNotLogin(string tips = "")
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
        {
            mLoginPage.ShowTipPanel(tips);
        }
    }

    private void BackToLoginScene(string tips = "")
    {
        ClearVideoUI();
        if (mLoginPage.mMeetSubScene.Length > 0)
        {
            SceneManager.sceneUnloaded -= OnSceneUnloaded;
        }
        mLoginPage.OnBackLoginClicked();
        BackToNotLogin(tips);
    }

    public VideoUI CreateVideoUI(string objName, int index)
    {
        GameObject go = UnityEngine.Object.Instantiate(mTextRawImage, mVideoWallGO.transform);
        if (go == null)
            return null;

        go.name = objName;
        Transform btnGrp = go.transform.Find("OperGrp");
        Button mirrorBtn = btnGrp.Find("MirrorBtn").GetComponent<Button>();
        mirrorBtn.onClick.AddListener(OnMirrorCamClicked);
        Button rotateBtn = btnGrp.Find("RotateBtn").GetComponent<Button>();
        rotateBtn.onClick.AddListener(OnRotateCamClicked);
        Button camBtn = btnGrp.Find("CamBtn").GetComponent<Button>();
        camBtn.onClick.AddListener(OnCamBtnClicked);
        Button micBtn = btnGrp.Find("MicBtn").GetComponent<Button>();
        micBtn.onClick.AddListener(OnMicBtnClicked);

        Rect canvasRt = mVideoWallGO.GetComponent<RectTransform>().rect;
        float xPos = 0 - canvasRt.width / 2f + index % 3 * 370;
        float yPos = canvasRt.height / 2f - index / 3 * 240;
        go.transform.localPosition = new Vector3(xPos, yPos, 0);
        RawImage rawImage = go.GetComponentInChildren<RawImage>();
        rawImage.transform.localScale = new Vector3(3.68f, 2.07f, 1f);
//         rawImage.transform.localScale = new Vector3(3.52f, 1.98f, 1f);

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

    private void ResetVideoUI()
    {
        mWatchList.Clear();

        int maxVideoCount = (mInScreenShare || mInMediaPlay) ? 3 : 9;
        // add myself first
        List<sdkUserVideoID> userIds = getUserVideoIDs(mMyUserId);
        // add others
        MeetingMemberList allMems = g_sdkMain.getSDKMeeting().getAllMembers();
        foreach (var obj in allMems)
        {
            if (userIds.Count > maxVideoCount)
                break;
            if (obj._userId == mMyUserId)
                continue;
            userIds.AddRange(getUserVideoIDs(obj._userId));
        }
        while (userIds.Count > maxVideoCount)
        {
            userIds.RemoveAt(userIds.Count - 1);
        }
        mWatchList.AddRange(userIds);
        UpdateWatchVideos();
        // add empty if not enough
        while (userIds.Count < maxVideoCount)
        {
            userIds.Add(new sdkUserVideoID(""));
        }

        int i = 0;
        for (; i < mVideoUIs.Count && i < userIds.Count; i++)
        {
            VideoUI vUI = mVideoUIs[i];
            vUI.UserInfo = userIds[i];
            Text txt = vUI.GetComponentInChildren<Text>();
            bool isMyVideo = (vUI.UserInfo._userID == mMyUserId);
            Button btnMirror = txt.transform.parent.Find("MirrorBtn").gameObject.GetComponent<Button>();
            Button btnRotate = txt.transform.parent.Find("RotateBtn").gameObject.GetComponent<Button>();
            Button btnCam = txt.transform.parent.Find("CamBtn").gameObject.GetComponent<Button>();
            Button btnMic = txt.transform.parent.Find("MicBtn").gameObject.GetComponent<Button>();
            btnMirror.gameObject.SetActive(isMyVideo);
            btnRotate.gameObject.SetActive(isMyVideo);
            btnCam.interactable = isMyVideo;
            btnMic.interactable = isMyVideo;
            if (userIds[i]._userID.Length > 0)
            {
                sdkMeetingMember mem = g_sdkMain.getSDKMeeting().getMemberInfo(userIds[i]._userID);
                txt.text = mem._nickName;
                bool micOpened = (mem._audioStatus == CRVSDK_ASTATUS.CRVSDK_AST_OPEN);
                btnMic.GetComponentInChildren<Text>().text = micOpened ? "音频 开" : "音频 关";
                bool camOpened = (mem._videoStatus == CRVSDK_VSTATUS.CRVSDK_VST_OPEN);
                btnCam.GetComponentInChildren<Text>().text = camOpened ? "视频 开" : "视频 关";
                vUI.SetEnableRender(camOpened);
                vUI.SetVisible(mEvtSys.activeSelf, false);
            }
            else
            {
                txt.text = "";
                vUI.SetEnableRender(false);
                vUI.SetVisible(false);
            }
        }

        for (; i < mVideoUIs.Count; i++)
        {
            VideoUI vUI = mVideoUIs[i];
            vUI.SetEnableRender(false);
            vUI.ClearUserInfo();
            vUI.SetVisible(false);
        }
    }

    private List<sdkUserVideoID> getUserVideoIDs(string userId)
    {
        List<sdkUserVideoID> idList = new List<sdkUserVideoID>();
        sdkUserVideoID mainId = new sdkUserVideoID(userId, g_sdkMain.getSDKMeeting().getDefaultVideo(userId));
        idList.Add(mainId);
        List<int> multiVideos = g_sdkMain.getSDKMeeting().getMultiVideos(userId);
        if (multiVideos.Count > 0)
        {
            sdkUserVideoID uId = new sdkUserVideoID(userId, multiVideos[0]);
            idList.Add(uId);
        }

        return idList;
    }

    public VideoUI FindVideoUI(sdkUserVideoID vID)
    {
        foreach (var vUI in mVideoUIs)
        {
            sdkUserVideoID tmpID = vUI.UserInfo;
            if (tmpID._userID == vID._userID && tmpID._videoID == vID._videoID)
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
        if (null != mMediaPlay && mMediaPlay.gameObject.activeSelf)
        {
            mMediaPlay.gameObject.SetActive(false);
        }
        if (null != mScreenShare && mScreenShare.gameObject.activeSelf)
        {
            mScreenShare.gameObject.SetActive(false);
        }
        foreach (var obj in mVideoUIs)
        {
            obj.SetVisible(false);
        }
    }

    private void RestoreVideoUI()
    {
        if (null != mMediaPlay && mInMediaPlay)
        {
            mMediaPlay.gameObject.SetActive(true);
        }
        if (null != mScreenShare && mInScreenShare)
        {
            mScreenShare.gameObject.SetActive(true);
        }
        foreach (var obj in mVideoUIs)
        {
            if (obj.UserInfo._userID.Length > 0)
            {
                obj.SetVisible(true);
            }
        }
    }

    private void InitGameObjs()
    {
        mEvtSys = GameObject.Find("EventSystem");
        mScrollView = GameObject.Find("Scroll View");
        mBasicFuncGrp = GameObject.Find("BasicFuncGrp");
        mAdvFuncGrp = GameObject.Find("AdvFuncGrp");
        mMediaPlay = GameObject.Find("MediaPlayGO").GetComponent<MediaPlayPage>();
        mMediaPlay.gameObject.SetActive(false);
        mScreenShare = GameObject.Find("ScreenShareGO").GetComponent<ScreenSharePage>();
        mScreenShare.gameObject.SetActive(false);
        mVideoWallGO = GameObject.Find("VideoWallGO");

        Text txtRoomId = GameObject.Find("txtRoomId").GetComponent<Text>();
        txtRoomId.text = "房间ID：\n" + mMeetingId.ToString();

        Button btnExitMeet = GameObject.Find("ExitRoomBtn").GetComponent<Button>();
        btnExitMeet.onClick.AddListener(OnExitRoomBtnClicked);
        mBasicFuncBtn = GameObject.Find("BasicFuncBtn").GetComponent<Button>();
        mBasicFuncBtn.onClick.AddListener(OnBasicFuncBtnClicked);
        mAdvFuncBtn = GameObject.Find("AdvFuncBtn").GetComponent<Button>();
        mAdvFuncBtn.onClick.AddListener(OnAdvFuncBtnClicked);
        string[] sceneBtns = { "AudioSetting", "VideoSetting", "LocRecord", "SvrRecord", "ScreenShareState", "MediaSelect", "RoomMsg", "RoomAttrs", "UserAttrs", "NetCamera", "VoiceChange", "EchoTest"};
        foreach (var btnName in sceneBtns)
        {
            Button sceneBtn = GameObject.Find(btnName).GetComponent<Button>();
            sceneBtn.onClick.AddListener(OnSceneBtnClicked);
        }

        mTextRawImage = Resources.Load<GameObject>("Prefab/TextRawImage");
        if (null == mTextRawImage)
        {
            Debug.Log("load TextRawImage failed");
        }
    }

    void OnLoadSceneFinished(Scene scene, LoadSceneMode mode)
    {
        if (scene.name == "MeetingScene")
        {
            mLoginPage.OnJoinScene(scene.name);

            InitGameObjs();

            // Display.displays.Length is always 1 in Editor
            int nScreen = Display.displays.Length;
            for (int i = 0; i < nScreen && i < 5; i++)
            {
                ScreenCamera sc = new ScreenCamera();
                sc.monitorID = i;
                string strScreen = JsonUtility.ToJson(sc);
                string camName = "自定义屏幕摄像头" + (i + 1);
                g_sdkMain.getSDKMeeting().createScreenCamDev(camName, strScreen);
            }

            for (int i = 0; i < 9; i++)
            {
                VideoUI vUI = CreateVideoUI("VideoUI_" + (i + 1).ToString(), i);
                if (!ReferenceEquals(vUI, null))
                {
                    mVideoUIs.Add(vUI);
                }
            }
            ResetVideoUI();

            g_sdkMain.getSDKMeeting().openMic(mMyUserId);
            g_sdkMain.getSDKMeeting().openVideo(mMyUserId);
        }
        SceneManager.sceneLoaded -= OnLoadSceneFinished;
    }

    private void UpdateWatchVideos()
    {
        UserVideoIDList uList = new UserVideoIDList();
        foreach(var vId in mWatchList)
        {
            uList.Add(vId);
        }
        g_sdkMain.getSDKMeeting().setWatchVideos(uList);
    }

    void OnExitRoomBtnClicked()
    {
        BackToLoginScene();
    }

    void OnBasicFuncBtnClicked()
    {
        Text btnTxt = mBasicFuncBtn.GetComponentInChildren<Text>();
        string strPrefix = "  > ";
        if (mBasicFuncGrp.activeSelf)
            strPrefix = "  ^ ";
        btnTxt.text = strPrefix + "基础功能";
        mBasicFuncGrp.SetActive(!mBasicFuncGrp.activeSelf);
    }

    void OnAdvFuncBtnClicked()
    {
        Text btnTxt = mAdvFuncBtn.GetComponentInChildren<Text>();
        string strPrefix = "  > ";
        if (mAdvFuncGrp.activeSelf)
            strPrefix = "  ^ ";
        btnTxt.text = strPrefix + "进阶功能";
        mAdvFuncGrp.SetActive(!mAdvFuncGrp.activeSelf);
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

    void OnMirrorCamClicked()
    {
        sdkMeetingMember memInfo = g_sdkMain.getSDKMeeting().getMemberInfo(mMyUserId);
        if (memInfo._videoStatus != CRVSDK_VSTATUS.CRVSDK_VST_OPEN)
            return;

        var button = UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject;
        GameObject parentObj = button.transform.parent.gameObject;
        if(null != parentObj)
        {
            if(!parentObj.name.StartsWith("VideoUI"))
            {
                parentObj = parentObj.transform.parent.gameObject;
            }
        }
        VideoUI vUI = parentObj.GetComponent<VideoUI>();
        if (null != vUI)
        {
            vUI.SetLocMirror(!vUI.GetLocMirror());
        }
    }

    void OnRotateCamClicked()
    {
        sdkMeetingMember memInfo = g_sdkMain.getSDKMeeting().getMemberInfo(mMyUserId);
        if (memInfo._videoStatus != CRVSDK_VSTATUS.CRVSDK_VST_OPEN)
            return;

        string videoEff = g_sdkMain.getSDKMeeting().getVideoEffects();
        VideoEffect vEff = JsonUtility.FromJson<VideoEffect>(videoEff);
        if(vEff.degree < 0)
        {
            vEff.degree = 0;
        }
        vEff.degree += 90;
        if(vEff.degree >= 360)
        {
            vEff.degree = 0;
        }

        g_sdkMain.getSDKMeeting().setVideoEffects(JsonUtility.ToJson(vEff));
    }

    void LoadSubScene(string sceneName)
    {
        HideAllVideoUI();
        mEvtSys.SetActive(false);
        mScrollView.SetActive(false);
        mLoginPage.mMeetSubScene = sceneName;
        SceneManager.sceneUnloaded += OnSceneUnloaded;
        SceneManager.LoadScene(sceneName, LoadSceneMode.Additive);
    }

    void OnSceneUnloaded(Scene scene)
    {
        if (scene.name != mLoginPage.mMeetSubScene)
            return;

        mEvtSys.SetActive(true);
        mScrollView.SetActive(true);
        mLoginPage.mMeetSubScene = "";
        RestoreVideoUI();
        SceneManager.sceneUnloaded -= OnSceneUnloaded;
    }

    void OnSceneBtnClicked()
    {
        var button = UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject;
        string sceneName = button.gameObject.name + "Scene";
        LoadSubScene(sceneName);
    }

    private void OnTimeUpdateLocRecContent()
    {
        if (g_sdkMain.getSDKMeeting().getLocMixerState(LocRecordPage.TEST_LocRec_ID) == CRVSDK_MIXER_STATE.CRVSDK_MIXER_NULL)
            return;

        List<RecordContent> mixerContents = MeetingPage.getRecordContents(LocRecordPage.mLocRecWidth, LocRecordPage.mLocRecHeight);
        string jsonList = JsonUtility.ToJson(new Serialization<RecordContent>(mixerContents));
        jsonList = jsonList.Substring(jsonList.IndexOf(':') + 1);
        jsonList = jsonList.Substring(0, jsonList.Length - 1);
        CRVSDK_ERR_DEF err = g_sdkMain.getSDKMeeting().updateLocMixerContent(LocRecordPage.TEST_LocRec_ID, jsonList);
        if (err != CRVSDK_ERR_DEF.CRVSDKERR_NOERR)
        {
            string strInfo = "更新本地录制内容失败，错误：" + err;
//             mLocRecInfo.text = strInfo;
            return;
        }
    }

    private void OnTimeUpdateSvrRecContent()
    {
        CRVSDK_MIXER_STATE state = SvrRecordPage.getSvrRecordState();
        if (state < CRVSDK_MIXER_STATE.CRVSDK_MIXER_STARTING || state > CRVSDK_MIXER_STATE.CRVSDK_MIXER_PAUSED)
            return;

        CloudMixerCfg mixerCfg = new CloudMixerCfg();
        VideoFileCfg vfc = new VideoFileCfg();
        vfc.layoutConfig = getRecordContents(SvrRecordPage.mSvrRecWidth, SvrRecordPage.mSvrRecHeight);
        mixerCfg.videoFileCfg = vfc;
        string cfg = JsonUtility.ToJson(mixerCfg);
        CRVSDK_ERR_DEF err = g_sdkMain.getSDKMeeting().updateCloudMixerContent(SvrRecordPage.mSvrMixerID, cfg);
        if (err != CRVSDK_ERR_DEF.CRVSDKERR_NOERR)
        {
            string strInfo = "更新云端录制内容失败，错误：" + err;
//             mSvrRecInfo.text = strInfo;
            return;
        }
    }

    public static List<RecordContent> getRecordContents(int recWidth, int recHeight)
    {
        List<RecordContent> contents = new List<RecordContent>();
        int contentYPos = 0;

        //按9宫格摆视频来计算位置(以下计算中，位置宽高均为2的倍数，能避免混图之后间隙不均匀现象）
        int videoUIH = ((recHeight - 2 * VIDEO_WALL_SPACE) / 3);
        videoUIH = videoUIH / 2 * 2;
        int videoUIW = (int)(videoUIH * 16 / 9.0 + 0.5);
        videoUIW = videoUIW / 2 * 2;

        //屏幕共享中
        if (mInScreenShare)
        {
            int screenH = recHeight - videoUIH - VIDEO_WALL_SPACE;
            RecordContent itemScreen = new RecordContent();
            itemScreen.type = (int)CRVSDK_MIXER_CONTENT_TYPE.CRVSDK_MIXCONT_SCREEN_SHARED;
            itemScreen.left = 0;
            itemScreen.top = contentYPos;
            itemScreen.width = recWidth;
            itemScreen.height = screenH;
            itemScreen.keepAspectRatio = 1;
            contents.Add(itemScreen);

            contentYPos += screenH + VIDEO_WALL_SPACE;
        }

        //影音共享中
        if (mInMediaPlay)
        {
            int mediaH = recHeight - videoUIH - VIDEO_WALL_SPACE;
            RecordContent itemMedia = new RecordContent();
            itemMedia.type = (int)CRVSDK_MIXER_CONTENT_TYPE.CRVSDK_MIXCONT_MEDIA;
            itemMedia.left = 0;
            itemMedia.top = contentYPos;
            itemMedia.width = recWidth;
            itemMedia.height = mediaH;
            itemMedia.keepAspectRatio = 1;
            contents.Add(itemMedia);

            contentYPos += mediaH + VIDEO_WALL_SPACE;
        }

        int rowCount = (mInMediaPlay || mInScreenShare) ? 1 : 3;
        //视频墙
        for (int row = 0; row < rowCount; row++)
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
