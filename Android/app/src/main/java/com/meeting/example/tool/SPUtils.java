package com.meeting.example.tool;

/**
 * Created by zjw on 2022/3/23.
 */
/**
 *
 */

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;

import java.util.ArrayList;
import java.util.Set;

public class SPUtils {
    public static final String DATA_NAME = "API_demo";
    public static final String LAST_MEET_ID = "LAST_MEET_ID";
    public static final String ROOM_TYPE = "ROOM_TYPE";

    @SuppressWarnings("unchecked")
    public static <T> T getPreference(Context context, String pName, String key, T defaultValue) {
        SharedPreferences sp = context.getSharedPreferences(pName, 0);
        if (sp.contains(key)) {
            if (defaultValue instanceof String) {
                return (T) sp.getString(key, (String) defaultValue);
            } else if (defaultValue instanceof Long) {
                return (T) Long.valueOf(sp.getLong(key, (Long) defaultValue));
            } else if (defaultValue instanceof Integer) {
                return (T) Integer.valueOf(sp.getInt(key,
                        (Integer) defaultValue));
            } else if (defaultValue instanceof Float) {
                return (T) Float
                        .valueOf(sp.getFloat(key, (Float) defaultValue));
            } else if (defaultValue instanceof Boolean) {
                return (T) Boolean.valueOf(sp.getBoolean(key,
                        (Boolean) defaultValue));
            } else {
                return defaultValue;
            }
        } else {
            return defaultValue;
        }
    }

    @SuppressWarnings("unchecked")
    public static <T> T getPreference(Context context, String pName, String key, Class<T> cls) {
        if (cls.equals(String.class)) {
            return (T) getPreference(context, pName, key, "");
        } else if (cls.equals(Long.class)) {
            return (T) getPreference(context, pName, key, 0L);
        } else if (cls.equals(Integer.class)) {
            return (T) getPreference(context, pName, key, 0);
        } else if (cls.equals(Float.class)) {
            return (T) getPreference(context, pName, key, 0.0f);
        } else if (cls.equals(Boolean.class)) {
            return (T) getPreference(context, pName, key, false);
        }
        return null;
    }

    public static <T> void setPreference(Context context, String pName, String key, T value) {
        SharedPreferences sp = context
                .getSharedPreferences(pName, 0);
        Editor editor = sp.edit();
        if (value instanceof Boolean) {
            editor.putBoolean(key, (Boolean) value);
        } else if (value instanceof Integer) {
            editor.putInt(key, (Integer) value);
        } else if (value instanceof String) {
            editor.putString(key, (String) value);
        } else if (value instanceof Long) {
            editor.putLong(key, (Long) value);
        } else if (value instanceof Float) {
            editor.putFloat(key, (Float) value);
        }
        editor.commit();
    }

    public static void removePreference(Context context, String pName, String key) {
        SharedPreferences sp = context.getSharedPreferences(pName, 0);
        Editor editor = sp.edit();
        editor.remove(key);
        editor.commit();
    }

    public static Set<String> getAll(Context context, String pName) {
        SharedPreferences sp = context.getSharedPreferences(pName, 0);
        return sp.getAll().keySet();
    }

    @SuppressLint("NewApi")
    public static Set<String> getPreference(Context context, String pName, String key) {
        SharedPreferences sp = context.getSharedPreferences(pName, 0);
        return sp.getStringSet(key, null);
    }

    public static void clearDates(Context context, String pName) {
        SharedPreferences sp = context.getSharedPreferences(pName, 0);
        sp.edit().clear().commit();
    }

    public static void removedates(Context context, String pName, ArrayList<String> removeTimes) {
        SharedPreferences sp = context.getSharedPreferences(pName, 0);
        Editor editor = sp.edit();
        for (int i = 0; i < removeTimes.size(); i++) {
            editor.remove(removeTimes.get(i));
        }
        editor.commit();
    }

    @SuppressLint("NewApi")
    public static void setPreference(Context context, String pName, String key, Set<String> set) {
        SharedPreferences sp = context.getSharedPreferences(pName, 0);
        Editor editor = sp.edit();
        editor.putStringSet(key, set);
        editor.commit();
    }
}

