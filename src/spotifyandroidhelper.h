#ifndef SPOTIFYANDROIDHELPER_H
#define SPOTIFYANDROIDHELPER_H

#include <QObject>
#include <QProcess>

class SpotifyAndroidHelper : public QObject
{
    Q_OBJECT

public:
    explicit SpotifyAndroidHelper(QObject *parent = nullptr);
    ~SpotifyAndroidHelper();

    Q_INVOKABLE void checkInstalled();
    Q_INVOKABLE void checkRunning();
    Q_INVOKABLE void launch();

signals:
    void installedResult(bool installed);
    void runningResult(bool running);
    void launchResult(bool success);

private slots:
    void onCheckInstalledFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onCheckRunningFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onLaunchFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    QProcess *m_checkInstalledProcess;
    QProcess *m_checkRunningProcess;
    QProcess *m_launchProcess;
};

#endif // SPOTIFYANDROIDHELPER_H
