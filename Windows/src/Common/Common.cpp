#include "stdafx.h"
#include "Common.h"

QString GetPlatFormName()
{
#if defined(WIN32)
	return QString("Win");
#elif defined(LINUX)
	return QString("Linux");
#elif defined(TARGET_OS_MAC)
	return QString("macOS");
#else
	return QString("Unknow");
#endif
}

QDateTime CoverTime(int time)
{
	QDateTime dtRec;
	dtRec.setTime_t(time);
	dtRec = dtRec.toLocalTime();
	return dtRec;
}

QString CoverDuration2Str(int seconds)
{
	int nHour = seconds/3600;
	int nMin = (seconds%3600)/60;
	int nSec = seconds%60;

	QString str;
	if ( nHour>0 )
	{
		str += QString("%1:").arg(nHour, 2, 10, QLatin1Char('0'));
	}
	str += QString("%1:%2").arg(nMin, 2, 10, QLatin1Char('0')).arg(nSec, 2, 10, QLatin1Char('0'));
	return str;
}

QString AddBackslashAtBegin(const QString &path)
{
	QString rslt = CorrectBackslashFormat(path);
	if ( !rslt.startsWith(QDir::separator()) )
	{
		rslt = QDir::separator() + rslt;
	}
	return rslt;
}

QString RmBackslashAtBegin(const QString &path)
{
	QString rslt = CorrectBackslashFormat(path);
	if ( rslt.startsWith(QDir::separator()) )
	{
		rslt.remove(0, 1);
	}
	return rslt;
}


QString AddBackslashAtend(const QString &path)
{
	QString rslt = CorrectBackslashFormat(path);
	if ( !rslt.endsWith(QDir::separator()) )
	{
		rslt += QDir::separator();
	}
	return rslt;
}

QString RmBackslashAtend(const QString &path)
{
	QString rslt = CorrectBackslashFormat(path);
	if ( rslt.endsWith(QDir::separator()) )
	{
		rslt.remove(rslt.length()-1, 1);
	}
	return rslt;
}

QString CorrectBackslashFormat(const QString &pathName)
{
	QChar replaceTo = QDir::separator();
	QChar tobeReplace = (replaceTo == '\\') ? '/' : '\\';
	QString rslt(pathName);
	rslt.replace(tobeReplace, replaceTo);
	return rslt;
}

QString FileNameIllegalCharDeal(const QString &NoPathfileName)
{
	QString rslt(NoPathfileName);
	rslt.replace('\\', '_');
	rslt.replace('/', '_');
	rslt.replace(':', '_');
	rslt.replace('*', '_');
	rslt.replace('"', '_');
	rslt.replace('<', '_');
	rslt.replace('>', '_');
	rslt.replace('|', '_');
	rslt.remove('\r');
	rslt.replace('\n', '_');
	return rslt;
}

bool ReadDataFromFile(const QString &fileName, QByteArray &data)
{
	//打开文件
	QFile file(fileName);
	if ( !file.open(QIODevice::ReadOnly) )
		return false;

	data = file.readAll();
	return true;
}

bool ReadDataFromFile(const QString &fileName, CRByteArray &data)
{
    //打开文件
    QFile file(fileName);
    if ( !file.open(QIODevice::ReadOnly) )
        return false;

    int nFileSize = int(file.size());
    data.resize(nFileSize);

    int nRead = file.read(data.getData(), nFileSize);
    return ( nRead==nFileSize );
}

bool WriteDataToFile(const QByteArray &dat, const QString &fileName, bool bAppend)
{
	//打开文件
	QFile file(fileName);
	QFile::OpenMode openMd = bAppend ? (QIODevice::WriteOnly | QIODevice::Append) : (QIODevice::WriteOnly | QIODevice::Truncate);
	if (!file.open(openMd))
		return false;

	int nWrt = file.write(dat);
	if (nWrt != dat.size())
		return false;

	return true;
}

int GetFileMd5(const QString &fileName, QString &md5)
{
	QFile file(fileName);
	if ( !file.open(QIODevice::ReadOnly) )
		return file.error();

	QCryptographicHash hash(QCryptographicHash::Md5);
	while(!file.atEnd()){
		QByteArray data_md5_file=file.read(1024*1024);
		hash.addData(data_md5_file);
	}

	md5 = QString::fromLocal8Bit(hash.result().toHex());
	return 0;
}


QString MakeMd5(const QByteArray &dat)
{
	QCryptographicHash hash(QCryptographicHash::Md5);
	hash.addData(dat);
	return QString::fromLocal8Bit(hash.result().toHex());
}

QString makeUUID()
{
	QUuid guid = QUuid::createUuid();
	QString str = guid.toString();
	str.remove('{');
	str.remove('}');
	return str;
}


QString GetInifileString(const QString &grpName, const QString &keyName, const QString& fileName, const QString &defaultValue)
{
	QString result(defaultValue);

	QSettings settings(fileName, QSettings::IniFormat);
	settings.beginGroup(grpName);
	if (settings.contains(keyName))
	{
		result = settings.value(keyName).toString();
	}

	return result;
}

int GetIniFileInt(const QString &grpName, const QString &keyName, const QString& fileName, int defaultValue)
{
	QString strValue = GetInifileString(grpName, keyName, fileName);
	if (strValue.isEmpty())
		return defaultValue;
	return strValue.toInt();
}

bool SetInifileString(const QString &grpName, const QString &keyName, const QString &val, const QString& fileName)
{
	QSettings settings(fileName, QSettings::IniFormat);
	settings.beginGroup(grpName);
	settings.setValue(keyName, val);
	settings.endGroup();
	settings.sync();
	bool rslt = settings.status() != QSettings::NoError;
	return rslt;
}


void WidgetStyleUpdate(QWidget *pWnd)
{
	pWnd->style()->unpolish(pWnd);
	pWnd->style()->polish(pWnd);
}

CRVideoFrame loadImgAsCRVideoFrame(const QString &fileName)
{
	CRVideoFrame rslt;
	CRByteArray jpgDat;
	if (!ReadDataFromFile(fileName, jpgDat))
	{
		qDebug("read file failed!");
		return rslt;
	}

	QFileInfo qfInfo(fileName);
	QString fileSuffix = qfInfo.suffix();

	CRVSDK_ERR_DEF err;
	if ((err = g_sdkMain->coverToVideoFrame(jpgDat, fileSuffix.toUtf8().constData(), rslt)) != 0)
	{
		qDebug("decode jpg failed: %d!", err);
		return rslt;
	}

	//420p内部效率最高
	if (!g_sdkMain->videoFrameCover(rslt, CRVSDK_VFMT_YUV420P, rslt.getWidth(), rslt.getHeight()))
	{
		qDebug("decode jpg failed!");
		rslt.clear();
		return rslt;
	}
	return rslt;
}

QImage makeRefrenceImgFromCRAVFrame(const CRVideoFrame &frm)
{
	if (frm.getFormat() != CRVSDK_VFMT_0RGB32 && frm.getFormat() != CRVSDK_VFMT_ARGB32)
		return QImage();

	uint8_t* rgb[1];
	int      linesize[1];
	frm.getRawDatPtr(rgb, linesize, 1);
	QImage img = QImage(rgb[0], frm.getWidth(), frm.getHeight(), linesize[0], QImage::Format_RGB32);
	return img;
}

QImage makeImageFromCRAVFrame(const CRVideoFrame &frm)
{
	CRVideoFrame tmpFrm(frm);
	if (!g_sdkMain->videoFrameCover(tmpFrm, CRVSDK_VFMT_0RGB32, tmpFrm.getWidth(), tmpFrm.getHeight()))
	{
		return QImage();
	}

	QImage img = makeRefrenceImgFromCRAVFrame(tmpFrm);
	return img.copy();
}

QString getFileSizeStr(int64_t fsize)
{
	if (fsize > 1024 * 1024)
	{
		return QString::number(fsize / 1024 * 1024.0, 'f', 1) + "MB";
	}
	if (fsize > 1024)
	{
		return QString::number(fsize / 1024.0, 'f', 1) + "KB";
	}
	return QString::number(fsize) + "B";
}
