#!/usr/bin/python
from sys import argv
from math import atan, cos, sin, sqrt

def cal(node, slot_list):
    if len(slot_list) < 2:
        x1, y1, t1 = 0, 0, 0
    else:
        x1, y1, t1 = slot_list[1][node]
    x0, y0, t0 = slot_list[0][node]
    
    dx = x1 - x0 + 1e-10
    dy = y1 - y0
    v = sqrt((dx)**2 + (dy)**2) / (t1 - t0)
    theta = atan(dy / dx)
    if theta < 0:
    	theta = theta + 360	
    return x1, y1, t1, v, theta

def let(a, b, c, d):
    r = 250
    val = -(a*b + c*d)
    val += sqrt((a**2 + c**2) * r**2 - (a*d - b*c)**2)
    val /= (a**2 + c**2 + 1e-10)
    return val

def find_min(l):
    min_val = l[0][2]
    for i in l[1:]:
        min_val = min(i[2], min_val)
    return min_val

if __name__ == '__main__':
    argv.append('node1.txt')
    node_id = int(argv[1].split('node')[-1].split('.')[0])
    with open(argv[1], 'r') as f:
        raw_data = f.read()[4:-1]
        
        slots = raw_data.split('\n###\n')[-3:]
        
        
        slot_list = []
        for slot in slots:
            slot_tmp = {}
            for line in slot.split('\n'):
                l = [float(i) for i in line.split(',')]
                slot_tmp[l[0]] = l[1:]
            slot_list.append(slot_tmp)

    
    if len(slot_list) >= 2:
        xi, yi, ti, vi, thetai = cal(node_id, slot_list)
#        print ti

        let_vals = []
        for node in slot_list[1]:
            if node == node_id:
                continue
            if node in slot_list[0]:
                xj, yj, tj, vj, thetaj = cal(node, slot_list)
                a = vi * cos(thetai) - vj * cos(thetaj)
                b = xi - xj
                c = vi * sin(thetai) - vj * sin(thetaj)
                d = yi - yj
                LET = let(a, b, c, d)
                let_vals.append([ti, node, LET])
                

        with open('let%i.txt' % node_id, 'a+') as f:
            for _, node, let in let_vals:
                f.write('%f,%i,%s\n' % (ti, node, let))

        if let_vals:
            with open('hello_interval%i' % node_id, 'w+') as f:
                f.write(str(find_min(let_vals)))
                
                