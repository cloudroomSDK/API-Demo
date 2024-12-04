using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;


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

public class SvrRecordPage : MonoBehaviour
{
    private CRVSDKMain g_sdkMain = null;

    private Dropdown mDDSvrRecRes = null;
    private Dropdown mDDSvrRecFmt = null;
    private Button mStartSvrRec = null;
    private Button mStopSvrRec = null;
    private Text mSvrRecInfo = null;

    public static string mSvrMixerID = "";
    public static int mSvrRecWidth = 0;
    public static int mSvrRecHeight = 0;

    void Awake()
    {
        g_sdkMain = MeetingPage.g_sdkMain;
        g_sdkMain.getSDKMeeting().onCreateCloudMixerFailed = createCloudMixerFailed;
        g_sdkMain.getSDKMeeting().notifyCloudMixerStateChanged = notifyCloudMixerStateChanged;
        g_sdkMain.getSDKMeeting().notifyCloudMixerOutputInfoChanged = notifyCloudMixerOutputInfoChanged;

        mDDSvrRecRes = GameObject.Find("ddSvrRecRes").GetComponent<Dropdown>();
        mDDSvrRecRes.value = 2;
        mDDSvrRecFmt = GameObject.Find("ddSvrRecFmt").GetComponent<Dropdown>();
        mStartSvrRec = GameObject.Find("StartSvrRecBtn").GetComponent<Button>();
        mStartSvrRec.onClick.AddListener(OnStartSvrRecClicked);
        mStopSvrRec = GameObject.Find("StopSvrRecBtn").GetComponent<Button>();
        mStopSvrRec.onClick.AddListener(OnStopSvrRecClicked);
        mSvrRecInfo = GameObject.Find("txtSvrRecInfo").GetComponent<Text>();

        UpdateSvrRecUI();
    }

    void Start()
    {

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
            if(obj.owner == MeetingPage.mMyUserId)
            {
                return obj.ID;
            }
        }

        return "";
    }


    public static  CRVSDK_MIXER_STATE getSvrRecordState()
    {
        CRVSDK_MIXER_STATE state = CRVSDK_MIXER_STATE.CRVSDK_MIXER_NULL;
        if (null != mSvrMixerID && mSvrMixerID.Length > 0)
        {
            string strJosnMixerInfo = MeetingPage.g_sdkMain.getSDKMeeting().getCloudMixerInfo(mSvrMixerID);
            CloudMixerInfo mixerInfo = JsonUtility.FromJson<CloudMixerInfo>(strJosnMixerInfo);
            state = (CRVSDK_MIXER_STATE)mixerInfo.state;
            
            CloudMixerCfg cmc = JsonUtility.FromJson<CloudMixerCfg>(mixerInfo.cfg);
            VideoFileCfg vfc = cmc.videoFileCfg;
            mSvrRecWidth = vfc.vWidth;
            mSvrRecHeight = vfc.vHeight;
        }
        return state;
    }

    private void createCloudMixerFailed(string mixerID, CRVSDK_ERR_DEF sdkErr)
    {
        if (mSvrMixerID != mixerID)
            return;

        UpdateSvrRecUI();
        if (sdkErr != CRVSDK_ERR_DEF.CRVSDKERR_NOERR)
        {
            string strInfo = "创建云端录制失败，错误：" + sdkErr;
            mSvrRecInfo.text = strInfo;
            return;
        }
    }

    private void notifyCloudMixerStateChanged(string mixerID, CRVSDK_MIXER_STATE state, string exParam, string operUserID)
    {
        if (mSvrMixerID != mixerID)
            return;

        UpdateSvrRecUI();
        if (state == CRVSDK_MIXER_STATE.CRVSDK_MIXER_NULL)
        {
            CloudMixerErr exParams = JsonUtility.FromJson<CloudMixerErr>(exParam);
            //录制异常
            if (null != exParams && exParams.err != 0)
            {
                string strInfo = "录制失败，错误：" + exParams.err + "，描述：" + exParams.errDesc;
                mSvrRecInfo.text = strInfo;
                return;
            }
        }
    }

    private void notifyCloudMixerOutputInfoChanged(string mixerID, string jsonStr)
    {
        if (mSvrMixerID != mixerID)
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
                string strInfo = "云端录制失败，错误：" + outputInfo.errDesc;	
                mSvrRecInfo.text = strInfo;
            }
            break;
        case CRVSDK_CLOUDMIXER_OUTPUT_STATE.CRVSDK_CLOUDMO_UPLOADING:
            break;
        case CRVSDK_CLOUDMIXER_OUTPUT_STATE.CRVSDK_CLOUDMO_UPLOADED:
            //上传完成
            {
                int httpType = CommonTools.ReadIniInt(MeetingPage.mIniFile, "UserCfg", "httpType");
                string server = CommonTools.ReadIniStr(MeetingPage.mIniFile, "UserCfg", "server");
                string protocol = (httpType == (int)CRVSDK_WEBPROTOCOL.CRVSDK_WEBPTC_HTTP) ? "http://" : "https://";
                string recUrl = protocol + server + "/mgr/sdk/";
                mSvrRecInfo.text = recUrl;
            }
            break;
        case CRVSDK_CLOUDMIXER_OUTPUT_STATE.CRVSDK_CLOUDMO_UPLOADFAIL:
            {
                string strInfo = "上传文件失败，错误：" + outputInfo.errDesc;	
                mSvrRecInfo.text = strInfo;
            }
            break;
        default:
            break;
        }
    }

    public void OnExitSvrRecordClicked()
    {
        StartCoroutine(UnloadSvrRecordScene());
    }

    public IEnumerator UnloadSvrRecordScene()
    {
        AsyncOperation async = SceneManager.UnloadSceneAsync("SvrRecordScene");
        yield return async;
    }

    void OnStartSvrRecClicked()
    {
        mSvrRecInfo.text = "";
        RecordParams recParam = MeetingPage.sRecordParams[mDDSvrRecRes.value];

        CloudMixerCfg mixerCfg = new CloudMixerCfg();
        mixerCfg.mode = 0;//合流模式
        DateTime dt = DateTime.Now;
        string recordFileBaseName = string.Format("{0:yyyy-MM-dd_HH-mm-ss}_Unity_{1}", dt, MeetingPage.mMeetingId);
        string suffix = mDDSvrRecFmt.options[mDDSvrRecFmt.value].text;
        string svrFilePath = string.Format("/{0}/{1}.{2}", dt.ToString("yyyy-MM-dd"), recordFileBaseName, suffix);
        VideoFileCfg vfc = new VideoFileCfg();
        vfc.svrPathName = svrFilePath;
        vfc.vWidth = recParam.width;//视频宽
        vfc.vHeight = recParam.height;//视频高
        vfc.mixedLayout = 1;//自定义布局
        vfc.layoutConfig = MeetingPage.getRecordContents(recParam.width, recParam.height);//布局内容
        mixerCfg.videoFileCfg = vfc;

        string rsltMixerID = g_sdkMain.getSDKMeeting().createCloudMixer(JsonUtility.ToJson(mixerCfg));
        mSvrRecWidth = recParam.width;
        mSvrRecHeight = recParam.height;
        mSvrMixerID = rsltMixerID;
    }

    void OnStopSvrRecClicked()
    {
        g_sdkMain.getSDKMeeting().destroyCloudMixer(mSvrMixerID);
    }
}
