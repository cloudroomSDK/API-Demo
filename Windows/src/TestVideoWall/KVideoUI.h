#ifndef KVIDEOUI_H
#define KVIDEOUI_H

#include "CustomRenderWidget.h"
#include "CustomRenderGLWidget.h"


QT_BEGIN_NAMESPACE
namespace Ui { class KVideoUI; }
QT_END_NAMESPACE

#if 1
#	define CustomRenderBase CustomVideoView
#else
#	define CustomRenderBase CustomVideoView_GL
#endif

class KVideoUI : public CustomRenderBase
{
	Q_OBJECT

public:
	KVideoUI(QWidget* pParent = 0);
	virtual ~KVideoUI();

	//恢复初始值
	void clean();

	void setVideoInfo(const char* userID);
	void setVideoInfo(const CRVSDK::CRUserVideoID &cam);

	void updateNickname(const QString &nickname);
	void updateNetState(int level);
	void updateMicStatus(CRVSDK_ASTATUS aStatus);
	void updateMicEnergy(int level);
	void updateCamStatus(CRVSDK_VSTATUS vStatus);

	const CRVSDK::CRUserVideoID &getUsrCamID() const { return m_vId; }
	const CRBase::CRString &getUserId() const {	return m_vId._userID; }
	int getCameraId() const { return m_vId._videoID; }

	bool isRenderState() const;

protected:
	void mouseDoubleClickEvent(QMouseEvent *event) override;
	void contextMenuEvent(QContextMenuEvent *event) override;

private slots:
	void slot_btnMicClicked();
	void slot_btnCamClicked();
	void slot_btnMirrorClicked();
	void slot_btnRotateClicked();
	void slot_upNetInfo();
	void slot_savePic();

private:
	void initAllPics();
	void updateBtnState(const CRBase::CRString &nickname, CRVSDK_ASTATUS aStatus, CRVSDK_VSTATUS vStatus);
	void updateRenderState();

private:
	Ui::KVideoUI	*ui{ nullptr };
	CRUserVideoID	m_vId;
	CRVSDK_ASTATUS	m_aST{ CRVSDK_AST_UNKNOWN };
	CRVSDK_VSTATUS	m_vST{ CRVSDK_VST_UNKNOWN };
	int				m_micEnergyLv{ 0 };

	bool			m_mineVideo;
	int				m_videoRotate;
	QTimer			m_upNetInfoTimer;

	QPointer<KVideoUI> m_fullVideoUI;
};


#endif // KVIDEOUI_H
