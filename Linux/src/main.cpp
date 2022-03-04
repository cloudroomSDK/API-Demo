#include "stdafx.h"
#include "DlgLogin.h"
#include <QApplication>

CRVideoSDKMain*	g_sdkMain = NULL;
QString g_cfgFile;

//定义CRMsgEvent
class CRMsgEvent : public QEvent
{
public:
	CRMsgEvent(uint32_t msgSN) : QEvent(QEvent::User) {
		m_msgSN = msgSN; 
	}

	uint32_t m_msgSN;
};

//Qt版本的主线程消息派发器
class CRMainThreadDispatch_Qt : public QObject, public CRMainThreadDispatch
{
public:
    CRMainThreadDispatch_Qt(QObject *parent) : QObject(parent){;}

	virtual void postCRMsg(uint32_t msgSN)
	{
		//向CRMainThreadDispatch_Qt发消息;
		//CRMainThreadDispatch_Qt为主线程对象，等于消息派发给了主线程
		//由于QCoreApplication::postEvent线程安全，所以无需提心多线程问题
		QCoreApplication::postEvent(this, new CRMsgEvent(msgSN));
	}

	bool event(QEvent *e)
	{
		//主线程的CRMainThreadDispatch_Qt在处理QEvent::User消息时，
		//调用dealCRMsg来完成消息的处理
		if (e->type() == QEvent::User)
		{
			CRMsgEvent *pMsg = static_cast<CRMsgEvent*>(e);
			dealCRMsg(pMsg->m_msgSN);
			return true;
		}
		return QObject::event(e);
	}
};


int main(int argc, char *argv[])
{
	QFileInfo qfinfo(QString::fromLocal8Bit(argv[0]));
	QString strAppPath = qfinfo.absolutePath();
	QDir::setCurrent(strAppPath);

	QApplication::addLibraryPath(strAppPath + "/plugins");
	QApplication a(argc, argv);

	g_cfgFile = strAppPath + "/APIDemo.ini";
#ifdef LINUX
	CRMainThreadDispatch_Qt *pDispatch = new CRMainThreadDispatch_Qt(&a);
    g_sdkMain = CRVideoSDKMain::create(strAppPath.toUtf8().constData(), pDispatch);
#else
    g_sdkMain = CRVideoSDKMain::create(strAppPath.toUtf8().constData());
#endif
	if (g_sdkMain == NULL)
	{
		QMessageBox::information(NULL, QObject::tr("提示"), QObject::tr("创建sdk对象失败!"));
		return -1;
	}

	int exitCode;
	{
		DlgLogin dlg;
		dlg.show();
		exitCode = a.exec();
	}

	g_sdkMain->destroy();
	g_sdkMain = NULL;
	return exitCode;
}
