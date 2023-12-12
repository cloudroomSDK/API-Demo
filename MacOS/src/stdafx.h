#ifndef STDAFX_H
#define STDAFX_H

#if defined(_MSC_VER) && (_MSC_VER >= 1600)    
# pragma execution_character_set("utf-8")    
#endif

#include <QtGui>
#include <QtCore>
#include <QtWidgets>


#include <CRVideoSDK_Def.h>
#include <CRVideoSDK_Objs.h>
#include <CRVideoSDKMain.h>
#include <CRVideoSDKMeeting.h>

using namespace CRBase;
using namespace CRVSDK;

#include "Common.h"
#include "ErrDesc.h"
#include "ObjsDef.h"

extern QString g_cfgFile;
extern CRVideoSDKMain*	g_sdkMain;

#endif
