package com.meeting.example.common;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.widget.Toast;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

/*import androidx.core.app.ActivityCompat;
 import androidx.core.content.ContextCompat;*/

public class PermissionManager {

	public static final int REQUEST_CODE_PERMISSION = 0x33;

	// 申请定位授权权限
	public static String[] LOCATION_PERMISSION = {
			Manifest.permission.ACCESS_FINE_LOCATION,
			Manifest.permission.ACCESS_COARSE_LOCATION, };

	public static String[] STORATION_PERMISSION = { Manifest.permission.WRITE_EXTERNAL_STORAGE, };

	public static String[] PHONE_INFO = { Manifest.permission.READ_PHONE_STATE };

	// 音视频相关权限
	public static String[] VIDEO_PERMISSION = { Manifest.permission.CAMERA,
			Manifest.permission.RECORD_AUDIO,
			Manifest.permission.READ_EXTERNAL_STORAGE,
			Manifest.permission.WRITE_EXTERNAL_STORAGE,
			Manifest.permission.READ_PHONE_STATE, };

	public static String[] NEED_PERMISSION = VIDEO_PERMISSION;

	private static PermissionManager instance;

	private WeakReference<Activity> activityWeakReference = null;
	private WeakReference<Context> contextWeakReference = null;

	public static PermissionManager getInstance() {
		// 线程安全的单例模式
		synchronized (PermissionManager.class) {
			if (instance == null) {
				instance = new PermissionManager();
			}
		}
		return instance;
	}

	// application中进行初始化
	public void setContext(Context context) {
		contextWeakReference = new WeakReference<>(context);
	}

	/************************************** 授权管理 ******************************************/

	/**
	 * 添加音视频所需权限
	 */
	public boolean applySDKPermissions(Activity activity) {
		contextWeakReference = new WeakReference<>(
				activity.getApplicationContext());
		activityWeakReference = new WeakReference<>(activity);
		return applyCheckPermissions(NEED_PERMISSION);
	}

	// 检查相应权限，并申请未授权的部分
	private boolean applyCheckPermissions(String... permissions) {
		try {
			//如果没有全部授权，获取未授权的权限
			List<String> needRequestPermissionList =
					findDeniedPermissions(permissions);

			//对未授权的权限进行授权询问
			if (null != needRequestPermissionList
					&& needRequestPermissionList.size() > 0) {
				ActivityCompat.requestPermissions(activityWeakReference.get(),
						needRequestPermissionList.toArray(new
                                String[needRequestPermissionList.size()]), REQUEST_CODE_PERMISSION);
			}
		} catch (Exception e) {
			//异常状态处理
			e.printStackTrace();
			Toast.makeText(contextWeakReference.get(), "授权功能异常" + e.getMessage(),
					Toast.LENGTH_SHORT).show();
			return false;
		}
		return false;
	}

	/**
	 * 查看是否权限
	 */
	public boolean checkPermission(String... permissions) {
		// 如果android版本低于Android6.0，默认为开启权限（无危险权限）
		 if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true;
		NEED_PERMISSION = permissions;
		PackageManager pm = contextWeakReference.get().getPackageManager();
		for (String permission : permissions) {
			if (PackageManager.PERMISSION_GRANTED !=
					pm.checkPermission(permission,
							contextWeakReference.get().getPackageName())) {
				return false;
			}
		}
		return true;
	}

	/**
	 * 获取需要申请权限的列表
	 */
	private List<String> findDeniedPermissions(String[] permissions) {
		List<String> needRequestPermissionList = new ArrayList<String>();
		for (String perm : permissions) {
			if (ContextCompat.checkSelfPermission(contextWeakReference.get(),
					perm) != PackageManager.PERMISSION_GRANTED) {
				needRequestPermissionList.add(perm);
			} else {
				if (ActivityCompat.shouldShowRequestPermissionRationale(
						activityWeakReference.get(), perm)) {
					needRequestPermissionList.add(perm);
				}
			}
		}
		return needRequestPermissionList;
	}
}
