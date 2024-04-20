using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;


public class AudioSettingPage : MonoBehaviour
{
    private CRVSDKMain g_sdkMain = null;

    private Dropdown mDDMicSet = null;
    private Dropdown mDDSpeakerSet = null;
    private Slider mMicVol = null;
    private Slider mSpkVol = null;

    void Awake()
    {
        g_sdkMain = MeetingPage.g_sdkMain;

        mDDMicSet = GameObject.Find("ddMic").GetComponent<Dropdown>();
        mDDSpeakerSet = GameObject.Find("ddSpeaker").GetComponent<Dropdown>();
        mMicVol = GameObject.Find("sliderMic").GetComponent<Slider>();
        mMicVol.minValue = 0;
        mMicVol.maxValue = 255;
        mSpkVol = GameObject.Find("sliderSpk").GetComponent<Slider>();
        mSpkVol.minValue = 0;
        mSpkVol.maxValue = 255;

        SetupAudioSetPanel();
    }

    void Start()
    {

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

    public void OnExitAudioSetClicked()
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

        StartCoroutine(UnloadAudioSetScene());
    }

    public IEnumerator UnloadAudioSetScene()
    {
        AsyncOperation async = SceneManager.UnloadSceneAsync("AudioSettingScene");
        yield return async;
    }
}
