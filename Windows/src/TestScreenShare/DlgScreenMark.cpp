#include "stdafx.h"
#include "DlgScreenMark.h"
#include "ScreenMarkView.h"

DlgScreenMark::DlgScreenMark(bool bForSharer, QWidget *parent, Qt::WindowFlags flags)
	: QDialog(parent, flags)
{
    this->setObjectName("DlgScreenMark");

    m_markView = new ScreenMarkView(bForSharer, this);
    m_clearBtn = new QPushButton(this);
    m_clearBtn->setObjectName("clearMarkBtn");
    m_clearBtn->setCursor(QCursor(Qt::PointingHandCursor));
    m_clearBtn->setStyleSheet("#clearMarkBtn{	background: rgb(0,0,0,200); \
                                border: 1px solid rgb(255, 255, 255); \
                                color: rgb(255, 255, 255); \
                                border-radius: 3px; \
                                padding-left: 4px; \
                                padding-right: 4px;}");
    m_clearBtn->setText(tr("清空标注"));
    m_clearBtn->raise();
    connect(m_clearBtn, &QToolButton::clicked, this, &DlgScreenMark::slot_clearMarkClicked);
}

DlgScreenMark::~DlgScreenMark()
{
    delete m_markView;
    m_markView = NULL;
}

void DlgScreenMark::SetScreenPixmap(const CRVideoFrame &frm)
{
    if (frm.getWidth() <= 0 || frm.getHeight() <= 0)
        return;

	QImage img = makeImageFromCRAVFrame(frm);
    m_markView->SetScreenPixmap(img);
    updateView();
}

bool DlgScreenMark::HasScreenPixmap()
{
    return !m_markView->GetScreenPixmap().isNull();
}

void DlgScreenMark::updateView()
{
    QSize imgSz = m_markView->GetScreenPixmap().size();
    imgSz.scale(this->size(), Qt::KeepAspectRatio);
    m_markView->resize(imgSz);
    m_markView->move((this->width() - imgSz.width()) / 2, (this->height() - imgSz.height()) / 2);
    m_clearBtn->setFixedSize(100, 30);
    m_clearBtn->move(0, 0);
}

void DlgScreenMark::resizeEvent(QResizeEvent *event)
{
	QWidget::resizeEvent(event);
    updateView();
}

void DlgScreenMark::paintEvent(QPaintEvent *event)
{
	QStyleOption opt;
	opt.init(this);
	QPainter p(this);
	style()->drawPrimitive(QStyle::PE_Widget, &opt, &p, this);
}

void DlgScreenMark::slot_clearMarkClicked()
{
	//清空标注
    g_sdkMain->getSDKMeeting().clearScreenMarks();

// 	QStringList delMark;
// 	for (auto &info : m_markView->m_allMarks)
// 	{
// 		delMark.append(info->_id);
// 	}
// 	QByteArray jsonData = CoverJsonToString(QVariant(delMark));
// 	g_sdkMain->getSDKMeeting().delScreenMarkData(jsonData.constData());
}
