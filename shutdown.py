#!/bin/python3

import os
import subprocess
# import platform
# from platform import OsInfo

def stopDepends():
    print("Shutdown ...")
    os.chdir("depends")
    subprocess.run(['docker-compose', 'stop'])
    return True


def shutdown():
    result = stopDepends()
    if(result):
        print("Stop successful.")
    else:
        print("Stop failed.")

shutdown()