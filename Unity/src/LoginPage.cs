using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;


public class LoginPage : MonoBehaviour
{
    static MeetingPage mApp = null;

    private Text mTips;
    private GameObject mSettingPanel;
    private GameObject mLoginPanel;
    private GameObject mTipPanel;
    private GameObject mIFAppID;
    private List<GameObject> mAppIDPanel = new List<GameObject>();
    private List<GameObject> mTokenPanel = new List<GameObject>();
    private List<Button> mMainBtns = new List<Button>();

    static LoginPage mInstance = null;
    void Awake()
    {
        if (null == mInstance)
        {
            mInstance = this;
            DontDestroyOnLoad(this);
            Application.runInBackground = true;
        }
        else
        {
            Destroy(this.gameObject);
            mInstance.gameObject.SetActive(true);
        }
    }

    // Start is called before the first frame update
    void Start()
    {
        if (null == mApp)
        {
            mApp = new MeetingPage(mInstance);
            mApp.init();
        }

        string strUserId = "UnityTest_" + UnityEngine.Random.Range(1000, 10000).ToString();
        GameObject ifGo = GameObject.Find("ifNickname");
        ifGo.GetComponent<InputField>().text = strUserId;

        INIParser parser = new INIParser();
        parser.Open(mApp.AppIniFile);
        string lastMeetId = parser.ReadValue("UserCfg", "lastRoomId", "");
        if (lastMeetId.Length > 0)
        {
            GameObject goMeetId = GameObject.Find("ifMeetingID");
            goMeetId.GetComponent<InputField>().text = lastMeetId;
        }
        parser.Close();

        GameObject tipGo = GameObject.Find("txtTips");
        mTips = tipGo.GetComponent<Text>();

        mSettingPanel = GameObject.Find("SettingPanel");
        mLoginPanel = GameObject.Find("LoginPanel");
        mTipPanel = GameObject.Find("TipPanel");

        mTokenPanel.Add(GameObject.Find("txtToken"));
        mTokenPanel.Add(GameObject.Find("ifToken"));
        mAppIDPanel.Add(GameObject.Find("txtAppID"));
        mIFAppID = GameObject.Find("ifAppID");
        mAppIDPanel.Add(mIFAppID);
        mAppIDPanel.Add(GameObject.Find("txtPassword"));
        mAppIDPanel.Add(GameObject.Find("ifPassword"));

        mMainBtns.Add(GameObject.Find("CreateBtn").GetComponent<Button>());
        mMainBtns.Add(GameObject.Find("JoinBtn").GetComponent<Button>());
        mMainBtns.Add(GameObject.Find("SettingBtn").GetComponent<Button>());

        mSettingPanel.SetActive(false);
        mTipPanel.SetActive(false);
    }

    public void SetLoginPanelVisible(bool bVisible)
    {
        mLoginPanel.SetActive(bVisible);
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
            ShowTipPanel("Please input correct meeting id");
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
        mSettingPanel.SetActive(true);
        mLoginPanel.SetActive(false);
        SetupSettingPanel();
    }

    private void SetupSettingPanel()
    {
        sdkLoginDat loginDat = mApp.GetLoginData();
        InputField ifServer = GameObject.Find("ifServer").GetComponent<InputField>();
        ifServer.text = loginDat._serverAddr;
        string strAppId = loginDat._appID;
        if (strAppId.Length == 0)
        {
            strAppId = "Default_APPID";
        }
        InputField ifAppId = mIFAppID.GetComponent<InputField>();
        ifAppId.text = strAppId;
        Dropdown ddProtocol = GameObject.Find("ddProtocol").GetComponent<Dropdown>();
        ddProtocol.value = (int)loginDat._webProtocol;
        Dropdown ddAuthType = GameObject.Find("ddAuthType").GetComponent<Dropdown>();
        ddAuthType.value = (int)loginDat._sdkAuthType;

        OnAuthTypeChanged((int)loginDat._sdkAuthType);
        ddAuthType.onValueChanged.AddListener(OnAuthTypeChanged);
    }

    private void OnAuthTypeChanged(int index)
    {
        if (index == 0)
        {
            foreach (var go in mTokenPanel)
            {
                go.SetActive(true);
            }
            foreach (var go in mAppIDPanel)
            {
                go.SetActive(false);
            }
        }
        else
        {
            foreach (var go in mTokenPanel)
            {
                go.SetActive(false);
            }
            foreach (var go in mAppIDPanel)
            {
                go.SetActive(true);
            }
        }
    }

    public void OnCancelSetBtnClicked()
    {
        mSettingPanel.SetActive(false);
        mLoginPanel.SetActive(true);
    }

    public void OnResetSetBtnClicked()
    {
        mApp.ResetLoginData();
        mApp.WriteLoginData();
        SetupSettingPanel();
    }

    public void OnSaveSetBtnClicked()
    {
        sdkLoginDat loginDat = new sdkLoginDat();
        InputField ifServer = GameObject.Find("ifServer").GetComponent<InputField>();
        loginDat._serverAddr = ifServer.text;
        Dropdown ddProtocol = GameObject.Find("ddProtocol").GetComponent<Dropdown>();
        loginDat._webProtocol = (CRVSDK_WEBPROTOCOL)ddProtocol.value;
        Dropdown ddAuthType = GameObject.Find("ddAuthType").GetComponent<Dropdown>();
        loginDat._sdkAuthType = (CRVSDK_AUTHTYPE)ddAuthType.value;
        if (loginDat._sdkAuthType == CRVSDK_AUTHTYPE.CRVSDK_AUTHTP_SECRET)
        {
            InputField ifAppId = mIFAppID.GetComponent<InputField>();
            string strAppId = ifAppId.text;
            if (strAppId.Length > 0 && strAppId != "Default_APPID")
            {
                loginDat._appID = strAppId;
            }
            InputField ifPassword = GameObject.Find("ifPassword").GetComponent<InputField>();
            string strPswd = ifPassword.text;
            loginDat._md5_appSecret = CommonTools.MakeMd5(strPswd);
        }
        else
        {
            InputField ifToken = GameObject.Find("ifToken").GetComponent<InputField>();
            loginDat._token = ifToken.text;
        }
        mApp.UpdateLoginData(loginDat);
        mSettingPanel.SetActive(false);
        mLoginPanel.SetActive(true);
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
