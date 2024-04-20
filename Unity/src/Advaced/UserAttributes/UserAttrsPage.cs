using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;


public class UserAttrsPage : MonoBehaviour
{
    private CRVSDKMain g_sdkMain = null;

    private Button mAddBtn = null;
    private Button mClearBtn = null;
    private GameObject mUserGrp = null;
    private GameObject mAttrsGrp = null;
    private Text mUserAttrsInfo = null;
    private GameObject mAddOrEditPanel = null;
    private InputField mIFKey = null;
    private InputField mIFValue = null;

    private string mSelectUserId = "";
    private Dictionary<string, RoomUserAttr> mAllAttrs = new Dictionary<string,RoomUserAttr>();
    private string mLastKey = "";
    private string mLastValue = "";
    private string mCookie;

    public GameObject mUserSelect;
    public GameObject mAttributeItem;

    void Awake()
    {
        g_sdkMain = MeetingPage.g_sdkMain;
        g_sdkMain.getSDKMeeting().onGetUserAttrsSuccess = getUserAttrsSuccess;
        g_sdkMain.getSDKMeeting().onGetUserAttrsFail = getUserAttrsFail;
        g_sdkMain.getSDKMeeting().onAddOrUpdateUserAttrsRslt = addOrUpdateUserAttrsRslt;
        g_sdkMain.getSDKMeeting().onDelUserAttrsRslt = delUserAttrsRslt;
        g_sdkMain.getSDKMeeting().onClearUserAttrsRslt = clearUserAttrsRslt;

        mUserGrp = GameObject.Find("SVUser");
        mAttrsGrp = GameObject.Find("AttrsGrp");
        mAddBtn = GameObject.Find("AddAttrBtn").GetComponent<Button>();
        mAddBtn.onClick.AddListener(OnAddAttrClicked);
        mClearBtn = GameObject.Find("ClearAttrsBtn").GetComponent<Button>();
        mClearBtn.onClick.AddListener(OnClearAttrsClicked);
        Button backBtn = GameObject.Find("BackUserBtn").GetComponent<Button>();
        backBtn.onClick.AddListener(OnBackUserClicked);
        mUserAttrsInfo = GameObject.Find("txtUserAttrsInfo").GetComponent<Text>();
        mAddOrEditPanel = GameObject.Find("AddOrEditPanel");
        mIFKey = GameObject.Find("ifKey").GetComponent<InputField>();
        mIFValue = GameObject.Find("ifValue").GetComponent<InputField>();
        Button btnSave = GameObject.Find("SaveBtn").GetComponent<Button>();
        btnSave.onClick.AddListener(OnSaveAttrClicked);
        Button btnCancel = GameObject.Find("CancelBtn").GetComponent<Button>();
        btnCancel.onClick.AddListener(OnCancelAttrClicked);
        mAddOrEditPanel.SetActive(false);
        mAttrsGrp.SetActive(false);

        mCookie = Guid.NewGuid().ToString();

        UpdateUserList();
    }

    private void getUserAttrsSuccess(string attrsMap, string cookie)
    {
        if (cookie != mCookie)
            return;

        Debug.Log("get user: " + mSelectUserId + " attrs: " + attrsMap);
        string jsonStr = attrsMap.Substring(attrsMap.IndexOf('{', 1));
        jsonStr.Substring(0, jsonStr.Length - 1);
        CommonTools.ParseRoomUserAttrs(jsonStr, mAllAttrs);

        mUserGrp.SetActive(false);
        mAttrsGrp.SetActive(true);
        UpdateAttrsView();
        UpdateBtnsState();
    }

    private void getUserAttrsFail(CRVSDK_ERR_DEF sdkErr, string cookie)
    {
        if (cookie != mCookie)
            return;

        mSelectUserId = "";
        mUserAttrsInfo.text = "Get room attribute fail, error: " + sdkErr;
    }

    private void addOrUpdateUserAttrsRslt(CRVSDK_ERR_DEF sdkErr, string cookie)
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

    private void delUserAttrsRslt(CRVSDK_ERR_DEF sdkErr, string cookie)
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

    private void clearUserAttrsRslt(CRVSDK_ERR_DEF sdkErr, string cookie)
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

    private void UpdateUserList()
    {
        GameObject content = GameObject.Find("UserContent");
        Transform transform;
        for (int i = 0; i < content.transform.childCount; i++)
        {
            transform = content.transform.GetChild(i);
            GameObject.Destroy(transform.gameObject);
        }

        MeetingMemberList allMems = g_sdkMain.getSDKMeeting().getAllMembers();
        foreach (var member in allMems)
        {
            GameObject go = Instantiate(mUserSelect, content.transform);
            var name = go.transform.Find("UserId").gameObject.GetComponent<Text>();
            name.text = member._userId;
            var button = go.transform.Find("SelectBtn").gameObject.GetComponent<Button>();
            button.onClick.AddListener(OnSelectClicked);
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

        GameObject content = GameObject.Find("AttrsContent");
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
            mUserAttrsInfo.text = "Operate success";
        }
        else
        {
            mUserAttrsInfo.text = "Operate fail, error: " + sdkErr;
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

    public void OnSelectClicked()
    {
        var button = UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject;
        mSelectUserId = button.transform.parent.Find("UserId").gameObject.GetComponent<Text>().text;
        Debug.Log("select user: " + mSelectUserId);

        string jsonIds = "[\"" + mSelectUserId + "\"]";
        g_sdkMain.getSDKMeeting().getUserAttrs(jsonIds, "", mCookie);
    }

    public void OnAddAttrClicked()
    {
        ShowAddOrEditPanel();
    }

    public void OnRemoveAttrClicked()
    {
        var button = UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject;
        mLastKey = button.transform.parent.Find("AttrKey").gameObject.GetComponent<Text>().text;
        string jsonStr = "[\"" + mLastKey + "\"]";
        g_sdkMain.getSDKMeeting().delUserAttrs(mSelectUserId, jsonStr, "", mCookie);
    }

    public void OnClearAttrsClicked()
    {
        if (mAllAttrs.Count == 0)
            return;

        ClearLastKeyValue();
        g_sdkMain.getSDKMeeting().clearUserAttrs(mSelectUserId, "", mCookie);
    }

    public void OnBackUserClicked()
    {
        mSelectUserId = "";
        ClearLastKeyValue();
        mAllAttrs.Clear();
        mAttrsGrp.SetActive(false);
        mUserGrp.SetActive(true);
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
            mUserAttrsInfo.text = "Key and value can't be empty";
            mAddOrEditPanel.SetActive(false);
            ClearLastKeyValue();
            return;
        }
        if (mAllAttrs.ContainsKey(mLastKey))
        {
            mUserAttrsInfo.text = "Key already exist";
            mAddOrEditPanel.SetActive(false);
            ClearLastKeyValue();
            return;
        }

        string jsonStr = "{\"" + mLastKey + "\":\"" + mLastValue + "\"}";
        Debug.Log("add or edit json: " + jsonStr);
        g_sdkMain.getSDKMeeting().addOrUpdateUserAttrs(mSelectUserId, jsonStr, "", mCookie);

        mAddOrEditPanel.SetActive(false);
    }

    public void OnCancelAttrClicked()
    {
        mAddOrEditPanel.SetActive(false);
    }

    public void OnExitUserAttrsClicked()
    {
        StartCoroutine(UnloadUserAttrsScene());
    }

    public IEnumerator UnloadUserAttrsScene()
    {
        AsyncOperation async = SceneManager.UnloadSceneAsync("UserAttrsScene");
        yield return async;
    }
}
