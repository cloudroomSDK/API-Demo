#include "stdafx.h"
#include "DlgVoiceChange.h"
#include "maindialog.h"

VoiceChangeItem::VoiceChangeItem(QWidget *parent /*= 0*/)
	: QWidget(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);
	
	connect(ui.cbVoiceChoose, SIGNAL(currentIndexChanged(int)), this, SLOT(slot_voiceChooseChanged(int)));
}

void VoiceChangeItem::setUserInfo(const CRString &userId, const QString &nickname, int type)
{
	m_userId = userId;
	updateNickName(nickname);
	updateVoiceType(type);
}

void VoiceChangeItem::updateNickName(const QString &nickname)
{
	QString strUsername = nickname;
	if (m_userId == MainDialog::getMyUserID())
	{
		strUsername += tr("(我)");
	}
	ui.lblUsername->setText(strUsername);
}

void VoiceChangeItem::updateVoiceType(int type)
{
	//锁定信号，不发出s_voiceChanged消息
	this->blockSignals(true);
	ui.cbVoiceChoose->setCurrentIndex(type);
	this->blockSignals(false);
}

void VoiceChangeItem::slot_voiceChooseChanged(int index)
{
	g_sdkMain->getSDKMeeting().setVoiceChange(m_userId.constData(), (CRVSDK_VOICECHANGE_TYPE)index);
}

DlgVoiceChange::DlgVoiceChange(QWidget *parent)
	: QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this); 
	g_sdkMain->getSDKMeeting().AddCallBack(this);
}

DlgVoiceChange::~DlgVoiceChange()
{
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}

void DlgVoiceChange::notifyUserEnterMeeting(const char* userID)
{
	updateMemberList();
}

void DlgVoiceChange::notifyUserLeftMeeting(const char* userID)
{
	updateMemberList();
}

void DlgVoiceChange::notifyNickNameChanged(const char* userID, const char* oldName, const char* newName, const char* oprUserID)
{
	QString strNickname(newName);
	for (int i = 0; i < ui.userListWidget->count(); i++)
	{
		QListWidgetItem *pItem = ui.userListWidget->item(i);
		VoiceChangeItem *pWidget = static_cast<VoiceChangeItem*>(ui.userListWidget->itemWidget(pItem));
		CRString itemUserId = pWidget->getUserId();
		if (itemUserId == userID)
		{
			pWidget->updateNickName(strNickname);
			break;
		}
	}
}

void DlgVoiceChange::notifySetVoiceChange(const char* userID, int type, const char* oprUserID)
{
	for (int i = 0; i < ui.userListWidget->count(); i++)
	{
		QListWidgetItem *pItem = ui.userListWidget->item(i);
		VoiceChangeItem *pWidget = static_cast<VoiceChangeItem*>(ui.userListWidget->itemWidget(pItem));
		CRString itemUserId = pWidget->getUserId();
		if (itemUserId == userID)
		{
			int type = g_sdkMain->getSDKMeeting().getVoiceChangeType(userID);
			pWidget->updateVoiceType(type);
			break;
		}
	}
}

void DlgVoiceChange::showEvent(QShowEvent *evt)
{
	QDialog::showEvent(evt);

	updateMemberList();
}

void DlgVoiceChange::hideEvent(QHideEvent *evt)
{
	QDialog::hideEvent(evt);
	ui.userListWidget->clear();
}

void DlgVoiceChange::updateMemberList()
{
	ui.userListWidget->clear();
	CRBase::CRArray<CRMeetingMember> allMems = g_sdkMain->getSDKMeeting().getAllMembers();
	for (uint32_t i = 0; i < allMems.count(); i++)
	{
		const CRMeetingMember &mem = allMems.item(i);
		QListWidgetItem *pItem = new QListWidgetItem;
		ui.userListWidget->addItem(pItem);
		VoiceChangeItem *pUser = new VoiceChangeItem(this);
		int type = g_sdkMain->getSDKMeeting().getVoiceChangeType(mem._userId.constData());
		pUser->setUserInfo(mem._userId, crStrToQStr(mem._nickName), type);
		ui.userListWidget->setItemWidget(pItem, pUser);
	}

	for (int i = 0; i < ui.userListWidget->count(); i++)
	{
		QListWidgetItem *pItem = ui.userListWidget->item(i);
		pItem->setSizeHint(QSize(pItem->sizeHint().width(), 50));
	}
}