name             'machine'
maintainer       'ActionML'
maintainer_email 'devops@actionml.com'
license          'All rights reserved'
description      'Installs/Configures machine'
long_description 'Installs/Configures machine'
version          '0.1.4'

# depends 'consul_kv'
depends 'aml'
depends 'docker', '~> 2.15.2'
depends 'chef-sugar', '~> 3.4.0'
depends 'nomad', '~> 0.1.0'
depends 'consul'

## fixing dependencies for bad cookbooks
depends 'build-essential', '>= 8.0.0'
depends 'golang', '>= 1.7'
