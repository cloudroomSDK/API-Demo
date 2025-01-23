#include "stdafx.h"
#include "DlgUserAttrs.h"
#include "DlgAddOrEditAttr.h"
#include "maindialog.h"

const std::string g_notifyAll = "{\"notifyAll\":1}";

DlgUserAttrs::DlgUserAttrs(const CRString &userId, QWidget *parent)
	: QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint), m_userId(userId)
{
	ui.setupUi(this);
	this->setAttribute(Qt::WA_DeleteOnClose);

	connect(ui.btnAdd, &QPushButton::clicked, this, &DlgUserAttrs::slot_btnAddClicked);
	connect(ui.btnRemove, &QPushButton::clicked, this, &DlgUserAttrs::slot_btnRemoveClicked);
	connect(ui.btnRemoveAll, &QPushButton::clicked, this, &DlgUserAttrs::slot_btnRemoveAllClicked);
	connect(ui.btnEdit, &QPushButton::clicked, this, &DlgUserAttrs::slot_btnEditClicked);

	m_cookie = MainDialog::getMyUserID();

	QStringList headerText;
	headerText << tr("键") << tr("值") << tr("修改者") << tr("修改时间");
	ui.userAttrsTable->setColumnCount(headerText.size());
	ui.userAttrsTable->verticalHeader()->setVisible(false);
	ui.userAttrsTable->setSelectionBehavior(QAbstractItemView::SelectRows);
	ui.userAttrsTable->setSelectionMode(QAbstractItemView::SingleSelection);
	ui.userAttrsTable->setEditTriggers(QAbstractItemView::NoEditTriggers);
	ui.userAttrsTable->horizontalHeader()->setSectionsClickable(false);
	for(int i = 0; i < headerText.size(); i++)
	{
		QTableWidgetItem *headerItem = new QTableWidgetItem(headerText.at(i));
		QFont ft = headerItem->font();
		ft.setBold(true);
		headerItem->setFont(ft);
		ui.userAttrsTable->setHorizontalHeaderItem(i, headerItem);
	}

	connect(ui.userAttrsTable, &QTableWidget::cellDoubleClicked, this, &DlgUserAttrs::slot_cellDoubleClicked);
	connect(ui.userAttrsTable, &QTableWidget::itemSelectionChanged, this, &DlgUserAttrs::updateButtonsState);

	updateButtonsState();
	g_sdkMain->getSDKMeeting().AddCallBack(this);
	
	QVariantList varList;
	varList.push_back(crStrToQStr(m_userId));
	QByteArray jsonStr = CoverJsonToString(varList);
	g_sdkMain->getSDKMeeting().getUserAttrs(jsonStr.constData(), NULL, m_cookie.constData());

}

DlgUserAttrs::~DlgUserAttrs()
{
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}

void DlgUserAttrs::getUserAttrsSuccess(const char* attrsMap, const char* cookie)
{
	if (m_cookie != cookie)
		return;

	QVariantMap varMap = QJsonDocument::fromJson(QByteArray(attrsMap)).toVariant().toMap();
	m_allAttrs = varMap[crStrToQStr(m_userId)].toMap();
	updateAttrsTable();
	updateButtonsState();
}

void DlgUserAttrs::getUserAttrsFail(CRVSDK_ERR_DEF sdkErr, const char* cookie)
{
	if (m_cookie != cookie)
		return;
	QMessageBox::information(this, tr("提示"), tr("获取用户属性失败(%1)").arg(getErrDesc(sdkErr)));
}

void DlgUserAttrs::addOrUpdateUserAttrsRslt(CRVSDK_ERR_DEF sdkErr, const char* cookie)
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

void DlgUserAttrs::delUserAttrsRslt(CRVSDK_ERR_DEF sdkErr, const char* cookie)
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

void DlgUserAttrs::clearUserAttrsRslt(CRVSDK_ERR_DEF sdkErr, const char* cookie)
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

void DlgUserAttrs::slot_btnAddClicked()
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
		g_sdkMain->getSDKMeeting().addOrUpdateUserAttrs(m_userId.constData(), jsonStr.constData(), g_notifyAll.c_str(), m_cookie.constData());
	}
}

void DlgUserAttrs::slot_btnRemoveClicked()
{
	int curRow = ui.userAttrsTable->currentRow();
	if(-1 == curRow || curRow >= ui.userAttrsTable->rowCount())
		return;

	QTableWidgetItem *itemKey = ui.userAttrsTable->item(curRow, 0);
	m_operKey = itemKey->text();
	QVariantList varList;
	varList.push_back(m_operKey);
	QByteArray jsonStr = CoverJsonToString(varList);

	g_sdkMain->getSDKMeeting().delUserAttrs(m_userId.constData(), jsonStr.constData(), g_notifyAll.c_str(), m_cookie.constData());
}

void DlgUserAttrs::slot_btnRemoveAllClicked()
{
	if(ui.userAttrsTable->rowCount() <= 0)
		return;

	clearOperStrings();
	g_sdkMain->getSDKMeeting().clearUserAttrs(m_userId.constData(), g_notifyAll.c_str(), m_cookie.constData());
}

void DlgUserAttrs::slot_btnEditClicked()
{
	int curRow = ui.userAttrsTable->currentRow();
	if(-1 == curRow || curRow >= ui.userAttrsTable->rowCount())
		return;

	slot_cellDoubleClicked(curRow, 0);
}

void DlgUserAttrs::slot_cellDoubleClicked(int row, int col)
{
	if(row >= ui.userAttrsTable->rowCount())
		return;

	DlgAddOrEditAttr *editDlg = new DlgAddOrEditAttr(this);
	QTableWidgetItem *itemKey = ui.userAttrsTable->item(row, 0);
	QTableWidgetItem *itemVal = ui.userAttrsTable->item(row, 1);
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
		g_sdkMain->getSDKMeeting().addOrUpdateUserAttrs(m_userId.constData(), jsonStr.constData(), g_notifyAll.c_str(), m_cookie.constData());
	}
}

void DlgUserAttrs::showOperRsltTips(CRVSDK_ERR_DEF sdkErr)
{
	if(CRVSDKERR_NOERR == sdkErr)
	{
		QMessageBox::information(this, tr("提示"), tr("操作成功"));
	}
	else
	{
		QMessageBox::information(this, tr("提示"), tr("操作失败(%1)").arg(getErrDesc(sdkErr)));
	}
}

void DlgUserAttrs::updateAttrsTable()
{
	while(ui.userAttrsTable->rowCount() > 0)
	{
		ui.userAttrsTable->removeRow(0);
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
				for(int i = 0; i < ui.userAttrsTable->rowCount(); i++)
				{
					QTableWidgetItem *pItem = ui.userAttrsTable->item(i, 0);
					if(pItem->text() == m_operKey)
					{
						ui.userAttrsTable->removeRow(i);
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
		ui.userAttrsTable->insertRow(curRow);
		ui.userAttrsTable->setItem(curRow, 0, keyItem);
		ui.userAttrsTable->setItem(curRow, 1, valItem);
		ui.userAttrsTable->setItem(curRow, 2, userItem);
		ui.userAttrsTable->setItem(curRow, 3, tsItem);
	}

}

void DlgUserAttrs::clearOperStrings()
{
	m_operKey.clear();
	m_operVal.clear();
}

void DlgUserAttrs::updateButtonsState()
{
	int itemCount = ui.userAttrsTable->rowCount();
	ui.btnRemoveAll->setEnabled(itemCount > 0);

	bool editable = true;
	int curRow = ui.userAttrsTable->currentRow();
	if(-1 == curRow || curRow >= ui.userAttrsTable->rowCount())
	{
		editable = false;
	}
	ui.btnEdit->setEnabled(editable);
	ui.btnRemove->setEnabled(editable);
}

