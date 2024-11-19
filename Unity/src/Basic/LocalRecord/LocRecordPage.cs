using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;


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

public class LocRecordPage : MonoBehaviour
{
    private CRVSDKMain g_sdkMain = null;

    //Local Record ID
    public static string TEST_LocRec_ID = "loc_record";

    private string mLocRecPath = null;
    private string mLocRecordFile;
    public static int mLocRecWidth = 0;
    public static int mLocRecHeight = 0;

    private InputField mIFLocRecPath = null;
    private Dropdown mDDLocRecRes = null;
    private Dropdown mDDLocRecFmt = null;
    private Button mStartLocRec = null;
    private Button mStopLocRec = null;
    private Text mLocRecInfo = null;

    void Awake()
    {
        g_sdkMain = MeetingPage.g_sdkMain;

        g_sdkMain.getSDKMeeting().notifyLocMixerStateChanged = notifyLocMixerStateChanged;
        g_sdkMain.getSDKMeeting().notifyLocMixerOutputInfo = notifyLocMixerOutputInfo;

        mIFLocRecPath = GameObject.Find("ifLocRecPath").GetComponent<InputField>();
        mDDLocRecRes = GameObject.Find("ddLocRecRes").GetComponent<Dropdown>();
        mDDLocRecRes.value = 2;
        mDDLocRecFmt = GameObject.Find("ddLocRecFmt").GetComponent<Dropdown>();
        mStartLocRec = GameObject.Find("StartLocRecBtn").GetComponent<Button>();
        mStartLocRec.onClick.AddListener(OnStartLocRecClicked);
        mStopLocRec = GameObject.Find("StopLocRecBtn").GetComponent<Button>();
        mStopLocRec.onClick.AddListener(OnStopLocRecClicked);
        mLocRecInfo = GameObject.Find("txtLocRecInfo").GetComponent<Text>();

        if (null == mLocRecPath)
        {
            mLocRecPath = Path.Combine(System.Environment.CurrentDirectory, "record");
        }
        string defPath = CommonTools.ReadIniStr(MeetingPage.mIniFile, "UserCfg", "recordPath", mLocRecPath);
        mIFLocRecPath.text = defPath;

        UpdateLocRecUI();
    }

    void Start()
    {

    }

    private void notifyLocMixerStateChanged(string mixerID, CRVSDK_MIXER_STATE state)
    {
        if (mixerID != TEST_LocRec_ID)
            return;

        UpdateLocRecUI();
    }

    private void notifyLocMixerOutputInfo(string mixerID, string nameOrUrl, string outputInfo)
    {
        if (mixerID != TEST_LocRec_ID)
            return;

        MixerOutputInfo oInfo = JsonUtility.FromJson<MixerOutputInfo>(outputInfo);
        if (oInfo.state == 2)
        {
            string strInfo = string.Format("文件名：{0}\n时长：{1}秒\n大小：{2}字节", Path.GetFileName(nameOrUrl), oInfo.duration / 1000, oInfo.fileSize);
            mLocRecInfo.text = strInfo;
        }
        else if (oInfo.state == 3)
        {
            string strInfo = string.Format("文件名：{0}\n异常：{1}", Path.GetFileName(nameOrUrl), oInfo.errCode);
            mLocRecInfo.text = strInfo;
        }
    }

    public void OnExitLocRecordClicked()
    {
        StartCoroutine(UnloadLocRecordScene());
    }

    public IEnumerator UnloadLocRecordScene()
    {
        AsyncOperation async = SceneManager.UnloadSceneAsync("LocRecordScene");
        yield return async;
    }

    void OnStartLocRecClicked()
    {
        mLocRecInfo.text = "";
        //录制配置
        RecordParams recParam = MeetingPage.sRecordParams[mDDLocRecRes.value];
        string mixerCfg = JsonUtility.ToJson(recParam);

        //录制内容
        List<RecordContent> mixerContents = MeetingPage.getRecordContents(recParam.width, recParam.height);
        string jsonList = JsonUtility.ToJson(new Serialization<RecordContent>(mixerContents));
        jsonList = jsonList.Substring(jsonList.IndexOf(':') + 1);
        jsonList = jsonList.Substring(0, jsonList.Length - 1);

        //创建混图器
        CRVSDK_ERR_DEF err = g_sdkMain.getSDKMeeting().createLocMixer(TEST_LocRec_ID, mixerCfg, jsonList);
        if (err != CRVSDK_ERR_DEF.CRVSDKERR_NOERR)
        {
            string strInfo = "开始本地录制失败，错误：" + err;
            mLocRecInfo.text = strInfo;
            return;
        }

        //录制输出
        string recordFileBaseName = string.Format("{0:yyyy-MM-dd_HH-mm-ss}_Unity_{1}", DateTime.Now, MeetingPage.mMeetingId);
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
            string strInfo = "更新本地录制失败，错误：" + err;
            mLocRecInfo.text = strInfo;
            g_sdkMain.getSDKMeeting().destroyLocMixer(TEST_LocRec_ID);
            return;
        }

        mLocRecWidth = recParam.width;
        mLocRecHeight = recParam.height;
    }

    void OnStopLocRecClicked()
    {
        if(g_sdkMain.getSDKMeeting().getLocMixerState(TEST_LocRec_ID) == CRVSDK_MIXER_STATE.CRVSDK_MIXER_NULL)
            return;

        g_sdkMain.getSDKMeeting().rmLocMixerOutput(TEST_LocRec_ID, mLocRecordFile);
        g_sdkMain.getSDKMeeting().destroyLocMixer(TEST_LocRec_ID);
    }

    void UpdateLocRecUI()
    {
        CRVSDK_MIXER_STATE state = g_sdkMain.getSDKMeeting().getLocMixerState(TEST_LocRec_ID);
	    mStartLocRec.gameObject.SetActive(state != CRVSDK_MIXER_STATE.CRVSDK_MIXER_RUNNING);
	    mStopLocRec.gameObject.SetActive(state == CRVSDK_MIXER_STATE.CRVSDK_MIXER_RUNNING);
        mStartLocRec.interactable = !(state == CRVSDK_MIXER_STATE.CRVSDK_MIXER_STARTING || state == CRVSDK_MIXER_STATE.CRVSDK_MIXER_STOPPING);
        mStopLocRec.interactable = !(state == CRVSDK_MIXER_STATE.CRVSDK_MIXER_STARTING || state == CRVSDK_MIXER_STATE.CRVSDK_MIXER_STOPPING);
    }
}
