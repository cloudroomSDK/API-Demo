#ifndef __COMMON_H__
#define __COMMON_H__

inline QString stdStrToQStr(const std::string &a)
{
    return QString::fromUtf8(a.c_str(), (int)a.length());
}
inline std::string qStrToStdStr(const QString &a)
{
	QByteArray utf8 = a.toUtf8();
	return std::string(utf8.constData(), utf8.length());
}
inline CRString qStrToCRStr(const QString &a)
{
	QByteArray utf8 = a.toUtf8();
	return CRByteArray(utf8.constData(), utf8.length());
}
inline QString crStrToQStr(const CRString &a)
{
	return QString::fromUtf8(a.constData(), a.length());
}
inline QByteArray crStrToByteArray(const CRString &a)
{
	return QByteArray(a.constData(), a.length());
}

QString GetPlatFormName();

QDateTime CoverTime(int time);
//[HH:]MM:SS
QString CoverDuration2Str(int seconds);

QString AddBackslashAtBegin(const QString &path);
QString RmBackslashAtBegin(const QString &path);
QString AddBackslashAtend(const QString &path);
QString RmBackslashAtend(const QString &path);
QString CorrectBackslashFormat(const QString &pathName);
QString FileNameIllegalCharDeal(const QString &NoPathfileName);

bool ReadDataFromFile(const QString &fileName, QByteArray &dat);
bool ReadDataFromFile(const QString &fileName, CRByteArray &data);
bool WriteDataToFile(const QByteArray &dat, const QString &fileName, bool bAppend=false);
int GetFileMd5(const QString &fileName, QString &md5);
QString MakeMd5(const QByteArray &dat);
QString makeUUID();

QString GetInifileString(const QString &grpName, const QString &keyName, const QString& fileName, const QString &defaultValue = "");
int GetIniFileInt(const QString &grpName, const QString &keyName, const QString& fileName, int defaultValue = 0);
bool SetInifileString(const QString &grpName, const QString &keyName, const QString &val, const QString& fileName);

void WidgetStyleUpdate(QWidget *pWnd);

CRVideoFrame loadImgAsCRVideoFrame(const QString &fileName);
QString getFileSizeStr(int64_t fsize);

//frm必须是RGB格式， image数据将引用frm中数据， 需要确保frm生命周期足够
QImage makeRefrenceImgFromCRAVFrame(const CRVideoFrame &frm);
//内部将copy图像数据，image不再依赖frm，开销较大
QImage makeImageFromCRAVFrame(const CRVideoFrame &frm);

#endif //__COMMON_H__
