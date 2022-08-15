package com.meeting.example.tool;

import com.cloudroom.cloudroomvideosdk.CloudroomVideoSDK;
import com.cloudroom.cloudroomvideosdk.model.SDK_LOG_LEVEL_DEF;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.Thread.UncaughtExceptionHandler;

public class CrashHandler implements UncaughtExceptionHandler {

	// private static final String TAG = "CrashHandler";

	public static void initThreadCrashHandler(boolean showCrashDialog) {
		UncaughtExceptionHandler uncaughtExceptionHandler = Thread
				.getDefaultUncaughtExceptionHandler();
		CrashHandler crashHandler = new CrashHandler(uncaughtExceptionHandler);
		Thread.setDefaultUncaughtExceptionHandler(crashHandler);
	}

	private UncaughtExceptionHandler mDefaultHandler;
	private boolean mShowCrashDialog = true;

	private CrashHandler(UncaughtExceptionHandler uncaughtExceptionHandler) {
		mDefaultHandler = uncaughtExceptionHandler;
	}

	public void setDefaultUncaughtExceptionHandler(
			UncaughtExceptionHandler uncaughtExceptionHandler) {
		mDefaultHandler = uncaughtExceptionHandler;
	}

	@Override
	public void uncaughtException(Thread thread, Throwable ex) {
		CloudroomVideoSDK.getInstance().writeLog(
				SDK_LOG_LEVEL_DEF.SDKLEVEL_CRIT, throwable2String(ex));
		if (mShowCrashDialog) {
			mDefaultHandler.uncaughtException(thread, ex);
		}
		android.os.Process.killProcess(android.os.Process.myPid());
	}

	private String throwable2String(Throwable ex) {
		StringWriter sw = new StringWriter();
		PrintWriter pw = new PrintWriter(sw);
		ex.printStackTrace(pw);
		pw.close();
		return sw.toString();
	}
}
