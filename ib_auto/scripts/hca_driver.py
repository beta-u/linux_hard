#!/usr/bin/python

'''Confirm the latest driver version

Usage:
	version <system> <release>

Options:
	-h,--help Show this message

Example:
	version rhel 6.6 
'''
from docopt import docopt

def cli():
	try:
		argument = docopt(__doc__)
		system = argument['<system>']
		release = argument['<release>']
		print driver[system][release]
	except KeyError:
		print 'The driver of -->  '+system+release+'  <-- doesn\'t exist! \nContact administrator to add!'

driver = {
	
		'rhel':	{
				'6.6'	:	'MLNX_OFED_LINUX-3.4-1.0.0.0-rhel6.6-x86-64.tgz',
				'6.7'	:	'MLNX_OFED_LINUX-3.4-2.0.0.0-rhel6.7-x86_64.tgz',
				'7.2'	:	'MLNX_OFED_LINUX-4.0-1.0.1.0-rhel7.2-x86_64.tgz',
				'7.3'	:	'MLNX_OFED_LINUX-4.0-1.0.1.0-rhel7.3-x86_64.tgz',
				},
				
		'suse':	{
				'11.2'	:	'driver5',
				'11.3'	:	'driver6',
				'11.2'	:	'driver7',
				}	
	}

	
if __name__ == '__main__':
	cli()


