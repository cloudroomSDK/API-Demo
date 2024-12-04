using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;


public class EchoTestPage : MonoBehaviour
{
    private CRVSDKMain g_sdkMain = null;

    private Button mStartEchoTest = null;
    private Button mStopEchoTest = null;
    private Text mEchoTestInfo = null;
    private int mSecondsToStop = 10;

    private float mTimer = 0f;
    private bool mStarted = false;

    void Awake()
    {
        g_sdkMain = MeetingPage.g_sdkMain;

        mStartEchoTest = GameObject.Find("StartEchoTest").GetComponent<Button>();
        mStartEchoTest.onClick.AddListener(OnStartEchoTestClicked);
        mStopEchoTest = GameObject.Find("StopEchoTest").GetComponent<Button>();
        mStopEchoTest.onClick.AddListener(OnStopEchoTestClicked);
        mEchoTestInfo = GameObject.Find("txtEchoTestInfo").GetComponent<Text>();

        mStopEchoTest.gameObject.SetActive(false);
    }

    void Start()
    {
    }

    void Update()
    {
        if (mStarted)
        {
            mTimer += Time.deltaTime;
            int secondsLeft = mSecondsToStop - (int)mTimer;
            mEchoTestInfo.text = string.Format("声音环回测试中，{0}秒后自动退出", secondsLeft);
            if (secondsLeft <= 0)
            {
                OnStopEchoTestClicked();
            }
        }
    }

    void OnDisable()
    {
        Debug.Log("EchoTestPage, OnDisable");
        OnStopEchoTestClicked();
    }

    public void OnStartEchoTestClicked()
    {
        g_sdkMain.getSDKMeeting().startEchoTest();
        mStarted = true;

        mStartEchoTest.gameObject.SetActive(false);
        mStopEchoTest.gameObject.SetActive(true);
    }

    public void OnStopEchoTestClicked()
    {
        mStarted = false;
        mTimer = 0f;
        g_sdkMain.getSDKMeeting().stopEchoTest();
        mStartEchoTest.gameObject.SetActive(true);
        mStopEchoTest.gameObject.SetActive(false);
        mEchoTestInfo.text = "";
    }

    public void OnExitEchoTestClicked()
    {
        StartCoroutine(UnloadEchoTestScene());
    }

    public IEnumerator UnloadEchoTestScene()
    {
        AsyncOperation async = SceneManager.UnloadSceneAsync("EchoTestScene");
        yield return async;
    }
}
