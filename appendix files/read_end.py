#!/usr/bin/python

if __name__ == '__main__':
    lines = open('/home/maryam/Desktop/karshenasi/new/destination-node.txt', 'r').read().split('\n')
    f = open('last_line', 'w+')
    f.write(lines[-2])
    f.close()
