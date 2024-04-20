using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

[Serializable]
public class CustomMsg
{
    public string CmdType;
    public string IMMsg;
    public CustomMsg() { }
}

public class RoomMsgPage : MonoBehaviour
{
    private CRVSDKMain g_sdkMain = null;

    private Button mSendMsg = null;
    private InputField mInput = null;
    private Text mRoomMsgTip = null;
    private ScrollRect mScrollRt = null;

    public GameObject mMsgObj;
    private string mCookie;

    static List<string> sAllRoomMsg = new List<string>();

    void Awake()
    {
        g_sdkMain = MeetingPage.g_sdkMain;
        g_sdkMain.getSDKMeeting().onSendMeetingCustomMsgRslt = sendMeetingCustomMsgRslt;
        g_sdkMain.getSDKMeeting().notifyMeetingCustomMsg = notifyMeetingCustomMsg;

        mSendMsg = GameObject.Find("SendMsgBtn").GetComponent<Button>();
        mSendMsg.onClick.AddListener(OnSendMsgClicked);
        mInput = GameObject.Find("ifInput").GetComponent<InputField>();
        mRoomMsgTip = GameObject.Find("txtRoomMsgTip").GetComponent<Text>();
        mScrollRt = GameObject.Find("Scroll View").GetComponentInChildren<ScrollRect>();

        mCookie = Guid.NewGuid().ToString();
    }

	private void sendMeetingCustomMsgRslt(CRVSDK_ERR_DEF sdkErr, string cookie)
    {
        if(mCookie != cookie)
            return;

        if(CRVSDK_ERR_DEF.CRVSDKERR_NOERR == sdkErr)
        {
            // add to receive
            append2RecvMsg(mInput.text, MeetingPage.mMyUserId);
            mInput.text = "";
            mRoomMsgTip.text = "";
        }
        else
        {
            mRoomMsgTip.text = "Send message failed, error: " + sdkErr;
        }
    }

	private void notifyMeetingCustomMsg(string fromUserID, string jsonDat)
    {
        if (MeetingPage.mMyUserId == fromUserID)
            return;

        string strMsg = jsonDat;
        CustomMsg recvMsg = JsonUtility.FromJson<CustomMsg>(jsonDat);
        if(recvMsg.CmdType == "IM")
        {
            strMsg = recvMsg.IMMsg;
        }
        append2RecvMsg(strMsg, fromUserID);
    }

    private void append2RecvMsg(string msg, string userId)
    {
        bool isMine = (userId == MeetingPage.mMyUserId);

        //添加前位置等信息
        DateTime curDt = DateTime.Now;
        string strTime = curDt.ToString(" mm:ss");
        if (isMine)
        {
            strTime = "Me" + strTime;
        }
        else
        {
            strTime = userId + strTime;
        }

        string totalMsg = strTime + "\n" + msg + "\n\n";
        sAllRoomMsg.Add(totalMsg);
        GameObject content = GameObject.Find("Content");
        GameObject newMsgObj = Instantiate(mMsgObj, content.transform);
        Text msgTxt = newMsgObj.GetComponentInChildren<Text>();
        msgTxt.text = totalMsg;
        // scroll to bottom;
        mScrollRt.verticalNormalizedPosition = 0;
    }

    public void OnSendMsgClicked()
    {
        string inputText = mInput.text;
        if (inputText.Length <= 0)
        {
            mRoomMsgTip.text = "message is empty!";
            return;
        }

        CustomMsg newMsg = new CustomMsg();
        newMsg.CmdType = "IM";
        newMsg.IMMsg = inputText;
        string roomMsg = JsonUtility.ToJson(newMsg);
        g_sdkMain.getSDKMeeting().sendMeetingCustomMsg(roomMsg, mCookie);
    }

    public void OnExitRoomMsgClicked()
    {
        StartCoroutine(UnloadRoomMsgScene());
    }

    public IEnumerator UnloadRoomMsgScene()
    {
        AsyncOperation async = SceneManager.UnloadSceneAsync("RoomMsgScene");
        yield return async;
    }
}
