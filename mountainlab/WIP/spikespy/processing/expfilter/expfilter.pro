#-------------------------------------------------
#
# Project created by QtCreator 2015-03-28T17:43:59
#
#-------------------------------------------------

QT       += core

QT       -= gui

CONFIG += c++11

OBJECTS_DIR = build
MOC_DIR = build
DESTDIR = ../../bin
TARGET = expfilter
CONFIG   += console
CONFIG   -= app_bundle

TEMPLATE = app


SOURCES += main.cpp expfilter.cpp

HEADERS += expfilter.h

#DEFINES += USE_REMOTE_MDA
INCLUDEPATH += ../../../common/mda
DEPENDPATH += ../../../common/mda
VPATH += ../../../common/mda
HEADERS += diskreadmda.h diskwritemda.h usagetracking.h mda.h mdaio.h
SOURCES += diskreadmda.cpp diskwritemda.cpp usagetracking.cpp mda.cpp mdaio.cpp
HEADERS += remotereadmda.h
SOURCES += remotereadmda.cpp

INCLUDEPATH += ../../../common/cachemanager
DEPENDPATH += ../../../common/cachemanager
VPATH += ../../../common/cachemanager
HEADERS += cachemanager.h
SOURCES += cachemanager.cpp

INCLUDEPATH += ../../../common/utils
DEPENDPATH += ../../../common/utils
VPATH += ../../../common/utils
HEADERS += textfile.h taskprogress.h
SOURCES += textfile.cpp taskprogress.cpp

INCLUDEPATH += ../../../common/commandlineparams
DEPENDPATH += ../../../common/commandlineparams
VPATH += ../../../common/commandlineparams
HEADERS += commandlineparams.h
SOURCES += commandlineparams.cpp

INCLUDEPATH += ../../../mountainsort/src/utils
DEPENDPATH += ../../../mountainsort/src/utils
VPATH += ../../../mountainsort/src/utils
HEADERS += msmisc.h
SOURCES += msmisc.cpp

INCLUDEPATH += ../../../common
DEPENDPATH += ../../../common
VPATH += ../../../common
HEADERS += mlutils.h
SOURCES += mlutils.cpp
