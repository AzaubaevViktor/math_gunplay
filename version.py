#!/usr/bin/env python
# -*- coding:utf-8 -*-
__author__ = 'ktulhy'

import subprocess
import datetime

def generate_version():
    proc = subprocess.Popen("git describe --long --tags", shell=True, stdout=subprocess.PIPE)
    version_raw = proc.stdout.readline().rstrip().lstrip()

    version_raw = version_raw if version_raw else "v0.0-0-0"

    version_raw = version_raw.split("-")

    major, _t = version_raw[0][1:].split(".")

    minor, typ = "0", "0"

    if 'a' in _t:
        minor, typ = _t.split("a")
        typ = "a" + typ
    elif 'b' in _t:
        minor, typ = _t.split("b")
        typ = "b" + typ
    else:
        minor, typ = _t, ""

    # +1 because script run before commit
    version = "%s.%s.%d%s" % (major, minor, int(version_raw[1]) + 1, typ)

    proc = subprocess.Popen("git show -s --format='%ct'", shell=True, stdout=subprocess.PIPE)
    date = proc.stdout.readline()

    date = datetime.datetime.fromtimestamp(
        int(date)
    ).strftime('%d.%m.%Y')

    return version, date

open("js/version.js", "wt").write("""var __version__ = "%s";
var __date__ = "%s";""" %generate_version())
