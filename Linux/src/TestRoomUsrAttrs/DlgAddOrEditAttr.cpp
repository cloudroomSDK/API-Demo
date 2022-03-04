#include "stdafx.h"
#include "DlgAddOrEditAttr.h"
#include "maindialog.h"

DlgAddOrEditAttr::DlgAddOrEditAttr(QWidget *parent)
	: QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);
	connect(ui.btnAddOrEdit, &QPushButton::clicked, this, &DlgAddOrEditAttr::slot_btnAddOrEditClicked);
	connect(ui.btnCancel, &QPushButton::clicked, this, &DlgAddOrEditAttr::slot_btnCancelClicked);

	m_isEdit = false;

	ui.btnAddOrEdit->setText(tr("新增"));
	this->setWindowTitle(tr("新增"));
}

DlgAddOrEditAttr::~DlgAddOrEditAttr()
{
}

void DlgAddOrEditAttr::setKeyValue(const QString &key, const QString &value)
{
	if(key.isEmpty() && value.isEmpty())
		return;

	m_isEdit = true;
	ui.btnAddOrEdit->setText(tr("修改"));
	this->setWindowTitle(tr("修改"));
	ui.le_keyStr->setText(key);
	ui.le_keyStr->setEnabled(false);
	ui.le_valueStr->setText(value);
}

void DlgAddOrEditAttr::getKeyValue(QString &key, QString &value)
{
	key = ui.le_keyStr->text();
	value = ui.le_valueStr->text();
}

void DlgAddOrEditAttr::slot_btnAddOrEditClicked()
{
	done(QDialog::Accepted);
}

void DlgAddOrEditAttr::slot_btnCancelClicked()
{
	done(QDialog::Rejected);
}

