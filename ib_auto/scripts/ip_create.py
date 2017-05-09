#!/usr/bin/python
'''Use to connect the head and end of ip address

Usage:
	ip_create <ip_head> <ip_end>

Options:
	-h,--help Show this message

Example:
	ip_create 192.168.1 10
'''
from docopt import docopt

def connect():
	argument = docopt(__doc__)
	ip_head = argument['<ip_head>']
	ip_end = argument['<ip_end>']
	ip_address = ip_head + '.' + ip_end
	print ip_address

if __name__ == '__main__':
	connect()
