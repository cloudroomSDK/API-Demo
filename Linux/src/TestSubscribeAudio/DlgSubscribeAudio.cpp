#include "stdafx.h"
#include "DlgSubscribeAudio.h"

//全局保存，退出房间后，配置不删除
DlgSubscribeAudio::SubInfo DlgSubscribeAudio::m_info = DlgSubscribeAudio::SubInfo();
DlgSubscribeAudio::DlgSubscribeAudio(QWidget *parent)
	: QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);	

	g_sdkMain->getSDKMeeting().AddCallBack(this);
	init();

	connect(ui.buttonGroup, SIGNAL(buttonClicked(int)), this, SLOT(slot_modeChanged()));
	connect(ui.buttonGroup_2, SIGNAL(buttonClicked(int)), this, SLOT(slot_listTpyeChanged()));
	connect(ui.listMembers, &QListWidget::itemDoubleClicked, this, &DlgSubscribeAudio::slot_listMembersClicked);
	connect(ui.listSubs, &QListWidget::itemDoubleClicked, this, &DlgSubscribeAudio::slot_listSubsClicked);
}

DlgSubscribeAudio::~DlgSubscribeAudio()
{
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}


void DlgSubscribeAudio::init()
{	
	//按钮状态
	ui.rbMixMode->setChecked(m_info.mode == CRVSDK_ASM_MIXED);
	ui.rbSeparateMode->setChecked(m_info.mode == CRVSDK_ASM_SEPARATE);
	ui.rbIncludeList->setChecked(m_info.listType == CRVSDK_ASLT_INCLUDE);
	ui.rbExcludeList->setChecked(m_info.listType == CRVSDK_ASLT_EXCLUDE);
	ui.widgetSeparate->setEnabled(m_info.mode == CRVSDK_ASM_SEPARATE);

	//加载所有成员
	CRBase::CRArray<CRMeetingMember> allMems = g_sdkMain->getSDKMeeting().getAllMembers();
	for (uint32_t i = 0; i < allMems.count(); i++)
	{
		const CRMeetingMember &mem = allMems.item(i);
		QListWidgetItem *pItem = new QListWidgetItem();
		pItem->setText(crStrToQStr(mem._nickName));
		pItem->setData(Qt::UserRole + 1, crStrToQStr(mem._userId));
		ui.listMembers->addItem(pItem);
	}

	//加载订阅列表
	for (auto &userInfo : m_info.subUserList)
	{
		QListWidgetItem *pItem = new QListWidgetItem();
		pItem->setText(userInfo.nickName);
		pItem->setData(Qt::UserRole + 1, userInfo.userId);
		ui.listSubs->addItem(pItem);
	}
}

void DlgSubscribeAudio::slot_modeChanged()
{
	//模式改变
	m_info.mode = ui.rbSeparateMode->isChecked() ? CRVSDK_ASM_SEPARATE : CRVSDK_ASM_MIXED;
	ui.widgetSeparate->setEnabled(m_info.mode == CRVSDK_ASM_SEPARATE);

	g_sdkMain->getSDKMeeting().setAudioSubscribeMode(m_info.mode);
	setSubListToSdk();
}

void DlgSubscribeAudio::slot_listTpyeChanged()
{
	//订阅列表类型
	m_info.listType = ui.rbExcludeList->isChecked() ? CRVSDK_ASLT_EXCLUDE : CRVSDK_ASLT_INCLUDE;
	setSubListToSdk();
}	

void DlgSubscribeAudio::slot_listMembersClicked(QListWidgetItem *item)
{
	QList<QListWidgetItem*> findList = ui.listSubs->findItems(item->text(), Qt::MatchCaseSensitive);
	for (auto &pItem : findList)
	{
		delete pItem;
	}

	ui.listSubs->addItem(item->clone());
	m_info.subUserList = getSubListFromUI();
	setSubListToSdk();
}

void DlgSubscribeAudio::slot_listSubsClicked(QListWidgetItem *item)
{
	delete item;
	m_info.subUserList = getSubListFromUI();
	setSubListToSdk();
}

void DlgSubscribeAudio::setSubListToSdk()
{
	if (m_info.subUserList.size() == 0)
	{
		g_sdkMain->getSDKMeeting().setAudioSubscribeListForSeparateMode(m_info.listType, NULL);
		return;
	}
	//构造数据
	int count = m_info.subUserList.size();
	QString ids;
	for (auto &info : m_info.subUserList)
	{
		if (!ids.isEmpty())
		{
			ids += ";";
		}
		ids += info.userId;

	}
	
	//设置订阅列表
	g_sdkMain->getSDKMeeting().setAudioSubscribeListForSeparateMode(m_info.listType, ids.toUtf8().constData());
}

QList<DlgSubscribeAudio::UserInfo> DlgSubscribeAudio::getSubListFromUI()
{
	QList<DlgSubscribeAudio::UserInfo> rslt;
	for (int i = 0; i < ui.listSubs->count(); i++)
	{
		DlgSubscribeAudio::UserInfo info;
		QListWidgetItem *pItem = ui.listSubs->item(i);
		info.userId = pItem->data(Qt::UserRole + 1).toString();
		info.nickName = pItem->text();
		rslt.append(info);
	}
	return rslt;
}