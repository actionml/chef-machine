default['machine']['node_class'] = ''
default['machine']['node_tags'] = []
default['machine']['network_number'] = 0

## ----- Docker Engine attributes -----
#

default['machine']['engine']['data_dir'] = '/var/lib/docker'
default['machine']['engine']['port'] = 2375
default['machine']['engine']['labels'] = []

# listens list is computed socket + bind_address (if set) by default
default['machine']['engine']['listens'] = ['unix:///var/run/docker.sock']
default['machine']['engine']['bind_address'] = '0.0.0.0'

## Locate docker socket file from the attributes
socket = node['machine']['engine']['listens'].select do |l|
  l.start_with?('unix://')
end.first || ''

socket = socket.partition('unix://').last
socket = socket.empty? ? '/var/run/docker.sock' : socket

# Docker pass through volumes (if docker passthrough is set)
default['machine']['docker_volumes'] = %W[
  /usr/bin/docker:/usr/bin/docker
  #{socket}:/var/run/docker.sock
]
