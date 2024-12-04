#include "stdafx.h"
#include "ShareSourceSelectDlg.h"
#include "ui_ShareSourceSelectDlg.h"
#include "CThumbnailItem.h"

#define COLUMN_NUM 3

ShareSourceSelectDlg::ShareSourceSelectDlg(QWidget *parent) : QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui = new Ui::ShareSourceSelectDlg();
	ui->setupUi(this);
	this->setFixedSize(640, 500);

	connect(ui->thumList, &QListWidget::currentItemChanged, this, &ShareSourceSelectDlg::on_currentItemchanged);
	connect(ui->thumList, &QListWidget::itemDoubleClicked, this, &ShareSourceSelectDlg::on_itemDoubleClicked);

#ifndef WIN32
	ui->audioBtn->hide();
#endif;
}

ShareSourceSelectDlg::~ShareSourceSelectDlg()
{
	delete ui;
}


void ShareSourceSelectDlg::showEvent(QShowEvent *event)
{
	QDialog::showEvent(event);

	int scrollW = 20;
	int scrnWndW = (ui->thumList->viewport()->width() - scrollW - 1) / COLUMN_NUM;
	int scrnWndH = ui->thumList->viewport()->height() / 3;
	ui->thumList->setGridSize(QSize(scrnWndW, scrnWndH));

	addScreenThumbnail(scrnWndW, scrnWndH);
	addPogramThumbnail(scrnWndW, scrnWndH);
	if (ui->thumList->count() > 0)
	{
		ui->thumList->setCurrentItem(ui->thumList->item(0));
	}
}

void ShareSourceSelectDlg::addScreenThumbnail(int w, int h)
{
	CRBase::CRArray<CRScreenCaptureSourceInfo> screens = g_sdkMain->getSDKMeeting().getScreenCaptureSources(CRSize(228, 128), CRSize(32, 32), CRVSDK_CAPSOURCE_SCREEN);
	int screenCount = screens.count();
	for (int i = 0; i < screenCount; i++)
	{
		const CRScreenCaptureSourceInfo &info = screens.item(i);
		CThumbnailItem *pWidget = new CThumbnailItem(this);
		pWidget->setInfo(info);

		QListWidgetItem* pItem = new QListWidgetItem;
		pItem->setSizeHint(QSize(w, h));
		pWidget->setFixedSize(QSize(w, h));
		ui->thumList->addItem(pItem);
		ui->thumList->setItemWidget(pItem, pWidget);
	}

	//用空白填充一行
	int remind = COLUMN_NUM - (screenCount % COLUMN_NUM);
	for (int i = 0; i < remind; i++)
	{
		QListWidgetItem* pItem = new QListWidgetItem;
		ui->thumList->addItem(pItem);
		pItem->setSizeHint(QSize(w, h));
	}
}

void ShareSourceSelectDlg::addPogramThumbnail(int w, int h)
{
	CRBase::CRArray<CRScreenCaptureSourceInfo> wnds = g_sdkMain->getSDKMeeting().getScreenCaptureSources(CRSize(228, 128), CRSize(32, 32), CRVSDK_CAPSOURCE_WINDOW);
	for (int i = 0; i < wnds.count(); i++)
	{
		const CRScreenCaptureSourceInfo &info = wnds.item(i);
		CThumbnailItem *pWidget = new CThumbnailItem(this);
		pWidget->setInfo(info);

		QListWidgetItem* pItem = new QListWidgetItem;
		pItem->setSizeHint(QSize(w, h));
		pWidget->setFixedSize(QSize(w, h));
		ui->thumList->addItem(pItem);
		ui->thumList->setItemWidget(pItem, pWidget);
	}

}

bool ShareSourceSelectDlg::isShareVoice()
{
	return ui->audioBtn->isChecked();		 
}

bool ShareSourceSelectDlg::isFluencyMode()
{
	return ui->fluencyBtn->isChecked();
}

void ShareSourceSelectDlg::on_startScreenBtn_clicked()
{
	this->accept();

	if (this->getShareType() == CRVSDK_CAPSOURCE_NULL)
	{
		return;
	}

	QVariantMap shrCfg;
	if (this->getShareType() == CRVSDK_CAPSOURCE_SCREEN)
	{
		shrCfg["monitorID"] = this->getScreenID();
	}
	else
	{
		shrCfg["catchWnd"] = this->getShareWId();
		shrCfg["activateWindow"] = true; //激活目标程序
		shrCfg["borderHighLight"] = true;
		shrCfg["highLightColor"] = "#54DB00";
		shrCfg["highLightColorForPause"] = "#FFC268";
		shrCfg["highLightWidth"] = 5;
	}
	shrCfg["shareSound"] = this->isShareVoice();
	if (this->isFluencyMode())
	{
		shrCfg["qp"] = 28;
		shrCfg["maxKbps"] = 1000;
	}
	else
	{
		shrCfg["qp"] = 22;
		shrCfg["maxKbps"] = 2000;
	}
	QByteArray strCfg = CoverJsonToString(shrCfg);
	g_sdkMain->getSDKMeeting().setScreenShareCfg(strCfg.constData());
	g_sdkMain->getSDKMeeting().startScreenShare();
}

void ShareSourceSelectDlg::on_currentItemchanged(QListWidgetItem *current, QListWidgetItem *previous)
{
	QWidget* pWidget = ui->thumList->itemWidget(previous);
	if (pWidget != NULL)
	{
		static_cast<CThumbnailItem*>(pWidget)->updateStyle(false);
	}

	QWidget* pWidgetCur = ui->thumList->itemWidget(current);
	if (pWidgetCur != NULL)
	{
		static_cast<CThumbnailItem*>(pWidgetCur)->updateStyle(true);
	}
}

void ShareSourceSelectDlg::on_itemDoubleClicked(QListWidgetItem*)
{
	on_startScreenBtn_clicked();
}



CRVSDK_SCREENCAPTURESOURCE_TYPE ShareSourceSelectDlg::getShareType()
{
	QListWidgetItem *pItem = ui->thumList->currentItem();
	if (pItem == nullptr)
		return CRVSDK_CAPSOURCE_NULL;

	CThumbnailItem* pWidget = dynamic_cast<CThumbnailItem*>(ui->thumList->itemWidget(pItem));
	if (pWidget == nullptr)
		return CRVSDK_CAPSOURCE_NULL;

	const CRScreenCaptureSourceInfo &info = pWidget->getInfo();
	return CRVSDK_SCREENCAPTURESOURCE_TYPE(info._type);
}

int ShareSourceSelectDlg::getScreenID()
{
	QListWidgetItem *pItem = ui->thumList->currentItem();
	if (pItem == nullptr)
		return -1;

	CThumbnailItem* pWidget = dynamic_cast<CThumbnailItem*>(ui->thumList->itemWidget(pItem));
	if (pWidget == nullptr)
		return -1;

	const CRScreenCaptureSourceInfo &info = pWidget->getInfo();
	return int(info._sourceId);
}

WId ShareSourceSelectDlg::getShareWId()
{
	QListWidgetItem *pItem = ui->thumList->currentItem();
	if (pItem == nullptr)
		return -1;

	CThumbnailItem* pWidget = dynamic_cast<CThumbnailItem*>(ui->thumList->itemWidget(pItem));
	if (pWidget == nullptr)
		return -1;

	return WId(pWidget->getInfo()._sourceId);
}

