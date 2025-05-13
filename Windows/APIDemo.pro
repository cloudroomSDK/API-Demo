QT += core gui widgets
CONFIG += precompile_header qt
DEFINES += QT_DEPRECATED_WARNINGS
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0
#DEFINES += _GLIBCXX_USE_CXX11_ABI=0

TEMPLATE = app
TARGET = APIDemo
# Winodws
mingw {
error("unsupported mingw")
}
msvc {
DEFINES += WIN32
contains(QT_ARCH, i386): ARCHITECTURE = x86
else: ARCHITECTURE = $$QT_ARCH
QMAKE_LFLAGS_RELEASE += /MAP
QMAKE_CFLAGS_RELEASE += /Zi
QMAKE_LFLAGS_RELEASE += /debug /opt:ref
INCLUDEPATH += $$PWD/CRVideoSDK/include
LIBS += -L$$PWD/CRVideoSDK/lib/$$ARCHITECTURE/ -lCRBase -lCRVideoSDKCpp
LIBS += -luser32
}
# Linux
linux {
DEFINES += LINUX
ARCHITECTURE=$$QMAKE_HOST.arch
contains(QMAKE_HOST.arch, aarch64) || linux-aarch64-gnu-g++{
ARCHITECTURE=aarch64
}
contains(QMAKE_HOST.arch, arm) || linux-arm-gnueabihf-g++{
ARCHITECTURE=arm-linux-gnueabihf
}
INCLUDEPATH += $$PWD/CRVideoSDK/include
LIBS += -L$$PWD/CRVideoSDK/lib/$$ARCHITECTURE -lCRBase -lCRVideoSDKCpp
QMAKE_LFLAGS += -Wl,-rpath,./:$$PWD/CRVideoSDK/lib/$$ARCHITECTURE
DEFINES += LINUX
}
# MacOS
macx {
    DEFINES += MAC
    LIBS += -F$$PWD/CRVideoSDK/lib/CRBeauty
    LIBS += -framework CRBeauty
    LIBS += -F$$PWD/CRVideoSDK/lib/CRBeauty/vnn
    LIBS += -framework vnn_core_osx
    LIBS += -framework vnn_face_osx
    LIBS += -framework vnn_kit_osx

    # 定义所有 Framework 路径
    FRAMEWORK_PATHS = $$PWD/CRVideoSDK/lib/CRBeauty $$PWD/CRVideoSDK/lib/CRBeauty/vnn
    # 遍历路径并添加到 Bundle
    for(path, FRAMEWORK_PATHS) {
        FRAMEWORK_FILES = $$files($${path}/*.framework)
        for(fw, FRAMEWORK_FILES) {
            MY_FRAMEWORK_$${fw}.files = $${fw}
            MY_FRAMEWORK_$${fw}.path = /Contents/Frameworks
            QMAKE_BUNDLE_DATA += MY_FRAMEWORK_$${fw}
        }
    }
    QMAKE_LFLAGS += -Wl,-rpath,@loader_path/Frameworks

    INCLUDEPATH += $$PWD/CRVideoSDK/lib/libCRVideoSDKCpp.xcframework/macos-x86_64/Headers
    LIBS += -L$$PWD/CRVideoSDK/lib/libCRVideoSDKCpp.xcframework/macos-x86_64  -lCRVideoSDKCpp
    QMAKE_INFO_PLIST = Info.plist
}
DESTDIR = $$PWD/bin/$$ARCHITECTURE

PRECOMPILED_HEADER = $$PWD/src/stdafx.h

INCLUDEPATH += \
    $$PWD/src \
    $$PWD/src/Common \
    $$PWD/src/Controls \
    $$PWD/src/TestAudioSetting \
    $$PWD/src/TestCustomAudioCapture \
    $$PWD/src/TestCustomVideoCaptureRender \
    $$PWD/src/TestLocRecord \
    $$PWD/src/TestMediaPlay \
    $$PWD/src/TestRoomMsg \
    $$PWD/src/TestRoomUsrAttrs \
    $$PWD/src/TestSvrRecord \
    $$PWD/src/TestVideoSetting \
    $$PWD/src/TestVideoWall \
    $$PWD/src/TestEchoTest \
    $$PWD/src/TestNetCamera \
    $$PWD/src/TestVoiceChange \
    $$PWD/src/TestTestScreenShare \
    $$PWD/src/TestSubscribeAudio \
    $$PWD/src/TestVideoBeauty \
    $$PWD/src/TestVirtualBackground \

SOURCES += \
    src/stdafx.cpp \
    src/main.cpp \
    src/Common/Common.cpp \
    src/Common/ErrDesc.cpp \
    src/Common/JsonHelper.cpp \
    src/Common/KeepAspectRatioDrawer.cpp \
    src/Common/CRFPSStatistics.cpp \
    src/Controls/CustomRenderWidget.cpp \
    src/Controls/CustomRenderGLWidget.cpp \
    src/Controls/CanvasWidget.cpp \
    src/Controls/NetSignalWidget.cpp \
    src/Controls/SliderWithDescPoint.cpp \
    src/DlgLogin.cpp \
    src/DlgLoginSet.cpp \
    src/maindialog.cpp \
    src/ObjsDef.cpp \
    src/TestAudioSetting/DlgAudioSet.cpp \
    src/TestCustomAudioCapture/CustomAudioCapture.cpp \
    src/TestCustomVideoCaptureRender/CustomVideoCaptureRender.cpp \
    src/TestLocRecord/DlgLocalRecord.cpp \
    src/TestMediaPlay/MediaPlayUI.cpp \
    src/TestMediaPlay/mediatoolbar.cpp \
    src/TestRoomMsg/DlgRoomMsg.cpp \
    src/TestRoomUsrAttrs/DlgAddOrEditAttr.cpp \
    src/TestRoomUsrAttrs/DlgRoomAttrs.cpp \
    src/TestRoomUsrAttrs/DlgUserAttrs.cpp \
    src/TestRoomUsrAttrs/DlgUserSelect.cpp \
    src/TestSvrRecord/DlgServerRecord.cpp \
    src/TestVideoSetting/DlgVideoSet.cpp \
    src/TestVideoWall/KVideoUI.cpp \
    src/TestVideoWall/VideoWallPage.cpp \
    src/TestEchoTest/DlgEchoTest.cpp \
    src/TestNetCamera/DlgNetCamera.cpp \
    src/TestVoiceChange/DlgVoiceChange.cpp \
    src/TestScreenShare/ScreenShareUI.cpp \
    src/TestScreenShare/ScreenMarkView.cpp \
    src/TestScreenShare/CThumbnailItem.cpp \
    src/TestScreenShare/ShareSourceSelectDlg.cpp \
    src/TestScreenShare/DlgScreenMark.cpp \
    src/TestScreenShare/KeyBoardCatcher.cpp \
    src/TestSubscribeAudio/DlgSubscribeAudio.cpp \
    src/TestVoiceChange/CustomVoiceChgDlg.cpp \
    src/TestVideoBeauty/TestVideoBeauty.cpp \
    src/TestVirtualBackground/TestVirtualBackground.cpp \

HEADERS += \
    src/stdafx.h \
    src/AccountInfo.h \
    src/Common/Common.h \
    src/Common/ErrDesc.h \
    src/Common/JsonHelper.h \
    src/Common/KeepAspectRatioDrawer.h \
    src/Common/CRFPSStatistics.h \
    src/Controls/CustomRenderWidget.h \
    src/Controls/CustomRenderGLWidget.h \
    src/Controls/CanvasWidget.h \
    src/Controls/NetSignalWidget.h \
    src/Controls/SliderWithDescPoint.h \
    src/DlgLogin.h \
    src/DlgLoginSet.h \
    src/maindialog.h \
    src/ObjsDef.h \
    src/TestAudioSetting/DlgAudioSet.h \
    src/TestCustomAudioCapture/CustomAudioCapture.h \
    src/TestCustomVideoCaptureRender/CustomVideoCaptureRender.h \
    src/TestLocRecord/DlgLocalRecord.h \
    src/TestMediaPlay/MediaPlayUI.h \
    src/TestMediaPlay/mediatoolbar.h \
    src/TestRoomMsg/DlgRoomMsg.h \
    src/TestRoomUsrAttrs/DlgAddOrEditAttr.h \
    src/TestRoomUsrAttrs/DlgRoomAttrs.h \
    src/TestRoomUsrAttrs/DlgUserAttrs.h \
    src/TestRoomUsrAttrs/DlgUserSelect.h \
    src/TestSvrRecord/DlgServerRecord.h \
    src/TestVideoSetting/DlgVideoSet.h \
    src/TestVideoWall/KVideoUI.h \
    src/TestVideoWall/VideoWallPage.h \
    src/TestEchoTest/DlgEchoTest.h \
    src/TestNetCamera/DlgNetCamera.h \
    src/TestVoiceChange/DlgVoiceChange.h \
    src/TestScreenShare/ScreenShareUI.h \
    src/TestScreenShare/ScreenMarkView.h \
    src/TestScreenShare/DlgScreenMark.h \
    src/TestScreenShare/CThumbnailItem.h \
    src/TestScreenShare/ShareSourceSelectDlg.h \
    src/TestScreenShare/KeyBoardCatcher.h \
    src/TestScreenShare/VirtualKey_Def.h \
    src/TestSubscribeAudio/DlgSubscribeAudio.h \
    src/TestVoiceChange/CustomVoiceChgDlg.h \
    src/TestVideoBeauty/TestVideoBeauty.h \
    src/TestVirtualBackground/TestVirtualBackground.h \

FORMS += \
    src/DlgLogin.ui \
    src/DlgLoginSet.ui \
    src/maindialog.ui \
    src/TestAudioSetting/DlgAudioSet.ui \
    src/TestCustomAudioCapture/CustomAudioCapture.ui \
    src/TestCustomVideoCaptureRender/CustomVideoCaptureRender.ui \
    src/TestLocRecord/DlgLocalRecord.ui \
    src/TestMediaPlay/MediaPlayUI.ui \
    src/TestMediaPlay/mediatoolbar.ui \
    src/TestRoomMsg/DlgRoomMsg.ui \
    src/TestRoomUsrAttrs/DlgAddOrEditAttr.ui \
    src/TestRoomUsrAttrs/DlgRoomAttrs.ui \
    src/TestRoomUsrAttrs/DlgUserAttrs.ui \
    src/TestRoomUsrAttrs/DlgUserSelect.ui \
    src/TestRoomUsrAttrs/UserItemWidget.ui \
    src/TestSvrRecord/DlgServerRecord.ui \
    src/TestSvrRecord/DlgServerRecordResult.ui \
    src/TestVideoSetting/DlgVideoSet.ui \
    src/TestVideoWall/KVideoUI.ui \
    src/TestVideoWall/VideoWallPage.ui \
    src/TestEchoTest/DlgEchoTest.ui \
    src/TestNetCamera/DlgNetCamera.ui \
    src/TestVoiceChange/DlgVoiceChange.ui \
    src/TestVoiceChange/VoiceChangeItem.ui \
    src/TestScreenShare/ScreenShareUI.ui \
    src/TestScreenShare/ScreenSharerToolBar.ui \
    src/TestScreenShare/CThumbnailItem.ui \
    src/TestScreenShare/ShareSourceSelectDlg.ui \
    src/TestSubscribeAudio/DlgSubscribeAudio.ui \
    src/TestVoiceChange/CustomVoiceChgDlg.ui \
    src/TestVoiceChange/VoiceCustomSetting.ui \
    src/TestVideoBeauty/TestVideoBeauty.ui \
    src/TestVirtualBackground/TestVirtualBackground.ui \

RESOURCES += \
    src/APIDemo.qrc
