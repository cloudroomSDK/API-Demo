#ifndef DLGUSERSELECT_H
#define DLGUSERSELECT_H

#include "ui_DlgUserSelect.h"
#include "ui_UserItemWidget.h"

class UserItemWidget : public QWidget
{
	Q_OBJECT

public:
	UserItemWidget(QWidget *parent = 0);
	~UserItemWidget() {}

	void setUserInfo(const CRString &userId, const QString &nickname);
	CRString getUserId() { return m_userId; }

signals:
	void s_btnUserAttrsClicked();

private:
	Ui::UserItemWidget ui;

	CRString	m_userId;
};

class UserItem : public QListWidgetItem
{
public:
	UserItem()
	{
		// 不可被选择
		this->setFlags(this->flags() & ~Qt::ItemIsSelectable);
	}
	~UserItem() {}
};

class DlgUserSelect : public QDialog, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT

public:
	DlgUserSelect(QWidget *parent = 0);
	~DlgUserSelect();

protected:
	virtual void notifyUserEnterMeeting(const char* userID);
	virtual void notifyUserLeftMeeting(const char* userID);
	virtual void notifyNickNameChanged(const char* userID, const char* oldName, const char* newName, const char* oprUserID);

protected slots:
	void slot_btnUserAttrClicked();
	void slot_itemDoubleClicked(QListWidgetItem *pItem);

protected:
	void updateMemberList();

private:
	Ui::DlgUserSelect ui;
};

#endif // DLGUSERSELECT_H
