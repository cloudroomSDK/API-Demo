using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;


public class VoiceChangePage : MonoBehaviour
{
    private CRVSDKMain g_sdkMain = null;

//     private Text mVoiceChangeInfo = null;
    public GameObject mUserOptions;

    void Awake()
    {
        g_sdkMain = MeetingPage.g_sdkMain;
        g_sdkMain.getSDKMeeting().notifyUserEnterMeeting += notifyUserEnterMeeting;
        g_sdkMain.getSDKMeeting().notifyUserLeftMeeting += notifyUserLeftMeeting;
        g_sdkMain.getSDKMeeting().notifySetVoiceChange += notifySetVoiceChange;

//         mVoiceChangeInfo = GameObject.Find("txtVoiceChangeInfo").GetComponent<Text>();
        UpdateUserList();
    }

    private void notifyUserEnterMeeting(string userID)
    {
        UpdateUserList();
    }

    private void notifyUserLeftMeeting(string userID)
    {
        UpdateUserList();
    }

    private void notifySetVoiceChange(string userID, CRVSDK_VOICECHANGE_TYPE type, string oprUserID)
    {
        if (oprUserID == MeetingPage.mMyUserId)
            return;

        Debug.Log("user " + userID + " voice change set to: " + type);
    }

    private void UpdateUserList()
    {
        GameObject content = GameObject.Find("Content");
        Transform transform;
        for (int i = 0; i < content.transform.childCount; i++)
        {
            transform = content.transform.GetChild(i);
            GameObject.Destroy(transform.gameObject);
        }

        MeetingMemberList allMems = g_sdkMain.getSDKMeeting().getAllMembers();
        foreach (var member in allMems)
        {
            GameObject go = Instantiate(mUserOptions, content.transform);
            var name = go.transform.Find("UserId").gameObject.GetComponent<Text>();
            name.text = member._userId;
            var opts = go.transform.Find("Options").gameObject.GetComponent<Dropdown>();
            int type = (int)g_sdkMain.getSDKMeeting().getVoiceChangeType(member._userId);
            opts.value = type;
            opts.onValueChanged.AddListener(delegate {
                OnDropdownChanged(opts);
            });
        }
    }


    private void OnDropdownChanged(Dropdown dd)
    {
        string userId = dd.transform.parent.Find("UserId").gameObject.GetComponent<Text>().text;
        Debug.Log("user(" + userId + ") option chaged to: " + dd.value);
        g_sdkMain.getSDKMeeting().setVoiceChange(userId, (CRVSDK_VOICECHANGE_TYPE)dd.value);
    }

    public void OnExitVoiceChangeClicked()
    {
        StartCoroutine(UnloadVoiceChangeScene());
    }

    public IEnumerator UnloadVoiceChangeScene()
    {
        AsyncOperation async = SceneManager.UnloadSceneAsync("VoiceChangeScene");
        yield return async;
    }
}
