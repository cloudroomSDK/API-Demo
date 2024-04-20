using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;


[Serializable]
public class RoomUserAttr
{
    public string value;
    public string lastModifyUserID;
    public long lastModifyTs;
    public RoomUserAttr() {
        lastModifyTs = 0;
    }
}

public class RoomAttrsPage : MonoBehaviour
{
    private CRVSDKMain g_sdkMain = null;

    private Button mAddBtn = null;
    private Button mClearBtn = null;
    private Text mRoomAttrsInfo = null;
    private GameObject mAddOrEditPanel = null;
    private InputField mIFKey = null;
    private InputField mIFValue = null;

    private Dictionary<string, RoomUserAttr> mAllAttrs = new Dictionary<string,RoomUserAttr>();
    private string mLastKey = "";
    private string mLastValue = "";
    private string mCookie;

    public GameObject mAttributeItem;

    void Awake()
    {
        g_sdkMain = MeetingPage.g_sdkMain;
        g_sdkMain.getSDKMeeting().onGetMeetingAllAttrsSuccess = getMeetingAllAttrsSuccess;
        g_sdkMain.getSDKMeeting().onGetMeetingAllAttrsFail = getMeetingAllAttrsFail;
        g_sdkMain.getSDKMeeting().onAddOrUpdateMeetingAttrsRslt = addOrUpdateMeetingAttrsRslt;
        g_sdkMain.getSDKMeeting().onDelMeetingAttrsRslt = delMeetingAttrsRslt;
        g_sdkMain.getSDKMeeting().onClearMeetingAttrsRslt = clearMeetingAttrsRslt;

        mAddBtn = GameObject.Find("AddAttrBtn").GetComponent<Button>();
        mAddBtn.onClick.AddListener(OnAddAttriClicked);
        mClearBtn = GameObject.Find("ClearAttrsBtn").GetComponent<Button>();
        mClearBtn.onClick.AddListener(OnClearAttrsClicked);
        mRoomAttrsInfo = GameObject.Find("txtRoomAttrsInfo").GetComponent<Text>();
        mAddOrEditPanel = GameObject.Find("AddOrEditPanel");
        mIFKey = GameObject.Find("ifKey").GetComponent<InputField>();
        mIFValue = GameObject.Find("ifValue").GetComponent<InputField>();
        Button btnSave = GameObject.Find("SaveBtn").GetComponent<Button>();
        btnSave.onClick.AddListener(OnSaveAttrClicked);
        Button btnCancel = GameObject.Find("CancelBtn").GetComponent<Button>();
        btnCancel.onClick.AddListener(OnCancelAttrClicked);
        mAddOrEditPanel.SetActive(false);

        mCookie = Guid.NewGuid().ToString();

        UpdateBtnsState();
        g_sdkMain.getSDKMeeting().getMeetingAllAttrs(mCookie);
    }

    private void getMeetingAllAttrsSuccess(string attrs, string cookie)
    {
        if (cookie != mCookie)
            return;

        Debug.Log("room attrs: " + attrs);
        CommonTools.ParseRoomUserAttrs(attrs, mAllAttrs);

        UpdateAttrsView();
        UpdateBtnsState();
    }

    private void getMeetingAllAttrsFail(CRVSDK_ERR_DEF sdkErr, string cookie)
    {
        if (cookie != mCookie)
            return;

        mRoomAttrsInfo.text = "Get room attribute fail, error: " + sdkErr;
    }

    private void addOrUpdateMeetingAttrsRslt(CRVSDK_ERR_DEF sdkErr, string cookie)
    {
        if (cookie != mCookie)
            return;

        UpdateTips(sdkErr);
        if (CRVSDK_ERR_DEF.CRVSDKERR_NOERR == sdkErr)
        {
            UpdateAttrsView();
            UpdateBtnsState();
        }
    }

    private void delMeetingAttrsRslt(CRVSDK_ERR_DEF sdkErr, string cookie)
    {
        if (cookie != mCookie)
            return;

        UpdateTips(sdkErr);
        if (CRVSDK_ERR_DEF.CRVSDKERR_NOERR == sdkErr)
        {
            UpdateAttrsView();
            UpdateBtnsState();
        }
    }

    private void clearMeetingAttrsRslt(CRVSDK_ERR_DEF sdkErr, string cookie)
    {
        if (cookie != mCookie)
            return;

        UpdateTips(sdkErr);
        if (CRVSDK_ERR_DEF.CRVSDKERR_NOERR == sdkErr)
        {
            mAllAttrs.Clear();
            UpdateAttrsView();
            UpdateBtnsState();
        }
    }

    private void UpdateAttrsView()
    {
        if (mLastKey.Length > 0)
        {
            // Add
            if (!mAllAttrs.ContainsKey(mLastKey))
            {
                RoomUserAttr ruAttr = new RoomUserAttr();
                ruAttr.value = mLastValue;
                ruAttr.lastModifyUserID = MeetingPage.mMyUserId;
                DateTimeOffset dto = new DateTimeOffset(DateTime.Now);
                ruAttr.lastModifyTs = dto.ToUnixTimeSeconds();
                mAllAttrs.Add(mLastKey, ruAttr);
            }
            else
            {
                if (mLastValue.Length > 0)
                {
                    // Edit
                    RoomUserAttr ruAttr = mAllAttrs[mLastKey];
                    ruAttr.value = mLastValue;
                    ruAttr.lastModifyUserID = MeetingPage.mMyUserId;
                    DateTimeOffset dto = new DateTimeOffset(DateTime.Now);
                    ruAttr.lastModifyTs = dto.ToUnixTimeSeconds();
                }
                else
                {
                    // Remove
                    mAllAttrs.Remove(mLastKey);
                }
            }
        }
        ClearLastKeyValue();

        GameObject content = GameObject.Find("Content");
        Transform transform;
        for (int i = 0; i < content.transform.childCount; i++)
        {
            transform = content.transform.GetChild(i);
            GameObject.Destroy(transform.gameObject);
        }
        foreach (var obj in mAllAttrs)
        {
            GameObject go = Instantiate(mAttributeItem, content.transform);
            var txtKey = go.transform.Find("AttrKey").gameObject.GetComponent<Text>();
            txtKey.text = obj.Key;
            var txtValue = go.transform.Find("AttrValue").gameObject.GetComponent<Text>();
            txtValue.text = obj.Value.value;
            var txtModifyUser = go.transform.Find("ModifyByUser").gameObject.GetComponent<Text>();
            txtModifyUser.text = obj.Value.lastModifyUserID;
            var txtModifyTime = go.transform.Find("ModifyTime").gameObject.GetComponent<Text>();
            DateTime dt = DateTimeOffset.FromUnixTimeSeconds(obj.Value.lastModifyTs).LocalDateTime;
            txtModifyTime.text = dt.ToString("yyyy/MM/dd hh:mm:ss");
            var editBtn = go.transform.Find("EditBtn").gameObject.GetComponent<Button>();
            editBtn.onClick.AddListener(OnEditAttrClicked);
            var removeBtn = go.transform.Find("RemoveBtn").gameObject.GetComponent<Button>();
            removeBtn.onClick.AddListener(OnRemoveAttrClicked);
        }
    }

    private void UpdateBtnsState()
    {
        mClearBtn.interactable = (mAllAttrs.Count > 0);
    }

    private void UpdateTips(CRVSDK_ERR_DEF sdkErr)
    {
        if (sdkErr == CRVSDK_ERR_DEF.CRVSDKERR_NOERR)
        {
            mRoomAttrsInfo.text = "Operate success";
        }
        else
        {
            mRoomAttrsInfo.text = "Operate fail, error: " + sdkErr;
            ClearLastKeyValue();
        }
    }

    private void ShowAddOrEditPanel(string strKey = "", string strValue = "")
    {
        mAddOrEditPanel.SetActive(true);
        mIFKey.text = strKey;
        mIFValue.text = strValue;
        mIFKey.interactable = (strKey.Length == 0);
    }

    private void ClearLastKeyValue()
    {
        mLastKey = "";
        mLastValue = "";
    }

    public void OnAddAttriClicked()
    {
        ShowAddOrEditPanel();
    }

    public void OnRemoveAttrClicked()
    {
        var button = UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject;
        mLastKey = button.transform.parent.Find("AttrKey").gameObject.GetComponent<Text>().text;
        string jsonStr = "[\"" + mLastKey + "\"]";
        g_sdkMain.getSDKMeeting().delMeetingAttrs(jsonStr, "", mCookie);
    }

    public void OnClearAttrsClicked()
    {
        if (mAllAttrs.Count == 0)
            return;

        ClearLastKeyValue();
        g_sdkMain.getSDKMeeting().clearMeetingAttrs("", mCookie);
    }

    public void OnEditAttrClicked()
    {
        var button = UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject;
        var attrKey = button.transform.parent.Find("AttrKey").gameObject.GetComponent<Text>().text;
        var attrValue = button.transform.parent.Find("AttrValue").gameObject.GetComponent<Text>().text;
        ShowAddOrEditPanel(attrKey, attrValue);
    }

    public void OnSaveAttrClicked()
    {
        mLastKey = mIFKey.text;
        mLastValue = mIFValue.text;
        if (mLastKey.Length == 0 || mLastValue.Length == 0)
        {
            mRoomAttrsInfo.text = "Key and value can't be empty";
            mAddOrEditPanel.SetActive(false);
            ClearLastKeyValue();
            return;
        }
        if (mAllAttrs.ContainsKey(mLastKey))
        {
            mRoomAttrsInfo.text = "Key already exist";
            mAddOrEditPanel.SetActive(false);
            ClearLastKeyValue();
            return;
        }

        string jsonStr = "{\"" + mLastKey + "\":\"" + mLastValue + "\"}";
        Debug.Log("add or edit json: " + jsonStr);
        g_sdkMain.getSDKMeeting().addOrUpdateMeetingAttrs(jsonStr, "", mCookie);

        mAddOrEditPanel.SetActive(false);
    }

    public void OnCancelAttrClicked()
    {
        mAddOrEditPanel.SetActive(false);
    }

    public void OnExitRoomAttrClicked()
    {
        StartCoroutine(UnloadRoomAttrsScene());
    }

    public IEnumerator UnloadRoomAttrsScene()
    {
        AsyncOperation async = SceneManager.UnloadSceneAsync("RoomAttrsScene");
        yield return async;
    }
}
