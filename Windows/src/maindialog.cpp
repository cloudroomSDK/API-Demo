#include "stdafx.h"
#include "maindialog.h"
#include "ui_maindialog.h"
#include "./TestLocRecord/DlgLocalRecord.h"
#include "./TestSvrRecord/DlgServerRecord.h"
#include "./TestVideoWall/KVideoUI.h"
#include "./TestVideoWall/VideoWallPage.h"
#include "./TestCustomAudioCapture/CustomAudioCapture.h"
#include "./TestCustomVideoCaptureRender/CustomVideoCaptureRender.h"
#include "./TestMediaPlay/MediaPlayUI.h"
#include "./TestScreenShare/ScreenShareUI.h"
#include "./TestAudioSetting/DlgAudioSet.h"
#include "./TestVideoSetting/DlgVideoSet.h"
#include "./TestRoomMsg/DlgRoomMsg.h"
#include "./TestRoomUsrAttrs/DlgUserSelect.h"
#include "./TestRoomUsrAttrs/DlgRoomAttrs.h"
#include "./TestRoomUsrAttrs/DlgUserAttrs.h"
#include "./TestNetCamera/DlgNetCamera.h"
#include "./TestVoiceChange/DlgVoiceChange.h"
#include "./TestEchoTest/DlgEchoTest.h"


MainDialog *g_mainDialog = NULL;
CRString MainDialog::m_myUserId;
int MainDialog::m_meetId = 0;

MainDialog::MainDialog(QWidget *parent, int meetId, const QString &userId)
	: QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint | Qt::WindowMinMaxButtonsHint), ui(new Ui::MainDialog)
{
	g_mainDialog = this;
	m_meetId = meetId;
	m_myUserId = qStrToCRStr(userId);

	ui->setupUi(this);
	setWindowTitle(tr("房间号：%1").arg(meetId));

	m_dlgLocRecord = NULL;
	m_dlgSvrRecord = NULL;
	m_customAudioCapture = NULL;
	m_customVideoCaptureRender = NULL;
	m_mediaPlayUI = NULL;
	m_screeShareUI = NULL;
	m_videoWallPage = NULL;
	m_dlgRoomAttrs = NULL;
	m_dlgUserSelect = NULL;
	m_dlgNetCamera = NULL;

	//入会就开始收消息
	m_dlgRoomMsg = new DlgRoomMsg(this);
	m_dlgSvrRecord = new DlgServerRecord(this);

	connect(ui->btnBaseFunc, &QPushButton::clicked, this, &MainDialog::slot_btnBaseFuncClicked);
	connect(ui->btnHigherFunc, &QPushButton::clicked, this, &MainDialog::slot_btnHigherFuncClicked);
	connect(ui->btnAudioSet, &QPushButton::clicked, this, &MainDialog::slot_btnAudioSetClicked);
	connect(ui->btnVideoSet, &QPushButton::clicked, this, &MainDialog::slot_btnVideoSetClicked);
	connect(ui->btnLocRecord, &QPushButton::clicked, this, &MainDialog::slot_btnLocRecordClicked);
	connect(ui->btnSvrRecord, &QPushButton::clicked, this, &MainDialog::slot_btnSvrRecordClicked);
	connect(ui->btnMedia, &QPushButton::clicked, this, &MainDialog::slot_btnMediaClicked);
	connect(ui->btnCustomAudio, &QPushButton::clicked, this, &MainDialog::slot_btnCustomAudioClicked);
	connect(ui->btnCustomVideo, &QPushButton::clicked, this, &MainDialog::slot_btnCustomVideoClicked);
	connect(ui->btnRoomMsg, &QPushButton::clicked, this, &MainDialog::slot_btnRoomMsgClicked);
	connect(ui->btnRoomSet, &QPushButton::clicked, this, &MainDialog::slot_btnRoomSetClicked);
	connect(ui->btnMemberSet, &QPushButton::clicked, this, &MainDialog::slot_btnMemberSetClicked);
	connect(ui->btnNetCamera, &QPushButton::clicked, this, &MainDialog::slot_btnNetCameraClicked);
	connect(ui->btnVoiceChange, &QPushButton::clicked, this, &MainDialog::slot_btnVoiceChangeClicked);
	connect(ui->btnEchoTest, &QPushButton::clicked, this, &MainDialog::slot_btnEchoTestClicked);
	connect(ui->btnStartScreenShare, &QPushButton::clicked, this, &MainDialog::slot_btnStartScreenClicked);
	connect(ui->btnStopScreenShare, &QPushButton::clicked, this, &MainDialog::slot_btnStopScreenClicked);

	QLayout *pLayout = ui->mainFuncWidget->layout();
	pLayout->setSpacing(VIDEO_WALL_SPACE);

	m_mediaPlayUI = new MediaPlayUI(this);
	m_mediaPlayUI->hide();
	pLayout->addWidget(m_mediaPlayUI);
	connect(m_mediaPlayUI, &MediaPlayUI::s_mediaPlaying, this, &MainDialog::slot_mediaPlaying);

	ui->btnStopScreenShare->hide();
	m_screeShareUI = new ScreenShareUI(this);
	m_screeShareUI->hide();
	pLayout->addWidget(m_screeShareUI);
	connect(m_screeShareUI, &ScreenShareUI::s_shareStateChanged, this, &MainDialog::slot_screenShareStateChanged);

	m_videoWallPage = new VideoWallPage(this);
	m_videoWallPage->setVideoWallMode(true);
	pLayout->addWidget(m_videoWallPage);
	connect(m_videoWallPage, &VideoWallPage::s_contentChanged, this, &MainDialog::s_viewChanged);

	QIcon upIcon(":/Resources/arrowUp.png");
	QIcon downIcon(":/Resources/arrowDown.png");
	ui->btnBaseFunc->setIcon(upIcon);
	ui->btnHigherFunc->setIcon(downIcon);
	ui->higherFuncWidget->setVisible(false);

	//开麦、开摄像头
	g_sdkMain->getSDKMeeting().openMic(MainDialog::getMyUserID().constData());
	g_sdkMain->getSDKMeeting().openVideo(MainDialog::getMyUserID().constData());

}

MainDialog::~MainDialog()
{
	g_mainDialog = NULL;
    delete ui;
}

QVariant MainDialog::getRecordContents(const QSize &recSize)
{
 	QVariantList contents;
	int contentYPos = 0;

	//按9宫格摆视频来计算位置(以下计算中，位置宽高均为2的倍数，能避免混图之后间隙不均匀现象）
	int videoUIH = ((recSize.height() - 2 * VIDEO_WALL_SPACE) / 3) & 0xFFFFFFFE;
	int videoUIW = (int(videoUIH * 16 / 9.0 + 0.5)) & 0xFFFFFFFE;

	//屏幕共享中
	if (m_screeShareUI->isVisibleTo(this))
	{
		int screenH = (recSize.height() - videoUIH - VIDEO_WALL_SPACE) & 0xFFFFFFFE;
		QVariantMap item;
		item["type"] = CRVSDK_MIXCONT_SCREEN_SHARED;
		item["left"] = 0;
		item["top"] = 0;
		item["width"] = recSize.width();
		item["height"] = screenH;
		item["keepAspectRatio"] = 1;
		contents.append(item);

		contentYPos += screenH + VIDEO_WALL_SPACE;
	}

	//影音共享中
	if (m_mediaPlayUI->isVisibleTo(this))
	{
		int mediaH = (recSize.height() - videoUIH - VIDEO_WALL_SPACE) & 0xFFFFFFFE;
		QVariantMap item;
		item["type"] = CRVSDK_MIXCONT_MEDIA;
		item["left"] = 0;
		item["top"] = 0;
		item["width"] = recSize.width();
		item["height"] = mediaH;
		item["keepAspectRatio"] = 1;
		contents.append(item);

		contentYPos += mediaH + VIDEO_WALL_SPACE;
	}

	//视频墙
	QList<KVideoUI*> vuis = m_videoWallPage->getVideos();
	for (int row = 0; row < 3 && vuis.size()>0; row++)
	{
		int contentXPos = 0;
		for (int col = 0; col < 3 && vuis.size()>0; col++)
		{
			QVariantMap itemParams;
			itemParams["camid"] = QString("%1.-1").arg(vuis.front()->getUserId().constData());
			vuis.pop_front();

			QVariantMap itemVideo;
			itemVideo["type"] = CRVSDK_MIXCONT_VIDEO;
			itemVideo["left"] = contentXPos;
			itemVideo["top"] = contentYPos;
			itemVideo["width"] = videoUIW;
			itemVideo["height"] = videoUIH;
			itemVideo["param"] = itemParams;
			itemVideo["keepAspectRatio"] = 1;
			contents.append(itemVideo);

			contentXPos += videoUIW + VIDEO_WALL_SPACE;
		}
		contentYPos += videoUIH + VIDEO_WALL_SPACE;
	}

    //时间戳
    {
        QVariantMap item;
        item["type"] = CRVSDK_MIXCONT_TEXT;
        item["left"] = 10;
        item["top"] = 10;
        QVariantMap paramMap;
        paramMap["text"] = "%timestamp%";
        item["param"] = paramMap;
        contents.append(item);
    }
    {
        QVariantMap item;
        item["type"] = CRVSDK_MIXCONT_TEXT;
        item["left"] = 10;
        item["top"] = 60;
        QVariantMap paramMap;
        paramMap["text"] = "中文测试test";
        item["param"] = paramMap;
        contents.append(item);
    }
    return contents;
}

void MainDialog::slot_btnBaseFuncClicked()
{
	bool funcShow = ui->baseFuncWidget->isVisible();
	ui->baseFuncWidget->setVisible(!funcShow);
	ui->btnBaseFunc->setIcon(QIcon(funcShow ? ":/Resources/arrowDown.png" : ":/Resources/arrowUp.png"));
}
void MainDialog::slot_btnHigherFuncClicked()
{
	bool funcShow = ui->higherFuncWidget->isVisible();
	ui->higherFuncWidget->setVisible(!funcShow);
	ui->btnHigherFunc->setIcon(QIcon(funcShow ? ":/Resources/arrowDown.png" : ":/Resources/arrowUp.png"));
}

void MainDialog::slot_btnAudioSetClicked()
{
	DlgAudioSet *dlgAudioSet = new DlgAudioSet(this);
	dlgAudioSet->setAttribute(Qt::WA_DeleteOnClose);
	dlgAudioSet->exec();
}

void MainDialog::slot_btnVideoSetClicked()
{
	DlgVideoSet *dlgVideoSet = new DlgVideoSet(this);
	dlgVideoSet->setAttribute(Qt::WA_DeleteOnClose);
	dlgVideoSet->exec();
}

void MainDialog::slot_btnLocRecordClicked()
{
	if (m_dlgLocRecord == NULL)
	{
		m_dlgLocRecord = new DlgLocalRecord(this);
	}
	m_dlgLocRecord->show();
}
void MainDialog::slot_btnSvrRecordClicked()
{
	if (m_dlgSvrRecord == NULL)
	{
		m_dlgSvrRecord = new DlgServerRecord(this);
	}
	m_dlgSvrRecord->show();
}

void MainDialog::slot_btnMediaClicked()
{
	//屏幕共享中，不能使用该功能
	if (g_sdkMain->getSDKMeeting().getScreenShareInfo()._state == 1)
	{
		QMessageBox::information(this, tr("提示"), tr("请先停止屏幕共享"));
		return;
	}
	QString filters = tr("常见格式(*.mp4 *.mp3 *.flv *.avi *.wmv *.mkv *.mov *.3gp *.wma *.wav);;所有文件(*.*)");
	QString fileName = QFileDialog::getOpenFileName(this, "打开文件", QString(), filters);
	if (fileName.length() > 0)
	{
		CRMediaInfo mInfo = g_sdkMain->getSDKMeeting().getMediaInfo();
		if (mInfo._state != CRVSDK_MEDIAST_STOPPED)
		{
			if (mInfo._userID != getMyUserID())
			{
				QMessageBox::information(this, tr("提示"), tr("他人正在共享影音，不能再共享。"));
				return;
			}
			g_sdkMain->getSDKMeeting().stopPlayMedia();
		}

		g_sdkMain->getSDKMeeting().startPlayMedia(fileName.toUtf8().constData());
	}
}

void MainDialog::slot_mediaPlaying(bool bPlaying)
{
	m_mediaPlayUI->setVisible(bPlaying);
	m_videoWallPage->setVideoWallMode(bPlaying ? false : true);
	emit s_viewChanged();
}

void MainDialog::slot_btnStartScreenClicked()
{
	//影音共享中，不能使用该功能
	if (g_sdkMain->getSDKMeeting().getMediaInfo()._state != CRVSDK_MEDIAST_STOPPED)
	{
		QMessageBox::information(this, tr("提示"), tr("请先停止影音共享"));
		return;
	}
	//屏幕共享中，不能使用该功能
	if (g_sdkMain->getSDKMeeting().getScreenShareInfo()._state == 1)
	{
		QMessageBox::information(this, tr("提示"), tr("他人正在共享屏幕，不能再共享。"));
		return;
	}

	//g_sdkMain->getSDKMeeting().setScreenShareCfg(CRScreenShareCfg());
	g_sdkMain->getSDKMeeting().startScreenShare();
}

void MainDialog::slot_btnStopScreenClicked()
{
	//屏幕共享中，不能使用该功能
	CRScreenShareInfo shareInfo = g_sdkMain->getSDKMeeting().getScreenShareInfo();
	if (shareInfo._state == 1 && shareInfo._sharerUserID != m_myUserId)
	{
		QMessageBox::information(this, tr("提示"), tr("他人正在共享屏幕，不能停止。"));
		return;
	}

	g_sdkMain->getSDKMeeting().stopScreenShare();
}

void MainDialog::slot_screenShareStateChanged(bool bShare)
{
	m_screeShareUI->setVisible(bShare);
	m_videoWallPage->setVideoWallMode(bShare ? false : true);
	ui->btnStartScreenShare->setVisible(!bShare);
	ui->btnStopScreenShare->setVisible(bShare);
	emit s_viewChanged();
}

void MainDialog::slot_btnCustomAudioClicked()
{
	if (m_customAudioCapture == NULL)
	{
		m_customAudioCapture = new CustomAudioCapture(this);
	}
	m_customAudioCapture->show();
}
void MainDialog::slot_btnCustomVideoClicked()
{
	if (m_customVideoCaptureRender == NULL)
	{
		m_customVideoCaptureRender = new CustomVideoCaptureRender(this);
	}
	m_customVideoCaptureRender->show();
}

void MainDialog::slot_btnRoomMsgClicked()
{
	m_dlgRoomMsg->show();
}
void MainDialog::slot_btnRoomSetClicked()
{
	if(NULL == m_dlgRoomAttrs)
	{
		m_dlgRoomAttrs = new DlgRoomAttrs(this);
	}
	m_dlgRoomAttrs->show();
}

void MainDialog::slot_btnMemberSetClicked()
{
	if(NULL == m_dlgUserSelect)
	{
		m_dlgUserSelect = new DlgUserSelect(this);
	}
	m_dlgUserSelect->show();
}

void MainDialog::slot_btnNetCameraClicked()
{
	if (NULL == m_dlgNetCamera)
	{
		m_dlgNetCamera = new DlgNetCamera(this);
	}
	m_dlgNetCamera->show();
}

void MainDialog::slot_btnVoiceChangeClicked()
{
	DlgVoiceChange *dlgVoiceChange = new DlgVoiceChange(this);
	dlgVoiceChange->setAttribute(Qt::WA_DeleteOnClose);
	dlgVoiceChange->exec();
}

void MainDialog::slot_btnEchoTestClicked()
{
	DlgEchoTest *dlgEchoTest = new DlgEchoTest(this);
	dlgEchoTest->setAttribute(Qt::WA_DeleteOnClose);
	dlgEchoTest->show();
}
