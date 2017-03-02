
default['machine']['consul_options'] = {
  address: '127.0.0.1:8500',
  resolv_failsafe: {
    nameservers: %W(8.8.4.4 8.8.8.8)
  }
  # start_join list is required so that agents can reach servers
}
