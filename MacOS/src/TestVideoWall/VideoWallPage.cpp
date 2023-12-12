#include "stdafx.h"
#include "VideoWallPage.h"
#include "KVideoUI.h"
#include "ui_VideoWallPage.h"
#include "maindialog.h"

VideoWallPage::VideoWallPage(QWidget* pParent) : QWidget(pParent)
{
	ui = new Ui::VideoWallPage;
	ui->setupUi(this);

	m_asMainMode = false;
	g_sdkMain->getSDKMeeting().AddCallBack(this);
}

VideoWallPage::~VideoWallPage()
{
	g_sdkMain->getSDKMeeting().RmCallBack(this);

	clearVideoUIS();
	delete ui;
}

void VideoWallPage::setVideoWallMode(bool asMain)
{
	if(asMain == m_asMainMode)
		return;

	m_asMainMode = asMain;
	ResetVideoUis();
}

void VideoWallPage::clearVideoUIS()
{
	while(m_videos.size()>0)
	{
		delVideoUI(m_videos[0]);
	}

}

void VideoWallPage::delVideoUI(KVideoUI* pUI)
{
	if ( pUI==NULL )
		return;

	m_videos.removeAll(pUI);
	pUI->clean();
	pUI->hide();
	m_freeVUIs.push_back(pUI);
}

KVideoUI* VideoWallPage::createVideoUI()
{
	//找到一个空的窗口
	KVideoUI* pVUi = NULL;
	if(m_freeVUIs.size()>0)
	{
		pVUi = m_freeVUIs[0];
		m_freeVUIs.pop_front();
	}
	else
	{
		pVUi = new KVideoUI(this);
	}

	return pVUi;
}

KVideoUI* VideoWallPage::findVideoUIByUserID(const char* userID)
{
	for(int i = 0; i < m_videos.size(); i++)
	{
		KVideoUI *pVUI = m_videos.at(i);
		if (pVUI->getUserId() == userID)
		{
			return pVUI;
		}
	}

	return NULL;
}

KVideoUI* VideoWallPage::findUnusedUI()
{
	for(int i = 0; i < m_videos.size(); i++)
	{
		KVideoUI *pVUI = m_videos.at(i);
		if(pVUI->getUserId().isEmpty())
		{
			return pVUI;
		}
	}

	return NULL;
}

KVideoUI* VideoWallPage::findLastUsedUI()
{
	int idx = m_videos.size() - 1;
	for(; idx > 0; idx--)
	{
		KVideoUI *pVUI = m_videos.at(idx);
		if(!pVUI->getUserId().isEmpty())
		{
			return pVUI;
		}
	}

	return NULL;
}

bool VideoWallPage::isWallPageFull()
{
	int videoCount = m_asMainMode ? 9 : 3;
	videoCount = qMin(videoCount, m_videos.size());
	for(int i = 0; i < videoCount; i++)
	{
		KVideoUI *pVUI = m_videos.at(i);
		if(pVUI->getUserId().isEmpty())
		{
			return false;
		}
	}
	return true;
}

void VideoWallPage::replaceByLastUsedUI(KVideoUI *pVUI)
{
	KVideoUI *pLastUsed = findLastUsedUI();
	if(NULL != pLastUsed && pLastUsed != pVUI)
	{
		pVUI->setVideoInfo(pLastUsed->getUsrCamID());
		pLastUsed->clean();
	}
	else
	{
		pVUI->clean();
	}
}

CRUserVideoID VideoWallPage::findUserNotInWall()
{
	CRUserVideoID uid;
	CRBase::CRArray<CRMeetingMember> allMems = g_sdkMain->getSDKMeeting().getAllMembers();
    for(uint32_t i = 0; i < allMems.count(); i++)
	{
		const CRMeetingMember &mem = allMems.item(i);
		KVideoUI *pTmp = findVideoUIByUserID(mem._userId.constData());
		if(NULL == pTmp)
		{
			uid._userID = mem._userId;
			break;
		}
	}

	return uid;
}

void VideoWallPage::MakeVideoUis()
{
	//删除所有旧的UI
	clearVideoUIS();

	int maxVideoCount = m_asMainMode ? 9 : 3;
	//获取所有人
	CRBase::CRArray<CRMeetingMember> allMems = g_sdkMain->getSDKMeeting().getAllMembers();
	CRBase::CRString myUserId = MainDialog::getMyUserID();

	//自己放到最前
	QList<CRUserVideoID> usrIds;
	{
		CRUserVideoID usrId;
		usrId._userID = myUserId;
		usrIds.push_front(usrId);
	}

    for(uint32_t i = 0; i < allMems.count(); i++)
	{
		const CRMeetingMember &mem = allMems.item(i);
		if(mem._userId == myUserId)
			continue;

		if(usrIds.size() >= maxVideoCount)
			break;

		CRUserVideoID usrId;
		usrId._userID = mem._userId;
		usrIds.push_back(usrId);
	}

	//不足，填空
	for(; usrIds.size() < maxVideoCount;)
	{
		CRUserVideoID usrId;
		usrIds.push_back(usrId);
	}

	//创建窗口
	for(int i = 0; i < usrIds.size(); i++)
	{
		KVideoUI* pVUi = createVideoUI();
		pVUi->updateNetState(g_sdkMain->getSDKMeeting().getNetState());
		m_videos.push_back(pVUi);

		const CRUserVideoID &usrId = usrIds.at(i);
		pVUi->setVideoInfo(usrId);
	}
}

void VideoWallPage::relayoutVideoWidgets_H()
{
	//锁毁之前的布局
	QLayout* oldLayout = ui->WidgetClient->layout();
	if (oldLayout)
	{
		delete oldLayout;
	}

	//新的布局
	QGridLayout* mainLayout = new QGridLayout(ui->WidgetClient);
	mainLayout->setContentsMargins(0, 0, 0, 0);
	mainLayout->setSpacing(VIDEO_WALL_SPACE);
	int videoCount = m_videos.size();
	if(videoCount <= 3)
	{
		mainLayout->addWidget(m_videos[0], 0, 0, Qt::AlignCenter);
		mainLayout->addWidget(m_videos[1], 0, 1, Qt::AlignCenter);
		mainLayout->addWidget(m_videos[2], 0, 2, Qt::AlignCenter);
	}
	else
	{
		// 3行
		int rowCount = 3, colCount = 3;
		for(int i = 0; i < rowCount; i++)
		{
			for(int j = 0; j < colCount; j++)
			{
				mainLayout->addWidget(m_videos[i * 3 + j], i, j, Qt::AlignCenter);
			}
		}
	}

	for(int i=0; i<m_videos.size(); i++)
	{
		m_videos[i]->show();
	}
}

void VideoWallPage::ResetVideoUis()
{
	//重新生成小窗口
	MakeVideoUis();
	resetVideoWidgetSize();
	emit s_contentChanged();
}

void VideoWallPage::resetVideoWidgetSize()
{
	resetVideoWidgetSize_H();
	relayoutVideoWidgets_H();
}

void VideoWallPage::resetVideoWidgetSize_H()
{
	int clientWidth = this->width();
	int clientHeight = 0;

	//先按宽估计videoUI大小
	int videoUIW = (clientWidth - 2 * VIDEO_WALL_SPACE) / 3;
	int videoUIH = (videoUIW * 9 / 16.0 + 0.5);
	
	if (m_videos.size()<=3)	// 1排显示
	{
		clientHeight = videoUIH;
	}
	else // 3排显示
	{
		clientHeight = videoUIH * 3 + 2 * VIDEO_WALL_SPACE;
		//如果按宽估算超高了， 切成按高计算
		if (clientHeight > this->height())
		{
			videoUIH = (this->height() - 2 * VIDEO_WALL_SPACE) / 3;
			videoUIW = (videoUIH * 16 / 9.0 + 0.5);
			clientHeight = this->height();
			clientWidth = videoUIW * 3 + 2 * VIDEO_WALL_SPACE;
		}
	}

	//设置每个videoUI的大小
	for (int i = 0; i < m_videos.size(); i++)
	{
		m_videos[i]->setFixedSize(videoUIW, videoUIH);
	}

	//
	ui->WidgetClient->setFixedSize(clientWidth, clientHeight);
	ui->WidgetClient->move(0, 0);
	this->setMinimumHeight(videoUIH);
}

void VideoWallPage::resizeEvent(QResizeEvent *event)
{
	resetVideoWidgetSize();
	emit s_contentChanged();
}


void VideoWallPage::notifyNetStateChanged(int level)
{
	KVideoUI *pVUI = findVideoUIByUserID(MainDialog::getMyUserID().constData());
	if(NULL == pVUI)
		return;

	pVUI->updateNetState(level);
}

void VideoWallPage::notifyUserEnterMeeting(const char* userID)
{
	KVideoUI *pVUI = findVideoUIByUserID(userID);
	if(NULL != pVUI)
		return;

	KVideoUI *pUnused = findUnusedUI();
	if(NULL != pUnused)
	{
		pUnused->setVideoInfo(userID);
		emit s_contentChanged();
	}
}

void VideoWallPage::notifyUserLeftMeeting(const char* userID)
{
	KVideoUI *pVUI = findVideoUIByUserID(userID);
	if(NULL == pVUI)
		return;

	if(isWallPageFull())
	{
		CRUserVideoID uid = findUserNotInWall();
		if(!uid._userID.isEmpty())
		{
			pVUI->setVideoInfo(uid);
		}
		else
		{
			replaceByLastUsedUI(pVUI);
		}
	}
	else
	{
		replaceByLastUsedUI(pVUI);
	}

	emit s_contentChanged();
}

void VideoWallPage::notifyNickNameChanged(const char* userID, const char* oldName, const char* newName, const char* oprUserID)
{
	KVideoUI *pVUI = findVideoUIByUserID(userID);
	if(NULL != pVUI)
	{
		pVUI->updateNickname(QString::fromLocal8Bit(newName));
		emit s_contentChanged();
	}
}

void VideoWallPage::notifyMicStatusChanged(const char* userID, CRVSDK_ASTATUS oldStatus, CRVSDK_ASTATUS newStatus, const char* oprUserID)
{
	KVideoUI *pVUI = findVideoUIByUserID(userID);
	if(NULL != pVUI)
	{
		pVUI->updateMicStatus(newStatus);
	}
}

void VideoWallPage::notifyMicEnergy(const char* userID, int oldLevel, int newLevel)
{
	KVideoUI *pVUI = findVideoUIByUserID(userID);
	if(NULL != pVUI)
	{
		pVUI->updateMicEnergy(newLevel);
	}
}

void VideoWallPage::notifyVideoStatusChanged(const char* userID, CRVSDK_VSTATUS oldStatus, CRVSDK_VSTATUS newStatus, const char* oprUserID)
{
	KVideoUI *pVUI = findVideoUIByUserID(userID);
	if(NULL != pVUI)
	{
		pVUI->updateCamStatus((CRVSDK_VSTATUS)newStatus);
		emit s_contentChanged();
	}
}

