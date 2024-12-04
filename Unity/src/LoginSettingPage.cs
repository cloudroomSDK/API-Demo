using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class LoginSettingPage : MonoBehaviour
{
    private LoginPage mLoginPage;
    private GameObject mIFAppID;
    private List<GameObject> mAppIDPanel = new List<GameObject>();
    private List<GameObject> mTokenPanel = new List<GameObject>();

    void Awake()
    {
        GameObject go = GameObject.Find("MainControl");
        if (null != go)
        {
            mLoginPage = go.GetComponent<LoginPage>();
        }

        mTokenPanel.Add(GameObject.Find("txtToken"));
        mTokenPanel.Add(GameObject.Find("ifToken"));
        mAppIDPanel.Add(GameObject.Find("txtAppID"));
        mIFAppID = GameObject.Find("ifAppID");
        mAppIDPanel.Add(mIFAppID);
        mAppIDPanel.Add(GameObject.Find("txtPassword"));
        mAppIDPanel.Add(GameObject.Find("ifPassword"));

        SetupLoginSetting();
    }

    private void SetupLoginSetting()
    {
        sdkLoginDat loginDat = mLoginPage.GetLoginData();
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
        bool showTokenPanel = (index == 0);
        foreach (var go in mTokenPanel)
        {
            go.SetActive(showTokenPanel);
        }
        foreach (var go in mAppIDPanel)
        {
            go.SetActive(!showTokenPanel);
        }
    }

    public void OnCancelSetBtnClicked()
    {
        mLoginPage.OnBackLoginClicked();
    }

    public void OnResetSetBtnClicked()
    {
        mLoginPage.ResetLoginData();
        mLoginPage.WriteLoginData();
        SetupLoginSetting();
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
        mLoginPage.UpdateLoginData(loginDat);
        mLoginPage.OnBackLoginClicked();
    }
}
