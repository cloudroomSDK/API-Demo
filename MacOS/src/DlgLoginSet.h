#ifndef DLGLOGINSET_H
#define DLGLOGINSET_H

#include "ui_DlgLoginSet.h"

class DlgLoginSet : public QDialog
{
	Q_OBJECT

public:
	struct SettingInfo
	{
		QString				server;
		CRVSDK_WEBPROTOCOL	httpType;
		CRVSDK_AUTHTYPE		authType;
		QString				loginAppID;	
		QString				loginAppSecret;
		QString				loginToken;	
		SettingInfo()
		{
			reset();
		}
		void reset()
		{
			server = "sdk.cloudroom.com";
			httpType = CRVSDK_WEBPTC_HTTP;
			authType = CRVSDK_AUTHTP_SECRET;
			loginAppID.clear();
			loginAppSecret.clear();
			loginToken = "";
		}
	};
	static void initSettingInfo();
	static SettingInfo getSettingInfo();

public:
	DlgLoginSet(QWidget *parent = 0);
	~DlgLoginSet();
	void resetUI();
	static void readCfgFile(SettingInfo &info);
	void writeCfgFile();

protected:
	void slot_btnResetClicked();
	void slot_btnSaveClicked();
	void slot_rbTokenCheckChanged();

private:
	static SettingInfo s_info;
	Ui::DlgLoginSet ui;
};

#endif // DLGLOGINSET_H
