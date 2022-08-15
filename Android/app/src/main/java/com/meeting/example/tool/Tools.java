package com.meeting.example.tool;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ActivityManager;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ConfigurationInfo;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.util.Log;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

@SuppressLint("SimpleDateFormat")
public class Tools {

	public static String getTimeStr(int sec) {
		int s = sec % 60;
		int m = sec / 60;
		int h = m / 60;
		StringBuffer time = new StringBuffer();
		if (h > 0) {
			time.append(h).append("小时");
		}
		if (m > 0) {
			time.append(m).append("分");
		}
		time.append(s).append("秒");
		return time.toString();
	}

	public static boolean detectOpenGLES20(Context context) {
		ActivityManager am = (ActivityManager) context
				.getSystemService(Context.ACTIVITY_SERVICE);
		ConfigurationInfo info = am.getDeviceConfigurationInfo();
		return (info.reqGlEsVersion >= 0x20000);
	}

	/**
	 * sp转换成px
	 */
	public static int sp2px(Context context, float spValue) {
		float fontScale = context.getResources().getDisplayMetrics().scaledDensity;
		return (int) (spValue * fontScale + 0.5f);
	}

	public static String getPathFromUri(Context context, Uri uri) {
		String path = null;
		if (Build.VERSION.SDK_INT >= 19
				&&DocumentsContract.isDocumentUri(context, uri)) {
			//如果是document类型的Uri，通过document id处理，内部会调用Uri.decode(docId)进行解码
			String docId = DocumentsContract.getDocumentId(uri);
			//primary:Azbtrace.txt
			//video:A1283522
			String[] splits = docId.split(":");
			String type = null, id = null;
			if(splits.length == 2) {
				type = splits[0];
				id = splits[1];
			}
			switch (uri.getAuthority()) {
				case "com.android.externalstorage.documents":
					if("primary".equals(type)) {
						path = Environment.getExternalStorageDirectory() + File.separator + id;
					}
					break;
				case "com.android.providers.downloads.documents":
					if("raw".equals(type)) {
						path = id;
					} else {
						Uri contentUri = ContentUris.withAppendedId(Uri.parse("content://downloads/public_downloads"), Long.valueOf(docId));
						path = getMediaPathFromUri(context, contentUri, null, null);
					}
					break;
				case "com.android.providers.media.documents":
					Uri externalUri = null;
					switch (type) {
						case "image":
							externalUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
							break;
						case "video":
							externalUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
							break;
						case "audio":
							externalUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
							break;
						case "document":
							externalUri = MediaStore.Files.getContentUri("external");
							break;
					}
					if(externalUri != null) {
						String selection = "_id=?";
						String[] selectionArgs = new String[]{ id };
						path = getMediaPathFromUri(context, externalUri, selection, selectionArgs);
					}
					break;
			}
		} else if (ContentResolver.SCHEME_CONTENT.equalsIgnoreCase(uri.getScheme())) {
			path = getMediaPathFromUri(context, uri, null, null);
		} else if (ContentResolver.SCHEME_FILE.equalsIgnoreCase(uri.getScheme())) {
			//如果是file类型的Uri(uri.fromFile)，直接获取图片路径即可
			path = uri.getPath();
		}
		//确保如果返回路径，则路径合法
		return path == null ? null : (new File(path).exists() ? path : null);
	}

	private static String getMediaPathFromUri(Context context, Uri uri, String selection, String[] selectionArgs) {
		String path;
		String authroity = uri.getAuthority();
		path = uri.getPath();
		String sdPath = Environment.getExternalStorageDirectory().getAbsolutePath();
		if(!path.startsWith(sdPath)) {
			int sepIndex = path.indexOf(File.separator, 1);
			if(sepIndex == -1) path = null;
			else {
				path = sdPath + path.substring(sepIndex);
			}
		}

		if(path == null || !new File(path).exists()) {
			ContentResolver resolver = context.getContentResolver();
			String[] projection = new String[]{ MediaStore.MediaColumns.DATA };
			Cursor cursor = resolver.query(uri, projection, selection, selectionArgs, null);
			if (cursor != null) {
				if (cursor.moveToFirst()) {
					try {
						int index = cursor.getColumnIndexOrThrow(projection[0]);
						if (index != -1) path = cursor.getString(index);
						Log.i("eeee", "getMediaPathFromUri query " + path);
					} catch (IllegalArgumentException e) {
						e.printStackTrace();
						path = null;
					} finally {
						cursor.close();
					}
				}
			}
		}
		return path;
	}

	// 时间格式化对象
	private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat(
			"yyyy-MM-DD HH:mm:ss.SSS");

	public static String getCurrentTimeStr() {
		Date date = new Date(System.currentTimeMillis());
		return DATE_FORMAT.format(date);
	}

	public static boolean getFile(Activity activity, String type, int requestCode) {
		try {
			Intent intent = new Intent(Intent.ACTION_PICK, null);
			intent.setDataAndType(MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
					"video/*");
			activity.startActivityForResult(intent, requestCode);
			return true;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}
}
