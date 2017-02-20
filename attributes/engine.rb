# Chef machine Docker Engine configuration
#

default['machine']['engine']['data_dir'] = '/var/lib/docker'
default['machine']['engine']['port'] = 2375
default['machine']['engine']['labels'] = []

# listens list is computed socket + bind_address (if set) by default
default['machine']['engine']['listens'] = ['unix:///var/run/docker.sock']
default['machine']['engine']['bind_address'] = '0.0.0.0'
