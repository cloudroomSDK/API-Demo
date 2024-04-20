using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;


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

public class VideoSettingPage : MonoBehaviour
{
    private CRVSDKMain g_sdkMain = null;

    private Dropdown mDDCameraSet = null;
    private Dropdown mDDSecondCameraSet = null;
    private Dropdown mDDResolutionSet = null;
    private Dropdown mDDFpsSet = null;

    void Awake()
    {
        g_sdkMain = MeetingPage.g_sdkMain;

        mDDCameraSet = GameObject.Find("ddCamera").GetComponent<Dropdown>();
        mDDSecondCameraSet = GameObject.Find("ddSecondCam").GetComponent<Dropdown>();
        mDDResolutionSet = GameObject.Find("ddResolution").GetComponent<Dropdown>();
        mDDFpsSet = GameObject.Find("ddFps").GetComponent<Dropdown>();

        SetupVideoSetPanel();
    }

    void Start()
    {

    }

    void SetupVideoSetPanel()
    {
        mDDCameraSet.ClearOptions();
        mDDSecondCameraSet.ClearOptions();
        List<string> videoOptions = new List<string>();
        List<string> secondOptions = new List<string>();
        VideoDevInfoList allVideos = g_sdkMain.getSDKMeeting().getAllVideoInfo(MeetingPage.mMyUserId);
        int defCamId = g_sdkMain.getSDKMeeting().getDefaultVideo(MeetingPage.mMyUserId);
        int multiCam = -1;
        List<int> camList = g_sdkMain.getSDKMeeting().getMultiVideos(MeetingPage.mMyUserId);
        if (camList.Count > 0)
        {
            foreach (var vInfo in allVideos)
            multiCam = camList[0];
        }
        int camIdx = 0;
        int camSel = 0;
        int secondCamSel = 0;
        secondOptions.Add("None");
        if (allVideos.Count <= 0)
        {
            videoOptions.Add("Null");
        }
        else
        {
            foreach (var vInfo in allVideos)
            {
                string nameAndId = vInfo._devName + "_" + vInfo._videoID.ToString();
                videoOptions.Add(nameAndId);
                secondOptions.Add(nameAndId);
                if (defCamId == vInfo._videoID)
                {
                    camSel = camIdx;
                }
                if (multiCam == vInfo._videoID)
                {
                    secondCamSel = camIdx + 1;
                }
                camIdx++;
            }
        }
        mDDCameraSet.AddOptions(videoOptions);
        mDDCameraSet.value = camSel;
        mDDSecondCameraSet.AddOptions(secondOptions);
        mDDSecondCameraSet.value = secondCamSel;

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

    public void OnExitVideoSetClicked()
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

        int secondCamIdx = mDDSecondCameraSet.value;
        IntList moreVideos = new IntList();
        if (0 == secondCamIdx)
        {
            g_sdkMain.getSDKMeeting().setMultiVideos(moreVideos, 0);
        }
        else
        {
            string secondCamName = mDDSecondCameraSet.options[mDDSecondCameraSet.value].text;
            string[] secondCamInfo = secondCamName.Split('_');
            if (secondCamInfo.Length > 1)
            {
                int videoId = Convert.ToInt32(secondCamInfo[secondCamInfo.Length - 1]);
                moreVideos.Add(videoId);
                g_sdkMain.getSDKMeeting().setMultiVideos(moreVideos, 1);
            }
        }

        StartCoroutine(UnloadVideoSetScene());
    }

    public IEnumerator UnloadVideoSetScene()
    {
        AsyncOperation async = SceneManager.UnloadSceneAsync("VideoSettingScene");
        yield return async;
    }
}
