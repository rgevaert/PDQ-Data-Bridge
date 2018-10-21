class grafanaconfig {

  include ::grafana

  file { '/etc/grafana/provisioning/dashboards/dashboard.yaml':
    source  => '/vagrant/grafana/dashboard.yaml',
    require => Class['grafana'],
  }

}

class collectdstats {

  include ::collectd
  include ::collectd::plugin::csv
  include ::collectd::plugin::cpu
  include ::collectd::plugin::load
  include ::collectd::plugin::memory
  include ::collectd::plugin::disk
  include ::collectd::plugin::interface
  include ::collectd::plugin::uptime
  include ::collectd::plugin::swap
  include ::collectd::plugin::write_graphite
  include ::collectd::plugin::processes
  include ::collectd::plugin::irq
  include ::collectd::plugin::network

  collectd::plugin{'match_regex':;}

  class { '::collectd::plugin::aggregation':
    aggregators => {
      'cpu' => {
        plugin           => 'cpu',
        agg_type         => 'cpu',
        groupby          => ['Host', 'TypeInstance',],
        calculateaverage => true,
      },
    },
  }

  class { '::collectd::plugin::chain':
    chainname     => 'PostCache',
    defaulttarget => 'write',
    rules         => [
      {
        'match'   => {
          'type'    => 'regex',
          'matches' => {
            'Plugin'         => '^cpu$',
            'PluginInstance' => '^[0-9]+$',
          },
        },
        'targets' => [
          {
            'type'       => 'write',
            'attributes' => {
              'Plugin' => 'aggregation',
            },
          },
          {
            'type' => 'stop',
          },
        ],
      },
    ],
  }

}

class graphite {

  package {'graphite-carbon':
    ensure => 'latest',
  }

  package { 'graphite-web':
    ensure => 'latest',
  }

  exec { 'graphitedb':
    command => '/usr/bin/graphite-manage migrate --run-syncdb',
    user    => '_graphite',
    creates => '/var/lib/graphite/graphite.db',
    require => Package['graphite-web'],
  }

  include ::apache

  apache::vhost { $::fqdn:
    port                        => '80',
    docroot                     => '/usr/share/graphite-web',
    wsgi_daemon_process         => '_graphite',
    wsgi_daemon_process_options => {
      processes          => '5',
      threads            => '5',
      display-name       => '%{GROUP}',
      inactivity-timeout => 120,
      user               => '_graphite',
      group              => '_graphite',
    },
    wsgi_process_group          => '_graphite',
    wsgi_import_script          => '/usr/share/graphite-web/graphite.wsgi',
    wsgi_import_script_options  => {
      process-group     => '_graphite',
      application-group => '%{GLOBAL}',
    },
    wsgi_script_aliases         => { '/' => '/usr/share/graphite-web/graphite.wsgi' },
    aliases                     => [
      { alias => '/static/',
        path  => '/usr/share/graphite-web/static/',
      },
    ],
    directories                 => [
      { 'path'       => '/static/',
        'provider'   => 'location',
        'sethandler' => 'None',
      },
    ],
  }
}

node 'sut' {

  include ::collectdstats
  # Configure apache and relevant modules
  include ::apache
  include ::apache::mod::status
  include ::collectd::plugin::apache
}

node 'collector' {

  include ::apt
  include ::apt::backports
  include ::collectdstats
  include ::graphite
  include ::grafanaconfig

}
