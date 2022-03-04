#include "stdafx.h"
#include "DlgRoomMsg.h"
#include "maindialog.h"

DlgRoomMsg::DlgRoomMsg(QWidget *parent)
	: QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);
	ui.teReceive->setReadOnly(true);

	m_cookie = qStrToCRStr(makeUUID());

	connect(ui.btnSend, &QPushButton::clicked, this, &DlgRoomMsg::slot_btnSendClicked);
	g_sdkMain->getSDKMeeting().AddCallBack(this);
}

DlgRoomMsg::~DlgRoomMsg()
{
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}

void DlgRoomMsg::sendMeetingCustomMsgRslt(CRVSDK_ERR_DEF sdkErr, const char* cookie)
{
	if(m_cookie != cookie)
		return;

	if(CRVSDKERR_NOERR == sdkErr)
	{
		// add to receive
		append2ReceiveEdit(ui.teInput->toPlainText(), MainDialog::getMyUserID());

		ui.teInput->clear();
		ui.teInput->setFocus();
	}
	else
	{
		QMessageBox::information(this, tr("提示"), tr("发送消息失败(%1)").arg(getErrDesc(sdkErr)));
	}
}

void DlgRoomMsg::notifyMeetingCustomMsg(const char* fromUserID, const char* jsonDat)
{
	if (MainDialog::getMyUserID() == fromUserID)
		return;

	QString strMsg(jsonDat);
	QVariantMap varMap = QJsonDocument::fromJson(jsonDat).toVariant().toMap();
	QString cmdType = varMap["CmdType"].toString();
	if(cmdType == QString("IM"))
	{
		strMsg = varMap["IMMsg"].toString();
	}
	append2ReceiveEdit(strMsg, CRString(fromUserID));
}

void DlgRoomMsg::showEvent(QShowEvent *evt)
{
	QDialog::showEvent(evt);

	ui.teInput->setFocus();
	//显示最新消息
	QScrollBar *pVSBar = ui.teReceive->verticalScrollBar();
	pVSBar->setValue(pVSBar->maximum());
}

void DlgRoomMsg::slot_btnSendClicked()
{
	QString inputText = ui.teInput->toPlainText();
	if (inputText.length() <= 0)
	{
		QMessageBox::information(this, tr("提示"), tr("消息不能为空！"));
		return;
	}
	QVariantMap varMap;
	varMap["CmdType"] = "IM";
	varMap["IMMsg"] = inputText;
	QByteArray roomMsg = QJsonDocument::fromVariant(varMap).toJson();
	g_sdkMain->getSDKMeeting().sendMeetingCustomMsg(roomMsg.constData(), m_cookie.constData());
}

void DlgRoomMsg::append2ReceiveEdit(const QString &strMsg, const CRString &strUserId)
{
	bool isMine = (strUserId == MainDialog::getMyUserID());
	QString strNickname = crStrToQStr(strUserId);

	//添加前位置等信息
	QScrollBar *pVSBar = ui.teReceive->verticalScrollBar();
	int oldPos = pVSBar->value();
	int oldMax = pVSBar->maximum();

	QTextCursor tc = ui.teReceive->textCursor();
	tc.movePosition(QTextCursor::End);
	tc.beginEditBlock();
	insertMsgRow(tc, strMsg, strNickname, isMine);
	tc.endEditBlock();

	if ((oldMax - oldPos) <= 2)
	{
		//滚动到最后
		pVSBar->setValue(pVSBar->maximum());
	}
	else
	{
		//保证相对位置不变
		pVSBar->setValue(oldPos);
	}
}

void DlgRoomMsg::insertMsgRow(QTextCursor &cursor, const QString &strMsg, const QString &strNickname, bool isMine)
{
	//时间、昵称
	QDateTime curDT = QDateTime::currentDateTime();
	QString strTime = curDT.toString("hh:mm");
	if(!isMine)
	{
		strTime += QString(" ") + strNickname;
	}
	QTextBlockFormat blockFmt;
	blockFmt.setAlignment(isMine ? Qt::AlignRight : Qt::AlignLeft);
	QTextCharFormat format;
	format.setForeground(QColor(102, 102, 102));
	cursor.insertBlock(blockFmt, format);
	QString timeHtml = QString("<span style=\"color:#666666; font-size:12pt;\">%1</span>").arg(strTime);
	cursor.insertHtml(timeHtml);

	//消息内容cell
	QTextTableFormat tableFormat_msg;
	QVector<QTextLength> tableTextLength_msg;
	tableTextLength_msg << QTextLength(QTextLength::VariableLength, 30);
	tableFormat_msg.setColumnWidthConstraints(tableTextLength_msg);
	tableFormat_msg.setBorder(0);
	tableFormat_msg.setPadding(0);
	tableFormat_msg.setMargin(4);
	tableFormat_msg.setCellPadding(0);
	tableFormat_msg.setCellSpacing(0);
	tableFormat_msg.setBackground(QColor(240, 240, 240));//背景色
	tableFormat_msg.setAlignment((isMine ? Qt::AlignRight : Qt::AlignLeft) | Qt::AlignVCenter);
	QTextTable *tableMsg = cursor.insertTable(1, 1, tableFormat_msg);
	QString msgHtml = QString("<span style=\"color:%1; font-size:12pt;\">%2</span>").arg(isMine ? "#666666" : "#333333").arg(strMsg);
	cursor.insertHtml(msgHtml);
}

