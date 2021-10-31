from sys import argv
import numpy as np

if __name__ == '__main__':
	input_file = argv[1]
	_id = input_file.split('/')[-1]
	output_file = '/'.join(input_file.split('/')[:-2]) + '/avghopcount/avg' + _id
	with open(input_file, 'r') as input_f, open(output_file, 'w_') as output_f:
		numbers = [float(i) for i in input_f.read().split('\n') if i.strip()]
		output_f.write('%f' % np.average(numbers))