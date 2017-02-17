
default['machine']['consul_options'] = {
  address: '127.0.0.1:8500',
  resolv_defaults: {
    nameservers: %W(8.8.4.4 8.8.8.8)
  }
  # start_join list is required so that agents can reach servers
}

default['machine']['nomad_options']['client'] = {
  node_class: 'client',
  network_speed: 1000,
  meta: {},
  # could be a list, but didn't seem to work so we are using raw exec.
  chroot_env: [],
  reserved: {
    memory: 512,
    cpu: 500,
    disk: 512,
    ports: '22,8500-8600,4646-4648'
  },
  options: {
    'driver.raw_exec.enable' => 1
  }
}
