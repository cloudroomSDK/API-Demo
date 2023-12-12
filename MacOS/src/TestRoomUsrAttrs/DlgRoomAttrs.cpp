#include "stdafx.h"
#include "DlgRoomAttrs.h"
#include "DlgAddOrEditAttr.h"
#include "maindialog.h"

DlgRoomAttrs::DlgRoomAttrs(QWidget *parent)
	: QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);

	connect(ui.btnAdd, &QPushButton::clicked, this, &DlgRoomAttrs::slot_btnAddClicked);
	connect(ui.btnRemove, &QPushButton::clicked, this, &DlgRoomAttrs::slot_btnRemoveClicked);
	connect(ui.btnRemoveAll, &QPushButton::clicked, this, &DlgRoomAttrs::slot_btnRemoveAllClicked);
	connect(ui.btnEdit, &QPushButton::clicked, this, &DlgRoomAttrs::slot_btnEditClicked);

	m_cookie = qStrToCRStr(makeUUID());

	QStringList headerText;
	headerText << tr("键") << tr("值") << tr("修改者") << tr("修改时间");
	ui.roomAttrsTable->setColumnCount(headerText.size());
	ui.roomAttrsTable->verticalHeader()->setVisible(false);
	ui.roomAttrsTable->setSelectionBehavior(QAbstractItemView::SelectRows);
	ui.roomAttrsTable->setSelectionMode(QAbstractItemView::SingleSelection);
	ui.roomAttrsTable->setEditTriggers(QAbstractItemView::NoEditTriggers);
	ui.roomAttrsTable->horizontalHeader()->setSectionsClickable(false);
	for(int i = 0; i < headerText.size(); i++)
	{
		QTableWidgetItem *headerItem = new QTableWidgetItem(headerText.at(i));
		QFont ft = headerItem->font();
		ft.setBold(true);
		headerItem->setFont(ft);
		ui.roomAttrsTable->setHorizontalHeaderItem(i, headerItem);
	}

	connect(ui.roomAttrsTable, &QTableWidget::cellDoubleClicked, this, &DlgRoomAttrs::slot_cellDoubleClicked);
	connect(ui.roomAttrsTable, &QTableWidget::itemSelectionChanged, this, &DlgRoomAttrs::updateButtonsState);

	updateButtonsState();
	g_sdkMain->getSDKMeeting().AddCallBack(this);
	g_sdkMain->getSDKMeeting().getMeetingAllAttrs(m_cookie.constData());
}

DlgRoomAttrs::~DlgRoomAttrs()
{
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}

void DlgRoomAttrs::getMeetingAllAttrsSuccess(const char* attrs, const char* cookie)
{
	if(m_cookie!=cookie)
		return;

	m_allAttrs = QJsonDocument::fromJson(QByteArray(attrs)).toVariant().toMap();
	updateAttrsTable();
	updateButtonsState();
}

void DlgRoomAttrs::getMeetingAllAttrsFail(CRVSDK_ERR_DEF sdkErr, const char* cookie)
{
	if (m_cookie != cookie)
		return;
	QMessageBox::information(this, tr("提示"), tr("获取房间属性失败(%1)").arg(getErrDesc(sdkErr)));
}

void DlgRoomAttrs::addOrUpdateMeetingAttrsRslt(CRVSDK_ERR_DEF sdkErr, const char* cookie)
{
	if (m_cookie != cookie)
		return;
	showOperRsltTips(sdkErr);
	if(CRVSDKERR_NOERR == sdkErr)
	{
		updateAttrsTable();
		updateButtonsState();
	}
}

void DlgRoomAttrs::delMeetingAttrsRslt(CRVSDK_ERR_DEF sdkErr, const char* cookie)
{
	if (m_cookie != cookie)
		return;
	showOperRsltTips(sdkErr);
	if(CRVSDKERR_NOERR == sdkErr)
	{
		updateAttrsTable();
		updateButtonsState();
	}
}

void DlgRoomAttrs::clearMeetingAttrsRslt(CRVSDK_ERR_DEF sdkErr, const char* cookie)
{
	if (m_cookie != cookie)
		return;
	showOperRsltTips(sdkErr);
	if(CRVSDKERR_NOERR == sdkErr)
	{
		m_allAttrs.clear();
		updateAttrsTable();
		updateButtonsState();
	}
}

void DlgRoomAttrs::slot_btnAddClicked()
{
	DlgAddOrEditAttr *addDlg = new DlgAddOrEditAttr(this);
	if(QDialog::Accepted == addDlg->exec())
	{
		addDlg->getKeyValue(m_operKey, m_operVal);
		if(m_operKey.isEmpty() || m_operVal.isEmpty())
		{
			QMessageBox::information(this, tr("提示"), tr("不可填空值"));
			clearOperStrings();
			return;
		}
		if(m_allAttrs.contains(m_operKey))
		{
			QMessageBox::information(this, tr("提示"), tr("该键值已存在"));
			clearOperStrings();
			return;
		}

		QVariantMap varMap;
		varMap[m_operKey] = m_operVal;
		QByteArray jsonStr = CoverJsonToString(varMap);
		g_sdkMain->getSDKMeeting().addOrUpdateMeetingAttrs(jsonStr.constData(), NULL, m_cookie.constData());
	}
}

void DlgRoomAttrs::slot_btnRemoveClicked()
{
	int curRow = ui.roomAttrsTable->currentRow();
	if(-1 == curRow || curRow >= ui.roomAttrsTable->rowCount())
		return;

	QTableWidgetItem *itemKey = ui.roomAttrsTable->item(curRow, 0);
	m_operKey = itemKey->text();
	QVariantList varList;
	varList.push_back(m_operKey);
	QByteArray jsonStr = CoverJsonToString(varList);

	g_sdkMain->getSDKMeeting().delMeetingAttrs(jsonStr.constData(), NULL, m_cookie.constData());
}

void DlgRoomAttrs::slot_btnRemoveAllClicked()
{
	if(ui.roomAttrsTable->rowCount() <= 0)
		return;

	clearOperStrings();
	g_sdkMain->getSDKMeeting().clearMeetingAttrs(NULL, m_cookie.constData());
}

void DlgRoomAttrs::slot_btnEditClicked()
{
	int curRow = ui.roomAttrsTable->currentRow();
	if(-1 == curRow || curRow >= ui.roomAttrsTable->rowCount())
		return;

	slot_cellDoubleClicked(curRow, 0);
}

void DlgRoomAttrs::slot_cellDoubleClicked(int row, int col)
{
	if(row >= ui.roomAttrsTable->rowCount())
		return;

	DlgAddOrEditAttr *editDlg = new DlgAddOrEditAttr(this);
	QTableWidgetItem *itemKey = ui.roomAttrsTable->item(row, 0);
	QTableWidgetItem *itemVal = ui.roomAttrsTable->item(row, 1);
 	editDlg->setKeyValue(itemKey->text(), itemVal->text());
	if(QDialog::Accepted == editDlg->exec())
	{
		editDlg->getKeyValue(m_operKey, m_operVal);
		if(m_operKey.isEmpty() || m_operVal.isEmpty())
		{
			QMessageBox::information(this, tr("提示"), tr("不可填空值"));
			clearOperStrings();
			return;
		}

		QVariantMap varMap;
		varMap[m_operKey] = m_operVal;
		QByteArray jsonStr = CoverJsonToString(varMap);
		g_sdkMain->getSDKMeeting().addOrUpdateMeetingAttrs(jsonStr.constData(), NULL, m_cookie.constData());
	}
}

void DlgRoomAttrs::showOperRsltTips(CRVSDK_ERR_DEF sdkErr)
{
	if(CRVSDKERR_NOERR == sdkErr)
	{
		QMessageBox::information(this, tr("提示"), tr("操作成功"));
	}
	else
	{
		QMessageBox::information(this, tr("提示"), tr("操作失败(%1)").arg(getErrDesc(sdkErr)));
		clearOperStrings();
	}
}

void DlgRoomAttrs::updateAttrsTable()
{
	while(ui.roomAttrsTable->rowCount() > 0)
	{
		ui.roomAttrsTable->removeRow(0);
	}
	if(!m_operKey.isEmpty())
	{
		QVariantMap::iterator it = m_allAttrs.find(m_operKey);
		//添加
		if(it == m_allAttrs.end())
		{
			QVariantMap varMap;
			varMap["value"] = m_operVal;
			varMap["lastModifyUserID"] = crStrToQStr(MainDialog::getMyUserID());
			varMap["lastModifyTs"] = QDateTime::currentMSecsSinceEpoch() / 1000;
			m_allAttrs[m_operKey] = varMap;
		}
		else
		{
			//删除
			if(m_operVal.isEmpty())
			{
				m_allAttrs.erase(it);
				for(int i = 0; i < ui.roomAttrsTable->rowCount(); i++)
				{
					QTableWidgetItem *pItem = ui.roomAttrsTable->item(i, 0);
					if(pItem->text() == m_operKey)
					{
						ui.roomAttrsTable->removeRow(i);
						break;
					}
				}
			}
			//编辑
			else
			{
				QVariantMap varMap = m_allAttrs[m_operKey].toMap();
				varMap["value"] = m_operVal;
				varMap["lastModifyUserID"] = crStrToQStr(MainDialog::getMyUserID());
				varMap["lastModifyTs"] = QDateTime::currentMSecsSinceEpoch() / 1000;
				m_allAttrs[m_operKey] = varMap;
			}
		}
	}
	clearOperStrings();

	int curRow = 0;
	for(QVariantMap::iterator it = m_allAttrs.begin(); it != m_allAttrs.end(); ++it, curRow++)
	{
		QString strKey = it.key();
		QVariantMap varMap = it.value().toMap();
		QString strVal = varMap["value"].toString();
		QString strModUser = varMap["lastModifyUserID"].toString();
		qint64 lastModifyTs = varMap["lastModifyTs"].toLongLong() * 1000;
		QDateTime lastModifyDt = QDateTime::fromMSecsSinceEpoch(lastModifyTs);
		QString strModTs = lastModifyDt.toString("yyyy/MM/d hh:mm:ss");
		QTableWidgetItem *keyItem = new QTableWidgetItem(strKey);
		QTableWidgetItem *valItem = new QTableWidgetItem(strVal);
		QTableWidgetItem *userItem = new QTableWidgetItem(strModUser);
		QTableWidgetItem *tsItem = new QTableWidgetItem(strModTs);
		ui.roomAttrsTable->insertRow(curRow);
		ui.roomAttrsTable->setItem(curRow, 0, keyItem);
		ui.roomAttrsTable->setItem(curRow, 1, valItem);
		ui.roomAttrsTable->setItem(curRow, 2, userItem);
		ui.roomAttrsTable->setItem(curRow, 3, tsItem);
	}
}

void DlgRoomAttrs::clearOperStrings()
{
	m_operKey.clear();
	m_operVal.clear();
}

void DlgRoomAttrs::updateButtonsState()
{
	int itemCount = ui.roomAttrsTable->rowCount();
	ui.btnRemoveAll->setEnabled(itemCount > 0);

	bool editable = true;
	int curRow = ui.roomAttrsTable->currentRow();
	if(-1 == curRow || curRow >= ui.roomAttrsTable->rowCount())
	{
		editable = false;
	}
	ui.btnEdit->setEnabled(editable);
	ui.btnRemove->setEnabled(editable);
}

