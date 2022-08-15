package com.meeting.example.tool;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnDismissListener;
import android.graphics.BitmapFactory;
import android.text.Editable;
import android.text.Selection;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.cloudroom.tool.AndroidTool;
import com.example.meetingdemo.R;
import com.meeting.dialog.ButtomDialog;
import com.meeting.example.common.WheelView;

import java.util.ArrayList;

@SuppressLint("InflateParams")
public class UITool {

	private static final String TAG = "UITool";

	public static ArrayList<String> getStringArray(Context context, int arrayID) {
		String[] array = context.getResources().getStringArray(arrayID);
		ArrayList<String> list = new ArrayList<String>();
		for (String str : array) {
			list.add(str);
		}
		return list;
	}

	public interface ConfirmDialogCallback {
		void onOk();

		void onCancel();
	}

	private static class ConfirmDialog extends Dialog {

		public boolean ok = false;

		public ConfirmDialog(Context context, int theme) {
			super(context, theme);
			// TODO Auto-generated constructor stub
		}

	}

	public static Dialog showConfirmDialog(Activity activity, String message,
                                           ConfirmDialogCallback callback) {
		return showConfirmDialog(activity, message, callback, true);
	}

	public static Dialog showConfirmDialog(Activity activity, String message,
                                           final ConfirmDialogCallback callback, boolean cancelable) {
		final ConfirmDialog confirmDialog = new ConfirmDialog(activity,
				R.style.ConfirmDialog);
		confirmDialog.setCancelable(cancelable);
		confirmDialog.setOwnerActivity(activity);
		View view = LayoutInflater.from(activity).inflate(
				R.layout.layout_confirm_dailog, null);
		// 显示视频需要启用hardwareAccelerated，某些设备会导致控件花屏，需要把不需要使用硬件加速的控件关闭硬件加速功能
		view.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
		confirmDialog.setContentView(view);
		TextView msgTV = (TextView) view.findViewById(R.id.tv_message);
		msgTV.setText(message);
		view.findViewById(R.id.cancel).setOnClickListener(
				new OnClickListener() {

					@Override
					public void onClick(View v) {
						// TODO Auto-generated method stub
						confirmDialog.dismiss();
					}
				});
		view.findViewById(R.id.ok).setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				callback.onOk();
				confirmDialog.ok = true;
				confirmDialog.dismiss();
			}
		});
		confirmDialog.setOnDismissListener(new OnDismissListener() {

			@Override
			public void onDismiss(DialogInterface dialog) {
				// TODO Auto-generated method stub
				if (!confirmDialog.ok) {
					callback.onCancel();
				}
			}
		});
		confirmDialog.show();
		return confirmDialog;
	}

	public static void showMessageDialog(Activity activity, String message,
                                         final ConfirmDialogCallback callback) {
		try {
			final Dialog dialog = new Dialog(activity, R.style.ConfirmDialog);
			dialog.setCancelable(false);
			dialog.setOwnerActivity(activity);
			View view = LayoutInflater.from(activity).inflate(
					R.layout.layout_confirm_dailog, null);
			// 显示视频需要启用hardwareAccelerated，某些设备会导致控件花屏，需要把不需要使用硬件加速的控件关闭硬件加速功能
			view.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
			dialog.setContentView(view);
			TextView msgTV = (TextView) view.findViewById(R.id.tv_message);
			msgTV.setText(message);
			view.findViewById(R.id.cancel).setVisibility(View.GONE);
			view.findViewById(R.id.ok).setOnClickListener(
					new OnClickListener() {

						@Override
						public void onClick(View v) {
							// TODO Auto-generated method stub
							dialog.dismiss();
						}
					});
			dialog.setOnDismissListener(new OnDismissListener() {

				@Override
				public void onDismiss(DialogInterface dialog) {
					// TODO Auto-generated method stub
					callback.onOk();
				}
			});
			dialog.show();
		} catch (Exception e) {
			Log.d(TAG, "showMessageDialog fail");
		}
	}

	private static Dialog mProcessDialog = null;

	public static void showProcessDialog(Activity activity, String message) {
		hideProcessDialog(activity);
		try {
			mProcessDialog = new Dialog(activity, R.style.ConfirmDialog);
			mProcessDialog.setCancelable(false);
			mProcessDialog.setOwnerActivity(activity);
			View view = LayoutInflater.from(activity).inflate(
					R.layout.layout_confirm_dailog, null);
			// 显示视频需要启用hardwareAccelerated，某些设备会导致控件花屏，需要把不需要使用硬件加速的控件关闭硬件加速功能
			view.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
			mProcessDialog.setContentView(view);
			TextView msgTV = (TextView) view.findViewById(R.id.tv_message);
			msgTV.setText(message);
			view.findViewById(R.id.cancel).setVisibility(View.GONE);
			view.findViewById(R.id.ok).setVisibility(View.GONE);
			mProcessDialog.show();
		} catch (Exception e) {
			e.printStackTrace();
			Log.d(TAG, "showProcessDialog fail");
			mProcessDialog = null;
		}
	}

	public static void hideProcessDialog(Activity activity) {
		try {
			if (mProcessDialog != null) {
				Activity at = mProcessDialog.getOwnerActivity();
				if (at != activity) {
					return;
				}
				mProcessDialog.dismiss();
			}
		} catch (Exception e) {
			e.printStackTrace();
			Log.d(TAG, "hideProcessDialog fail");
		}
		mProcessDialog = null;
	}

	public interface InputDialogCallback {
		void onInput(String info);

		void onCancel();
	}

	public static void showInputDialog(Context context, String hint,
                                       InputDialogCallback callback) {
		showInputDialog(context, hint, -1, callback);
	}

	public static void showInputDialog(Context context, String hint,
                                       int inputType, final InputDialogCallback callback) {
		showInputDialog(context, hint, "", inputType, callback);
	}

	public static void showInputDialog(Context context, String hint,
                                       String defaultText, final InputDialogCallback callback) {
		showInputDialog(context, hint, defaultText, -1, callback);
	}

	public static void showInputDialog(Context context, String hint,
                                       String defaultText, int inputType,
                                       final InputDialogCallback callback) {
		try {
			final Dialog dialog = new Dialog(context, R.style.ConfirmDialog);
			dialog.setCancelable(false);
			View view = LayoutInflater.from(context).inflate(
					R.layout.layout_input_dailog, null);
			dialog.setContentView(view);
			final EditText inputET = (EditText) view
					.findViewById(R.id.et_input);
			inputET.setText(defaultText);
			Editable text = inputET.getText();
			Selection.setSelection(text, text.length());
			
			inputET.setHint(hint);
			if (inputType > 0) {
				inputET.setInputType(inputType);
			}
			TextView btnCancel = (TextView) view.findViewById(R.id.cancel);
			TextView btnOK = (TextView) view.findViewById(R.id.ok);

			btnCancel.setText(R.string.cacel);
			btnOK.setText(R.string.ok);
			btnCancel.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					// TODO Auto-generated method stub
					callback.onCancel();
					dialog.dismiss();
				}
			});
			btnOK.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					// TODO Auto-generated method stub
					String info = inputET.getEditableText().toString();
					callback.onInput(info);
					dialog.dismiss();
				}
			});
			dialog.show();
			fixDialogWidth(dialog);
		} catch (Exception e) {
			Log.d(TAG, "showInputDialog fail");
		}
	}

	private static void fixDialogWidth(Dialog dialog) {
		WindowManager.LayoutParams params = dialog.getWindow().getAttributes();
		params.width = AndroidTool.dip2px(dialog.getContext(), 240);
		params.height = WindowManager.LayoutParams.WRAP_CONTENT;
		dialog.getWindow().setAttributes(params);
	}

	public static void showPicDialog(Context context, String filePathName) {
		Dialog dialog = new Dialog(context, R.style.ConfirmDialog);
		dialog.setCancelable(true);
		ImageView view = new ImageView(context);
		try {
			view.setImageBitmap(BitmapFactory.decodeFile(filePathName));
		} catch (Exception e) {
		}
		int size = AndroidTool.dip2px(context, 200);
		dialog.setContentView(view, new ViewGroup.LayoutParams(size, size));
		dialog.show();
	}

	public interface SelectListener {
		void onSelect(int index, String item);
	}

	@SuppressLint("InflateParams")
	public static void showSingleChoiceDialog(Context context, String title,
                                              ArrayList<String> items, String curValue,
                                              final SelectListener selectListener) {
		View view = LayoutInflater.from(context).inflate(
				R.layout.layout_select_dailog, null);
		TextView cancelBtn = (TextView) view.findViewById(R.id.cancel);
		TextView okBtn = (TextView) view.findViewById(R.id.ok);
		TextView titleView = (TextView) view.findViewById(R.id.title);
		final WheelView wheelView = (WheelView) view
				.findViewById(R.id.view_wheel);

		titleView.setText(title);
		wheelView.setItems(items);

		int curIndex = items.indexOf(curValue);
		if (curIndex <= 0) {
			curIndex = 0;
		}
		wheelView.setSeletion(curIndex);

		final ButtomDialog dialog = new ButtomDialog(context, view);

		cancelBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				dialog.dismiss();
			}
		});
		okBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				selectListener.onSelect(wheelView.getSeletedIndex(),
						wheelView.getSeletedItem());
				dialog.dismiss();
			}
		});

		dialog.show();
	}

	public static int getResourceId(Context context, String resType,
                                    String resName) {
		if (context == null) {
			Log.w(TAG, "getResourceId context is null");
		}
		try {
			int sourceId = context.getResources().getIdentifier(resName,
					resType, context.getPackageName());
			return sourceId;
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return 0;
	}

	public static int getResourceId(Context context, String resClassAndName) {
		if (context == null) {
			Log.w(TAG, "getResourceId context is null");
		}
		try {
			String[] strs = resClassAndName.split("\\.");
			if (strs.length == 3) {
				String resType = strs[1];
				String resName = strs[2];
				return AndroidTool.getResourceId(context, resType, resName);
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			// e.printStackTrace();
		}
		return 0;
	}

	public static String LoadString(Context context, String resName) {
		if (context == null) {
			Log.w(TAG, "LoadString context is null");
		}
		String str = "";
		int strId = AndroidTool.getResourceId(context, "string", resName);
		if (strId > 0) {
			str = context.getResources().getString(strId);
		}
		return str;
	}
}
