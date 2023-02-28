#!/usr/bin/python3

import os
from datetime import datetime, timedelta
import time

cap_cmd1 = "gphoto2 --set-config /main/capturesettings/shutterspeed="
cap_cmd2 = "s --set-config capturetarget=1 --trigger-capture"
cap_cmd3 = "s --capture-image-and-download"

base_exp = 0.0008 # 1/1250
max_exp = 0.005 # 1/200
totality_exp = 5
interval = 15
ev_step = 3.333
frames = 4

p1 = datetime(2022, 11, 8,  8, 2, 17)
u1 = datetime(2022, 11, 8,  9, 9, 12)
u2 = datetime(2022, 11, 8, 10, 16, 39)
u3 = datetime(2022, 11, 8, 11, 41, 37)
u4 = datetime(2022, 11, 8, 12, 49, 3)
p4 = datetime(2022, 11, 8, 13, 56, 8)

def send_single_cap(exp):
    cap_cmd = cap_cmd1 + str(exp) + cap_cmd2
    os.popen(cap_cmd).read()

def send_hdr_bkt(ev_step, frames, min_exp):
    for sub in range(frames):
        cur_exp = min_exp * (2 ** (ev_step * sub))
        print("Sub", sub, "exp", cur_exp)
        cap_cmd = cap_cmd1 + str(cur_exp) + cap_cmd2
        os.popen(cap_cmd).read()

def partial_eclipse(percent, ev_step, frames):
    cur_base = percent * (max_exp - base_exp) + base_exp
    send_hdr_bkt(ev_step, frames, cur_base)



while True:
    now = datetime.utcnow()
    if now > p4:
        print("Eclipse ended")
        break
    if (now > p1 and now <= u1) or (now > u4 and now <= p4):
        send_single_cap(base_exp)
    if (now > u2 and now <= u3):
        send_single_cap(totality_exp)
    if (now > u1 and now <= u2):
        percentage = (now - u1) / (u2 - u1)
        partial_eclipse(percentage, ev_step, frames)
    if (now > u3 and now <= u4):
        percentage = (u4 - now) / (u4 - u3)
        partial_eclipse(percentage, ev_step, frames)
    if now < p1:
        print("Eclipse start in", (p1 - now).total_seconds(), "sec")
    
    # wait
    remaining_time = now - datetime.utcnow()
    remain_sec = remaining_time.total_seconds() + interval
    if remain_sec > 0:
        time.sleep(remain_sec)
    