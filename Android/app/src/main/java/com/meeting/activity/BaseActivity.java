package com.meeting.activity;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.os.Handler;

import com.meeting.DemoApp;
import com.meeting.example.common.PermissionManager;

import me.jessyan.autosize.internal.CustomAdapt;


public class BaseActivity extends Activity implements CustomAdapt {

    private static boolean mHasRequested = false;

    protected Handler mainhandler = new Handler();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        super.onCreate(savedInstanceState);
        if (!PermissionManager.getInstance().checkPermission(PermissionManager.VIDEO_PERMISSION)) {
            PermissionManager.getInstance().applySDKPermissions(this);
        } else {
            mainhandler.post(new Runnable() {
                @Override
                public void run() {
                    onRequestPermissionsFinished();
                }
            });
        }
        DemoApp.getInstance().onActivityCreate(this);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions,
                                           int[] grantResults) {
        mHasRequested = true;
        onRequestPermissionsFinished();
    }

    public void startActivity(Class<?> cls) {
        startActivity(new Intent(getApplicationContext(), cls));
    }

    @Override
    public boolean isBaseOnWidth() {
        return false;
    }

    @Override
    public float getSizeInDp() {
        return 667f;
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        DemoApp.getInstance().onActivityDestroy(this);
    }

    protected void onRequestPermissionsFinished() {
        DemoApp.getInstance().initCloudroomVideoSDK();
    }
}
