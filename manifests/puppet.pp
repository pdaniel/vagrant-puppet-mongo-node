class apt_update {
    exec { "aptGetUpdate":
        command => "sudo apt-get update",
        path => ["/bin", "/usr/bin"]
    }
}

class extra_opts{
	exec {"addExtraTools":
		command=>"npm install -g yo",
		path=>["/bin","/usr/bin"]
	}
}

class othertools {
    package { "git":
        ensure => latest,
        require => Exec["aptGetUpdate"]
    }

    package { "vim-common":
        ensure => latest,
        require => Exec["aptGetUpdate"]
    }

    package { "curl":
        ensure => present,
        require => Exec["aptGetUpdate"]
    }

    package { "htop":
        ensure => present,
        require => Exec["aptGetUpdate"]
    }
}

class node_js {
  include apt
  apt::ppa {
    'ppa:chris-lea/node.js': notify => Package["nodejs"]
  }

  package { "nodejs" :
      ensure => latest,
      require => [Exec["aptGetUpdate"],Class["apt"]]
  }

  exec { "npm-update" :
      cwd => "/vagrant",
      command => "npm -g update",
      onlyif => ["test -d /vagrant/node_modules"],
      path => ["/bin", "/usr/bin"],
      require => Package['nodejs']
  }
}

class mongodb {
  exec { "10genKeys":
    command => "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10",
    path => ["/bin", "/usr/bin"],
    notify => Exec["aptGetUpdate"],
    unless => "apt-key list | grep 10gen"
  }

  file { "10gen.list":
    path => "/etc/apt/sources.list.d/10gen.list",
    ensure => file,
    content => "deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen",
    notify => Exec["10genKeys"]
  }

  package { "mongodb-10gen":
    ensure => present,
    require => [Exec["aptGetUpdate"],File["10gen.list"]]
  }
}

class mysql{
	exec {"addMysql":
		command=>"sudo apt-get install mysql-server -y",
		path => ["/bin", "/usr/bin"],
		notify => Exec["aptGetUpdate"],
		unless=>"ls -l | grep mysql"
	}
}

include apt_update
include othertools
include node_js
include mongodb
include extra_opts
