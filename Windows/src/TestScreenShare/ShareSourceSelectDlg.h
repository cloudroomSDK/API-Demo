<<<<<<< HEAD
#ifndef SHARESOURCESELECTDLG_H
#define SHARESOURCESELECTDLG_H

#include <QWidget>
namespace Ui {class ShareSourceSelectDlg;};

class ShareSourceSelectDlg : public QDialog
{
	Q_OBJECT

public:
	ShareSourceSelectDlg(QWidget *parent = 0);
	~ShareSourceSelectDlg();

	CRVSDK_SCREENCAPTURESOURCE_TYPE getShareType();
	int getScreenID();
	WId getShareWId();
	bool isShareVoice();
	bool isFluencyMode();

protected:
	void showEvent(QShowEvent *event) override;

protected:
	void addScreenThumbnail(int w, int h);
	void addPogramThumbnail(int w, int h);

protected slots:
	void on_startScreenBtn_clicked();
	void on_currentItemchanged(QListWidgetItem *current, QListWidgetItem *previous);
	void on_itemDoubleClicked(QListWidgetItem*);

private:
	Ui::ShareSourceSelectDlg *ui;
};

#endif // SHARESOURCESELECTDLG_H
=======
#ifndef SHARESOURCESELECTDLG_H
#define SHARESOURCESELECTDLG_H

#include <QWidget>
namespace Ui {class ShareSourceSelectDlg;};

class ShareSourceSelectDlg : public QDialog
{
	Q_OBJECT

public:
	ShareSourceSelectDlg(QWidget *parent = 0);
	~ShareSourceSelectDlg();

	CRVSDK_SCREENCAPTURESOURCE_TYPE getShareType();
	int getScreenID();
	WId getShareWId();
	bool isShareVoice();
	bool isFluencyMode();

protected:
	void showEvent(QShowEvent *event) override;

protected:
	void addScreenThumbnail(int w, int h);
	void addPogramThumbnail(int w, int h);

protected slots:
	void on_startScreenBtn_clicked();
	void on_currentItemchanged(QListWidgetItem *current, QListWidgetItem *previous);
	void on_itemDoubleClicked(QListWidgetItem*);

private:
	Ui::ShareSourceSelectDlg *ui;
};

#endif // SHARESOURCESELECTDLG_H
>>>>>>> 6984688657bdef974c6ed098412b4f00ba77193f
