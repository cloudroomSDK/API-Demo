using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

[Serializable]
public class NetCamParams
{
    public int maxRetry;
    public NetCamParams() {
        maxRetry = 5;
    }
}

public class NetCameraPage : MonoBehaviour
{
    private CRVSDKMain g_sdkMain = null;

    private InputField mCamUrl = null;
    private Button mAddNetCamera = null;
    private Button mRemoveNetCamera = null;
    private VideoUI mVideoUI = null;
    private Text mNetCamInfo = null;

    static int sNetCamID = -1;
    static int sOldDefVideoID = -1;
    static string sNetCamUrl = "";

    void Awake()
    {
        g_sdkMain = MeetingPage.g_sdkMain;
        g_sdkMain.getSDKMeeting().onOpenVideoDevRslt += openVideoDevRslt;

        mCamUrl = GameObject.Find("ifNetCamUrl").GetComponent<InputField>();
        mAddNetCamera = GameObject.Find("AddNetCam").GetComponent<Button>();
        mAddNetCamera.onClick.AddListener(OnAddNetCameraClicked);
        mRemoveNetCamera = GameObject.Find("RemoveNetCam").GetComponent<Button>();
        mRemoveNetCamera.onClick.AddListener(OnRemoveNetCameraClicked);
        mNetCamInfo = GameObject.Find("txtNetCamInfo").GetComponent<Text>();
        GameObject go = GameObject.Find("RawImage");
        go.transform.localScale = new Vector3(3.2f, 1.8f, 1f);
        mVideoUI = go.AddComponent<VideoUI>();
        mVideoUI.SetSDKMain(g_sdkMain);

        init();
    }

    private void openVideoDevRslt(int videoID, bool isSucceed)
    {
        if (-1 == sNetCamID)
            return;

        if (!isSucceed)
        {
            OnRemoveNetCameraClicked();
            mNetCamInfo.text = "Open net camera failed";
        }
    }

    void init()
    {
        mCamUrl.text = sNetCamUrl;
        UpdateUI();
    }

    void UpdateUI()
    {
        bool hasNetCam = (sNetCamID != -1);
        mAddNetCamera.gameObject.SetActive(!hasNetCam);
        mRemoveNetCamera.gameObject.SetActive(hasNetCam);
        if (hasNetCam)
        {
            g_sdkMain.getSDKMeeting().openVideo(MeetingPage.mMyUserId);
            mVideoUI.UserInfo = new sdkUserVideoID(MeetingPage.mMyUserId, sNetCamID);
            mVideoUI.SetEnableRender(true);
        }
        else
        {
            mVideoUI.ClearUserInfo();
            mVideoUI.SetEnableRender(false);
            mVideoUI.gameObject.SetActive(true);
        }
    }

    public void OnAddNetCameraClicked()
    {
        NetCamParams ncParams = new NetCamParams();
        ncParams.maxRetry = 1;
        int rslt = g_sdkMain.getSDKMeeting().addIPCam(mCamUrl.text, JsonUtility.ToJson(ncParams));
        if (rslt < 0)
        {
            mNetCamInfo.text = "Add net camera failed, error: " + (CRVSDK_ERR_DEF)rslt;
            return;
        }
        sNetCamID = rslt;
        sNetCamUrl = mCamUrl.text;

        // switch to net camera and save old default camera
        sOldDefVideoID = g_sdkMain.getSDKMeeting().getDefaultVideo(MeetingPage.mMyUserId);
        g_sdkMain.getSDKMeeting().setDefaultVideo(sNetCamID);
        UpdateUI();
    }

    public void OnRemoveNetCameraClicked()
    {
        g_sdkMain.getSDKMeeting().delIPCam(sNetCamID);
        sNetCamID = -1;
        g_sdkMain.getSDKMeeting().setDefaultVideo(sOldDefVideoID);
        UpdateUI();
    }

    public void OnExitNetCameraClicked()
    {
        StartCoroutine(UnloadNetCameraScene());
    }

    public IEnumerator UnloadNetCameraScene()
    {
        AsyncOperation async = SceneManager.UnloadSceneAsync("NetCameraScene");
        yield return async;
    }
}
