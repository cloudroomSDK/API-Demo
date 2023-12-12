#include "stdafx.h"
#include "JsonHelper.h"
#include <QJsonDocument> 

QByteArray CoverJsonToString(const QVariant &JsonData)
{
	return QJsonDocument::fromVariant(JsonData).toJson(QJsonDocument::Compact);
}

QVariant CoverStringToJson(const QByteArray &JsonData)
{
    return QJsonDocument::fromJson(JsonData).toVariant();
}
