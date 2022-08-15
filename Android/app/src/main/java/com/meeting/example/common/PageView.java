package com.meeting.example.common;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.util.AttributeSet;
import android.view.View;
import android.widget.RelativeLayout;

import com.cloudroom.cloudroomvideosdk.model.MixerCotent;
import com.cloudroom.cloudroomvideosdk.model.Size;

import java.util.ArrayList;

public abstract class PageView extends RelativeLayout {
	
	public interface PageCallback {
		void uiContentChanged();
	}
	
	protected PageCallback mPageCallback = null;

	public PageView(Context context) {
		super(context);
	}

	public PageView(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
	}

	public PageView(Context context, AttributeSet attrs, int defStyleAttr) {
		super(context, attrs, defStyleAttr);
		// TODO Auto-generated constructor stub
	}

	@SuppressLint("NewApi")
	public PageView(Context context, AttributeSet attrs, int defStyleAttr,
                    int defStyleRes) {
		super(context, attrs, defStyleAttr, defStyleRes);
		// TODO Auto-generated constructor stub
	}

	public void setPageCallback(PageCallback pageCallback) {
		this.mPageCallback = pageCallback;
	}

	public abstract void addMixerCotents(Size recSiz, boolean bLocalMixer, ArrayList<MixerCotent> contents);
	
	public abstract boolean onViewClick(View v, int vID);

	public abstract boolean onActivityResult(int requestCode, int resultCode,
			Intent data);
}
