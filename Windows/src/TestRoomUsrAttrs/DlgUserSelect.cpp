#include "stdafx.h"
#include "DlgUserSelect.h"
#include "DlgUserAttrs.h"
#include "maindialog.h"


UserItemWidget::UserItemWidget(QWidget *parent /*= 0*/)
	: QWidget(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);
	connect(ui.btnUserAttrs, &QPushButton::clicked, this, &UserItemWidget::s_btnUserAttrsClicked);
}

void UserItemWidget::setUserInfo(const CRString &userId, const QString &nickname)
{
	m_userId = userId;
	QString strUsername = nickname;
	if(m_userId == MainDialog::getMyUserID())
	{
		strUsername += tr("(我)");
	}
	ui.lblUsername->setText(strUsername);
}

DlgUserSelect::DlgUserSelect(QWidget *parent)
	: QDialog(parent)
{
	ui.setupUi(this);
	connect(ui.userListWidget, &QListWidget::itemDoubleClicked, this, &DlgUserSelect::slot_itemDoubleClicked);

	g_sdkMain->getSDKMeeting().AddCallBack(this);
	updateMemberList();
}

DlgUserSelect::~DlgUserSelect()
{
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}

void DlgUserSelect::notifyUserEnterMeeting(const char* userID)
{
	updateMemberList();
}

void DlgUserSelect::notifyUserLeftMeeting(const char* userID)
{
	updateMemberList();
}

void DlgUserSelect::notifyNickNameChanged(const char* userID, const char* oldName, const char* newName, const char* oprUserID)
{
	QString strNickname(newName);
	for (int i = 0; i < ui.userListWidget->count(); i++)
	{
		QListWidgetItem *pItem = ui.userListWidget->item(i);
		UserItemWidget *pWidget = static_cast<UserItemWidget*>(ui.userListWidget->itemWidget(pItem));
		CRString itemUserId = pWidget->getUserId();
		if (itemUserId == userID)
		{
			pWidget->setUserInfo(itemUserId, strNickname);
			break;
		}
	}
}

void DlgUserSelect::slot_btnUserAttrClicked()
{
	UserItemWidget *pUser = static_cast<UserItemWidget*>(sender());
	DlgUserAttrs *pUserAttrs = new DlgUserAttrs(pUser->getUserId(), g_mainDialog);
	pUserAttrs->show();
	this->close();
}

void DlgUserSelect::slot_itemDoubleClicked(QListWidgetItem *pItem)
{
	UserItemWidget *pUser = static_cast<UserItemWidget*>(ui.userListWidget->itemWidget(pItem));
	DlgUserAttrs *pUserAttrs = new DlgUserAttrs(pUser->getUserId(), g_mainDialog);
	pUserAttrs->show();
	this->close();
}

void DlgUserSelect::updateMemberList()
{
	ui.userListWidget->clear();
	CRBase::CRArray<CRMeetingMember> allMems = g_sdkMain->getSDKMeeting().getAllMembers();
    for(uint32_t i = 0; i < allMems.count(); i++)
	{
		const CRMeetingMember &mem = allMems.item(i);
		UserItem *pItem = new UserItem;
		ui.userListWidget->addItem(pItem);
		UserItemWidget *pUser = new UserItemWidget(this);
		pUser->setUserInfo(mem._userId, crStrToQStr(mem._nickName));
		connect(pUser, &UserItemWidget::s_btnUserAttrsClicked, this, &DlgUserSelect::slot_btnUserAttrClicked);
		ui.userListWidget->setItemWidget(pItem, pUser);
	}

	for(int i = 0; i < ui.userListWidget->count(); i++)
	{
		QListWidgetItem *pItem = ui.userListWidget->item(i);
		pItem->setSizeHint(QSize(pItem->sizeHint().width(), 40));
	}
}
