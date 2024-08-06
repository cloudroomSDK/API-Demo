using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;


public class LoginPage : MonoBehaviour
{
    static MeetingPage mApp = null;

    private GameObject mEvtSys;

    private Text mTips;
    private GameObject mLoginPanel;
    private GameObject mTipPanel;
    private List<Button> mMainBtns = new List<Button>();

    private string mSceneName = "";
    public string mMeetSubScene = "";
    private sdkLoginDat mLoginData = new sdkLoginDat();

    void Awake()
    {
        Application.runInBackground = true;
    }

    // Start is called before the first frame update
    void Start()
    {
        if (null == mApp)
        {
            mApp = new MeetingPage(this);
            mApp.init();
        }

        mEvtSys = GameObject.Find("EventSystem");

        string strUserId = "UnityTest_" + UnityEngine.Random.Range(1000, 10000).ToString();
        GameObject ifGo = GameObject.Find("ifNickname");
        ifGo.GetComponent<InputField>().text = strUserId;

        string lastMeetId = CommonTools.ReadIniStr(MeetingPage.mIniFile, "UserCfg", "lastRoomId");
        if (lastMeetId.Length > 0)
        {
            GameObject goMeetId = GameObject.Find("ifMeetingID");
            goMeetId.GetComponent<InputField>().text = lastMeetId;
        }

        mTips = GameObject.Find("txtTips").GetComponent<Text>();
        mLoginPanel = GameObject.Find("LoginPanel");
        mTipPanel = GameObject.Find("TipPanel");

        mMainBtns.Add(GameObject.Find("CreateBtn").GetComponent<Button>());
        mMainBtns.Add(GameObject.Find("JoinBtn").GetComponent<Button>());
        mMainBtns.Add(GameObject.Find("SettingBtn").GetComponent<Button>());

        mTipPanel.SetActive(false);

        ResetLoginData();
        ReadLoginData();
    }

    public void UpdateLoginData(sdkLoginDat loginDat)
    {
        mLoginData = loginDat;
        WriteLoginData();
    }

    private void ReadLoginData()
    {
        INIParser parser = new INIParser();
        parser.Open(MeetingPage.mIniFile);
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
        parser.Open(MeetingPage.mIniFile);
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

    public void OnJoinScene(string sceneName)
    {
        mEvtSys.gameObject.SetActive(false);
        mLoginPanel.SetActive(false);
        mSceneName = sceneName;
    }

    public void OnBackLoginClicked()
    {
        StartCoroutine(UnloadMeetSubSceneAysnc());
        StartCoroutine(UnloadSceneAysnc());
    }

    public IEnumerator UnloadMeetSubSceneAysnc()
    {
        if (mMeetSubScene.Length > 0)
        {
            AsyncOperation async = SceneManager.UnloadSceneAsync(mMeetSubScene);
            yield return async;
            mMeetSubScene = "";
        }
    }

    public IEnumerator UnloadSceneAysnc()
    {
        if (mSceneName.Length > 0)
        {
            AsyncOperation async = SceneManager.UnloadSceneAsync(mSceneName);
            yield return async;
            mEvtSys.gameObject.SetActive(true);
            mLoginPanel.SetActive(true);
            mSceneName = "";
        }
    }

    public void SetButtonsEnable(bool bEnable)
    {
        foreach (var btn in mMainBtns)
        {
            btn.interactable = bEnable;
        }
    }

    public void ShowTipPanel(string tip)
    {
        mTips.text = tip;
        mTipPanel.SetActive(true);
    }

    public void OnJoinBtnClicked()
    {
        GameObject goMeetId = GameObject.Find("ifMeetingID");
        string strMeetId = goMeetId.GetComponent<InputField>().text;
        if (strMeetId.Length != 8)
        {
            ShowTipPanel("请输入正确的房间ID");
            return;
        }
        GameObject goUserId = GameObject.Find("ifNickname");
        string userId = goUserId.GetComponent<InputField>().text;

        mApp.LoginAndJoinMeeting(userId, Convert.ToInt32(strMeetId));
        SetButtonsEnable(false);
    }

    public void OnCreateBtnClicked()
    {
        GameObject goUserId = GameObject.Find("ifNickname");
        string userId = goUserId.GetComponent<InputField>().text;
        mApp.LoginAndJoinMeeting(userId, 0);
        SetButtonsEnable(false);
    }

    public void OnSettingBtnClicked()
    {
        mEvtSys.gameObject.SetActive(false);
        SceneManager.sceneLoaded += OnLoadSceneFinished;
        SceneManager.LoadScene("LoginSettingScene", LoadSceneMode.Additive);
    }

    void OnLoadSceneFinished(Scene scene, LoadSceneMode mode)
    {
        OnJoinScene(scene.name);
        SceneManager.sceneLoaded -= OnLoadSceneFinished;
    }

    public void OnTipOkBtnClicked()
    {
        mTips.text = "";
        mTipPanel.SetActive(false);
    }

    void OnApplicationQuit()
    {
        Debug.Log("LoginPage, OnApplicationQuit");
        if (null != mApp)
        {
            mApp.uninit();
        }
        mApp = null;
    }
}
