include_attribute 'machine::engine'

## Specifies machine containers to bootstrap or ignore
#
default['machine']['bootstrap_containers'] = %w(
  consul
  swarm
  nomad
  registrator
)
default['machine']['ignore_containers'] = []

# Defaults (used as the base for merge)
default['machine']['container_default_options']['log_opts'] = %w(max-size=50m max-file=5)

## Volumes for passing docker binary and socket into
#
socket = node['machine']['engine']['listens'].select {|l| l.start_with?('unix://') }.first || ""
socket = socket.partition("unix://").last
default['machine']['docker_passthrough_volumes'] = %W(
  /var/run/docker.sock:/var/run/docker.sock
  #{socket}
)
