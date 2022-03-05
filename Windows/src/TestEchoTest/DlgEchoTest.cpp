#include "stdafx.h"
#include "DlgEchoTest.h"

#define TEST_TIME 10

DlgEchoTest::DlgEchoTest(QWidget *parent)
	: QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);

	connect(&m_timer, &QTimer::timeout, this, &DlgEchoTest::slot_timeout);
	connect(ui.btnTest, &QPushButton::clicked, this, &DlgEchoTest::slot_btnTestClicked);
	
	stopTest();
}

DlgEchoTest::~DlgEchoTest()
{
 	g_sdkMain->getSDKMeeting().stopEchoTest();
}

void DlgEchoTest::slot_btnTestClicked()
{
	//开始环回测试
	if (ui.btnTest->text() == tr("开始"))
	{
		startTest();
	}
	else
	{
		stopTest();
	}
}

void DlgEchoTest::startTest()
{
	ui.btnTest->setText(tr("停止"));
	g_sdkMain->getSDKMeeting().startEchoTest();
	m_timer.start(1000);
	m_nSecondsToStop = TEST_TIME;
	slot_timeout();
}

void DlgEchoTest::stopTest()
{
	ui.btnTest->setText(tr("开始"));
	ui.label->setText(tr("未开始"));

	g_sdkMain->getSDKMeeting().stopEchoTest();
	m_timer.stop();
	m_nSecondsToStop = 0;
}


void DlgEchoTest::slot_timeout()
{
	if (m_nSecondsToStop <= 0)
	{
		stopTest();
	}
	else
	{
		ui.label->setText(tr("正在语音测试，%1秒后自动结束").arg(m_nSecondsToStop--));
	}
}
