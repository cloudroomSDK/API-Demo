#include "stdafx.h"
#include "ObjsDef.h"

QString getBeautyFilterTypeName(BeautyFilterType type)
{
	switch (type)
	{
	case BeautySmooth: return QObject::tr("磨皮");
	case BeautyWhiten: return QObject::tr("美白");
	case BeautyLipstick: return QObject::tr("红唇");
	case BeautyBlusher: return QObject::tr("腮红");
	case BeautyThinFace:return QObject::tr("瘦脸");
	case BeautyBigEye:return QObject::tr("大眼");
	default: return "";
	}
}

void Struct_Cov(const QVariantMap &src, VideoCfg &dst)
{
	if (src.empty())
	{
		return;
	}

	QStringList varLst = src.value("size").toString().split('*');
	if (varLst.size() > 1)
	{
		dst._size.setWidth(varLst[0].toInt());
		dst._size.setHeight(varLst[1].toInt());
	}
	dst._fps = src.value("fps", dst._fps).toInt();
	dst._maxbps = src.value("maxbps", dst._maxbps).toInt();
	dst._min_qp = src.value("qp_min", dst._min_qp).toInt();
	dst._max_qp = src.value("qp_max", dst._max_qp).toInt();
}

void Struct_Cov(const VideoCfg &src, QVariantMap &dst)
{
	dst["fps"] = src._fps;
	dst["maxbps"] = src._maxbps;
	dst["qp_min"] = src._min_qp;
	dst["qp_max"] = src._max_qp;
	if (!src._size.isEmpty())
	{
		dst["size"] = QString("%1*%2").arg(src._size.width()).arg(src._size.height());
	}
}


void Struct_Cov(const QVariantMap &src, VideoEffectsObj &dst)
{
	dst._denoise = src.value("denoise", dst._denoise).toInt();
	dst._mirror = src.value("mirror", dst._mirror).toInt();
}

void Struct_Cov(const VideoEffectsObj &src, QVariantMap &dst)
{
	dst["denoise"] = src._denoise;
	dst["mirror"] = src._mirror;
}

void Struct_Cov(const QVariantMap &src, BeautyCfg &dst)
{
	dst.filters.clear();
	QVariantList filters = src.value("filters").toList();
	for (int i = 0; i < filters.size(); i++)
	{
		QVariantMap item = filters[i].toMap();
		BeautyFilterType type = (BeautyFilterType) item.value("type").toInt();
		float lv = item.value("level").toFloat();
		dst.filters[type] = lv;
	}
}

void Struct_Cov(const BeautyCfg &src, QVariantMap &dst)
{
	QVariantList filters;
	for (auto &pir : src.filters)
	{
		if (pir.second > 0.000001)
		{
			QVariantMap item;
			item["type"] = int(pir.first);
			item["level"] = pir.second;
			filters.push_back(item);
		}
	}
	if (filters.size() > 0)
	{
		dst["filters"] = filters;
	}
}
