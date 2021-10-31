#!/usr/bin/python
from os import walk, path
from sys import argv

if __name__ == '__main__':
	for root, folders, files in walk('.'):
		for f in files:
			address = path.join(root, f)
			if argv[1] in open(address, 'r').read():
				print address
				