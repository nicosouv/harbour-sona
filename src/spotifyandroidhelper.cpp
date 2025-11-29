#include "spotifyandroidhelper.h"
#include <QDebug>

SpotifyAndroidHelper::SpotifyAndroidHelper(QObject *parent)
    : QObject(parent)
    , m_checkInstalledProcess(nullptr)
    , m_checkRunningProcess(nullptr)
    , m_launchProcess(nullptr)
{
}

SpotifyAndroidHelper::~SpotifyAndroidHelper()
{
    if (m_checkInstalledProcess) {
        m_checkInstalledProcess->kill();
        m_checkInstalledProcess->deleteLater();
    }
    if (m_checkRunningProcess) {
        m_checkRunningProcess->kill();
        m_checkRunningProcess->deleteLater();
    }
    if (m_launchProcess) {
        m_launchProcess->kill();
        m_launchProcess->deleteLater();
    }
}

void SpotifyAndroidHelper::checkInstalled()
{
    qDebug() << "SpotifyAndroidHelper: Checking if Spotify Android is installed";

    if (m_checkInstalledProcess) {
        m_checkInstalledProcess->deleteLater();
    }

    m_checkInstalledProcess = new QProcess(this);
    connect(m_checkInstalledProcess, SIGNAL(finished(int,QProcess::ExitStatus)),
            this, SLOT(onCheckInstalledFinished(int,QProcess::ExitStatus)));

    // List all packages and capture output
    m_checkInstalledProcess->start("apkd-launcher", QStringList() << "--list-packages");
}

void SpotifyAndroidHelper::onCheckInstalledFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    bool installed = false;

    if (exitStatus == QProcess::NormalExit) {
        QString output = QString::fromUtf8(m_checkInstalledProcess->readAllStandardOutput());
        QString errorOutput = QString::fromUtf8(m_checkInstalledProcess->readAllStandardError());

        qDebug() << "SpotifyAndroidHelper: apkd-launcher exit code:" << exitCode;
        qDebug() << "SpotifyAndroidHelper: stdout:" << output;
        qDebug() << "SpotifyAndroidHelper: stderr:" << errorOutput;

        installed = output.contains("com.spotify.music");

        if (installed) {
            qDebug() << "SpotifyAndroidHelper: Spotify Android is installed";
        } else {
            qDebug() << "SpotifyAndroidHelper: Spotify Android is NOT installed";
        }
    } else {
        qDebug() << "SpotifyAndroidHelper: Process crashed or failed";
    }

    emit installedResult(installed);

    m_checkInstalledProcess->deleteLater();
    m_checkInstalledProcess = nullptr;
}

void SpotifyAndroidHelper::checkRunning()
{
    qDebug() << "SpotifyAndroidHelper: Checking if Spotify Android is running";

    if (m_checkRunningProcess) {
        m_checkRunningProcess->deleteLater();
    }

    m_checkRunningProcess = new QProcess(this);
    connect(m_checkRunningProcess, SIGNAL(finished(int,QProcess::ExitStatus)),
            this, SLOT(onCheckRunningFinished(int,QProcess::ExitStatus)));

    // Check if the process is running
    m_checkRunningProcess->start("pgrep", QStringList() << "-f" << "com.spotify.music");
}

void SpotifyAndroidHelper::onCheckRunningFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    bool running = false;

    if (exitStatus == QProcess::NormalExit) {
        QString output = QString::fromUtf8(m_checkRunningProcess->readAllStandardOutput());

        qDebug() << "SpotifyAndroidHelper: pgrep exit code:" << exitCode;
        qDebug() << "SpotifyAndroidHelper: pgrep output:" << output;

        // pgrep returns 0 if found, 1 if not found
        running = (exitCode == 0 && !output.trimmed().isEmpty());

        if (running) {
            qDebug() << "SpotifyAndroidHelper: Spotify Android is running";
        } else {
            qDebug() << "SpotifyAndroidHelper: Spotify Android is NOT running";
        }
    } else {
        qDebug() << "SpotifyAndroidHelper: pgrep process crashed or failed";
    }

    emit runningResult(running);

    m_checkRunningProcess->deleteLater();
    m_checkRunningProcess = nullptr;
}

void SpotifyAndroidHelper::launch()
{
    qDebug() << "SpotifyAndroidHelper: Launching Spotify Android";

    if (m_launchProcess) {
        m_launchProcess->deleteLater();
    }

    m_launchProcess = new QProcess(this);
    connect(m_launchProcess, SIGNAL(finished(int,QProcess::ExitStatus)),
            this, SLOT(onLaunchFinished(int,QProcess::ExitStatus)));

    // Launch the app
    m_launchProcess->start("apkd-launcher", QStringList() << "--start" << "com.spotify.music");
}

void SpotifyAndroidHelper::onLaunchFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    QString output = QString::fromUtf8(m_launchProcess->readAllStandardOutput());
    QString errorOutput = QString::fromUtf8(m_launchProcess->readAllStandardError());

    qDebug() << "SpotifyAndroidHelper: Launch exit code:" << exitCode;
    qDebug() << "SpotifyAndroidHelper: Launch stdout:" << output;
    qDebug() << "SpotifyAndroidHelper: Launch stderr:" << errorOutput;

    bool success = (exitStatus == QProcess::NormalExit && exitCode == 0);

    if (success) {
        qDebug() << "SpotifyAndroidHelper: Spotify Android launch command succeeded";
    } else {
        qDebug() << "SpotifyAndroidHelper: Spotify Android launch command failed";
    }

    emit launchResult(success);

    m_launchProcess->deleteLater();
    m_launchProcess = nullptr;
}
