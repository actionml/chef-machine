
# We use nomad cookbook to create nomad confiuration file
include_recipe 'nomad::config'

# Data path inside the stackfeed/nomad
node.default['nomad']['datadir'] = '/data'
node.default['nomad']['client_enabled'] = true
