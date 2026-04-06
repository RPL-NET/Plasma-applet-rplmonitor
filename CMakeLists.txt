cmake_minimum_required(VERSION 3.16)
project(plasma-applet-rplmonitor)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)

plasma_install_package(. org.rpl.rplmonitor)
