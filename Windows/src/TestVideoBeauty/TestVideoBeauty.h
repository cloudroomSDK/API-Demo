#ifndef TESTVIDEOBEAUTY_H
#define TESTVIDEOBEAUTY_H

#include <QWidget>
#include "ui_TestVideoBeauty.h"

class TestVideoBeauty : public QDialog, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT

public:
	TestVideoBeauty(QWidget *parent = 0);
	~TestVideoBeauty();

protected slots:
	void slot_enableBeautyStateChanged(int v);
	void slot_sliderValueChanged(int v);
	void slot_filterTypeChanged(int v);

protected:
	void notifyVideoStatusChanged(const char* userID, CRVSDK_VSTATUS oldStatus, CRVSDK_VSTATUS newStatus, const char* oprUserID) override;
	void updateCombBoxItemStr();
	void updateCombBoxItemStr(int index, float lv);
	void setCfgToSDK(const BeautyCfg &cfg);
	float getTypeLevel(const BeautyCfg &cfg, BeautyFilterType type);

private:
	Ui::TestVideoBeauty ui;
	BeautyCfg _cfg;

};

#endif // TESTVIDEOBEAUTY_H
