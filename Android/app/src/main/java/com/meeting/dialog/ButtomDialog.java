package com.meeting.dialog;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import com.example.meetingdemo.R;


/**
 * 自定义底部弹出对话框 Created by zhaomac on 2017/9/8.
 */

public class ButtomDialog extends Dialog {

	private boolean iscancelable;// 控制点击dialog外部是否dismiss
	private boolean isBackCancelable;// 控制返回键是否dismiss
	private View view;
	@SuppressWarnings("unused")
	private Context context;

	// 这里的view其实可以替换直接传layout过来的 因为各种原因没传(lan)
	public ButtomDialog(Context context, View view) {
		super(context, R.style.ButtomDialog);

		this.context = context;
		this.view = view;
		this.iscancelable = true;
		this.isBackCancelable = true;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(view);// 这行一定要写在前面
		setCancelable(iscancelable);// 点击外部不可dismiss
		setCanceledOnTouchOutside(isBackCancelable);
		Window window = this.getWindow();
		window.setGravity(Gravity.BOTTOM);
		WindowManager.LayoutParams params = window.getAttributes();
		params.width = WindowManager.LayoutParams.MATCH_PARENT;
		params.height = WindowManager.LayoutParams.WRAP_CONTENT;
		window.setAttributes(params);
	}
}