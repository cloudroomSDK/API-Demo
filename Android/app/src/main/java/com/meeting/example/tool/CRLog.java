package com.meeting.example.tool;

import com.cloudroom.cloudroomvideosdk.CloudroomVideoSDK;
import com.cloudroom.cloudroomvideosdk.model.SDK_LOG_LEVEL_DEF;

public class CRLog {

	private static void log(SDK_LOG_LEVEL_DEF level, String tag, String log) {
		CloudroomVideoSDK.getInstance().writeLog(level, tag + ":" + log);
	}

	public static void debug(String tag, String log) {
		log(SDK_LOG_LEVEL_DEF.SDKLEVEL_DEBUG, tag, log);
	}

	public static void info(String tag, String log) {
		log(SDK_LOG_LEVEL_DEF.SDKLEVEL_INFO, tag, log);
	}

	public static void warn(String tag, String log) {
		log(SDK_LOG_LEVEL_DEF.SDKLEVEL_WARN, tag, log);
	}

	public static void error(String tag, String log) {
		log(SDK_LOG_LEVEL_DEF.SDKLEVEL_ERR, tag, log);
	}

}
