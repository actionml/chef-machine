
# register a given bunch into consul
node['consul']['kv'].each do |path, value|
  consul_kv "consul-kv_#{path}" do
    path path
    value value
    consul_addr node['consul']['address']
  end
end
