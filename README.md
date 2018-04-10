# Machine cookbook

This cookbook is used to bootstrap core services on a machine during the cloudinit initialization. By the core services here we specifically mean **consul** and **swarm**.

## Configuration

| Attribute | Description | Default value |
|---|---|---|
| **machine.bootstrap_containers** | The list of containers to bootstrap. Note that bootstrap will happen in the specified order. | `%w[consul swarm]` |
| **machine.containers** | Specifies containers configuration. The key is the container name (will be used as image if image is not provided), the value contains different container options such as image, volumes, exposed_ports etc.  | see: [attributes/containers.rb](attributes/containers.rb) |
| **machine.node_class** | Specifies consul agent *node_mata.class* variable used to distinguish nodes. | `"node"` |
| **machine.node_tags** | A list of tags added to the dummy *node_meta* service. | `[]` |

## Consul agent identification

At the moment cookbook generates consul agent **node_meta** containing *class* and *instance_id* which are set to **machine.node_class** and *AWS instance_id*.  This metadata can be used to distinguish nodes when consul agent is running.
There's another way to distinguish nodes while consul agent is stopped is to query the service catalog (when *leave_on_terminate* is set false). Specifically we use a dummy service named **node_meta**. This service contains the following tags: *class:{{node_class}}* and *instance_id:{{AWS instance_id}}* together with the list of tags from the **machine.node_tags** attribute.

### machine.engine

| Attribute | Description | Default value |
|---|---|---|
| **data_dir** | Docker data directory. | `"/var/lib/docker"` |
| **port** | Specifies the port docker listens on.  | `2375` |
| **labels** | Specifies the list of labels of the docker engine. | `[]` |
| **listens** | Specifies a list of endpoints the docker engine actually listens on (`tcp://#{bind_address}:#{port}` is automatically added). | `['unix:///var/run/docker.sock']` |
| **bind_address** | Specifies the bind address of the docker engine. | `"0.0.0.0"` |

### machine.consul_options

These attributes define consul  `agent.json` configuration. See [attributes/options.rb](attributes/options.rb).


### machine.containers.CONTAINER.docker_passthrough

Set the value to `true` to passthrough docker binary and socket as volumes into a container.

## License and Authors

Author:: ActionML (<devops@actionml.com>)
