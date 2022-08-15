package com.meeting;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Application;
import android.content.SharedPreferences;
import android.os.Environment;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.util.Log;

import com.cloudroom.cloudroomvideosdk.CloudroomVideoSDK;
import com.cloudroom.cloudroomvideosdk.model.SdkInitDat;
import com.meeting.example.common.PermissionManager;
import com.meeting.example.common.VideoSDKHelper;
import com.tencent.bugly.crashreport.CrashReport;

import java.util.LinkedList;

@SuppressLint({ "HandlerLeak", "SdCardPath" })
public class DemoApp extends Application {

	private static final String TAG = "DemoApp";
	public static final String DEMO_FILE_DIR = Environment
			.getExternalStorageDirectory().getAbsolutePath() + "/APIDemo/";
	public static String SDK_DATA_PATH = Environment
			.getExternalStorageDirectory().getAbsolutePath()
			+ "/APIDemo";
	private Handler mMainHandler = new Handler();

	@Override
	public void onCreate() {
		// TODO Auto-generated method stub
		super.onCreate();
		mInstance = this;

		// 注：Bugly崩溃收集上报代码，非云屋SDK
		CrashReport.initCrashReport(getApplicationContext(), "69473644c9", false);
		CrashReport.startCrashReport();
		// 本地本地管理对象初始化
		VideoSDKHelper.getInstance().setContext(getApplicationContext());
		//授权管理类
        PermissionManager.getInstance().setContext(getApplicationContext());
	}

	/**
	 * 初始化SDK
	 */
	public void initCloudroomVideoSDK() {
        if (CloudroomVideoSDK.getInstance().isInitSuccess()) {
            Log.i(TAG, "initCloudroomVideoSDK has init");
            return;
        }
        Log.i(TAG, "initCloudroomVideoSDK init");
		// 输出SDK版本号
		String sdkVer = CloudroomVideoSDK.getInstance()
				.GetCloudroomVideoSDKVer();
		Log.d(TAG, "CloudroomVideoSDKVer:" + sdkVer);

        SharedPreferences sharedPreferences = PreferenceManager
                .getDefaultSharedPreferences(this);
        String datEncType = sharedPreferences.getString("datEncType","1");
        int datEncTypeInt = Integer.parseInt(datEncType);

		// SDK初始化数据对象
		SdkInitDat initDat = new SdkInitDat();
		// 会议Demo不需要呼叫队列功能
		initDat.noCall = true;
		initDat.noQueue = true;
		// 配置文件目录
		initDat.sdkDatSavePath = DEMO_FILE_DIR;
        initDat.datEncType = datEncTypeInt >= 1 ? "1" : "0";
        if(datEncTypeInt == 1) {
            initDat.params.put("VerifyHttpsCert", "1");
        } else {
            initDat.params.put("VerifyHttpsCert", "0");
        }
//        initDat.params.put("SupportUSBCamera", "1");
		// 初始化SDK
		CloudroomVideoSDK.getInstance().init(getApplicationContext(), initDat);
	}

    public void uninitCloudroomVideoSDK() {
        if(!CloudroomVideoSDK.getInstance().isInitSuccess()) {
            return;
        }
        CloudroomVideoSDK.getInstance().uninit();
    }

	private static DemoApp mInstance = null;

	/**
	 * 获取App对象
	 * 
	 * @return
	 */
	public static DemoApp getInstance() {
		return mInstance;
	}

	/**
	 * 当前应用Activity列表，方便彻底退出应用
	 */
	private LinkedList<Activity> mActivitys = new LinkedList<Activity>();

    public Activity getLastActivity(Activity curActivity) {
        int count = mActivitys.size();
        int index = count - 1;
        while (count > 0 && index >= 0) {
            Activity activity = mActivitys.get(index);
            if(activity != curActivity && !activity.isFinishing()) {
                return activity;
            }
            index--;
        }
        return null;
    }
	
	/**
	 * Activity创建
	 * 
	 * @param activity
	 */
	public void onActivityCreate(Activity activity) {
		mActivitys.add(activity);
	}

	/**
	 * Activity销毁
	 * 
	 * @param activity
	 */
	public void onActivityDestroy(Activity activity) {
		mActivitys.remove(activity);
	}

	/**
	 * 退出程序
	 */
	public void terminalApp() {
		// 反初始化SDK
		CloudroomVideoSDK.getInstance().uninit();
		for (Activity activity : mActivitys) {
			try {
				activity.finish();
			} catch (Exception e) {
			}
		}
		mActivitys.clear();
		mMainHandler.postDelayed(mKillRunnable, 500);
	}

	// 彻底杀掉应用进程
	private Runnable mKillRunnable = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			android.os.Process.killProcess(android.os.Process.myPid());
		}
	};

}
