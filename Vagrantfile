# -*- mode: ruby -*-
# vi: set ft=ruby :


#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.


require 'yaml'


# Read settings from the configuration file.
# A non-default configuration file can be specified via CONFIG env variable.
# Each setting can be overridden with an environment variable.

box_config = YAML.load_file(ENV['config'] || 'config.yaml')

# generic
BOX           = ENV['BOX']           || box_config['box']           || 'ubuntu/focal64'
PROVIDER      = ENV['PROVIDER']      || box_config['virtualbox']    || 'virtualbox'
# VM options
# NOTE: Depending on the provider of choice, some options may be ignored
VM_NAME     = ENV['VM_NAME']     || box_config['vm']['name']         || 'MindsDB'
VM_DESC     = ENV['VM_DESC']     || box_config['vm']['description']  || 'MindsDB In-Database Marchine Learning'
VM_HOTPLUG  = ENV['VM_HOTPLUG']  || box_config['vm']['hotplug']      || 'on'
VM_CPU      = ENV['VM_CPU']      || box_config['vm']['cpu']          || '2'
VM_RAM      = ENV['VM_RAM']      || box_config['vm']['ram']          || 1024 * 4
# expose/map ports
PORT_MYSQL    = ENV['PORT_MYSQL']    || box_config['ports']['mysql']    || nil
PORT_HTTP     = ENV['PORT_HTTP']     || box_config['ports']['http']     || nil
PORT_MONGODB  = ENV['PORT_MONGODB']  || box_config['ports']['mongodb']  || nil
# private network
PNET_ENABLE   = ENV['PNET_ENABLE']   || box_config['private_network']['enable']  || 'NO'
PNET_NAME     = ENV['PNET_NAME']     || box_config['private_network']['name']    || ''
PNET_IP       = ENV['PNET_IP']       || box_config['private_network']['ip']      || ''
# MindsDB settings
MINDSDB_VERSION     = ENV['MINDSDB_VERSION'] || box_config['mindsdb']['version'] || ''
MINDSDB_APIS        = ENV['MINDSDB_APIS']    || box_config['mindsdb']['apis']    || 'http,mysql,mongodb'
# guest system settings
SKIP_PYTHON_ALIAS  = ENV['SKIP_PYTHON_ALIAS'] || box_config['guest_system']['skip_python_alias'] || '1'
SYS_PIP_VERSION    = ENV['SYS_PIP_VERSION']   || box_config['guest_system']['pip_version']       || ''
SYS_ON_LOGIN       = ENV['SYS_ON_LOGIN']      || box_config['guest_system']['on_login']          || ''
SYS_SWAPPINESS     = ENV['SYS_SWAPPINESS'] || box_config['guest_system']['swappiness'] || '1'

# features and components
INCLUDE_CLIENT_MARIADB = ENV['INCLUDE_CLIENT_MARIADB'] || box_config['include']['clients']['mariadb'] || '1'
INCLUDE_CLIENT_MYCLI   = ENV['INCLUDE_CLIENT_MYCLI']   || box_config['include']['clients']['mycli']   || '1'


Vagrant.require_version '>= 2.2.16'

Vagrant.configure('2') do |config|
    config.vm.box = BOX

    config.vm.box_check_update = false

    # Syncer Folders
    if box_config['synced_folders'].kind_of?(Array)
        box_config['synced_folders'].each { |current_folder|
            config.vm.synced_folder current_folder['host'], current_folder['guest']
        }
    end

    if PNET_ENABLE.downcase == 'yes'
        if PNET_IP == ''
            config.vm.network 'private_network', type: 'dhcp'
        else
            config.vm.network 'private_network', ip: PNET_IP
        end
    end
    
    config.vm.network 'forwarded_port', guest: 47334, host: 47334
    config.vm.network 'forwarded_port', guest: 47335, host: 47335
    config.vm.network 'forwarded_port', guest: 47336, host: 47336
    # Ports exposed to the host
#    if (MINDSDB_APIS.include? 'mysql') and PORT_MYSQL.to_i > 0
#        config.vm.network 'forwarded_port', guest: 47335, host: PORT_MYSQL
#    end
#    if (MINDSDB_APIS.include? 'http') and PORT_HTTP.to_i > 0
#        config.vm.network 'forwarded_port', guest: 47334, host: PORT_HTTP
#    end
#    if (MINDSDB_APIS.include? 'mongodb') and PORT_MONGODB.to_i > 0
#        config.vm.network 'forwarded_port', guest: 47336, host: PORT_MONGODB
#    end


    if PROVIDER.downcase == 'virtualbox'
        config.vm.provider 'virtualbox' do |vb|
            vb.gui = false
            # this should avoid conflicts between VirtualBox and
            # MacOS audio
            vb.customize ["modifyvm", :id, '--audio',       'none']
            vb.customize ['modifyvm', :id, '--clipboard',   'bidirectional']
            vb.customize ['modifyvm', :id, '--name',        VM_NAME]
            vb.customize ['modifyvm', :id, '--description', VM_DESC]
            vb.customize ['modifyvm', :id, '--memory',      VM_RAM]
            vb.customize ['modifyvm', :id, '--cpuhotplug',  VM_HOTPLUG]
            vb.customize ['modifyvm', :id, '--cpus',        VM_CPU]
        end
    else
        puts 'ERROR: Unsupported provider: ' + PROVIDER
        puts 'ABORT'
        exit 1
    end


    # write some information in the info directory, so that it will
    # be easily available form the VM
    info_file = File.new('generated/box', 'w')
    info_file.puts(BOX)

    # Create a the FEATURES file.
    # Every time we add an optional feature we'll write a line into it,
    # as an uppercase id in snake case
    info_file = File.new('generated/FEATURES', 'w')

    config.vm.provision :shell,
        path: 'bootstrap.sh',
        env: {
            'MINDSDB_VERSION'         => MINDSDB_VERSION,
            'MINDSDB_APIS'            => MINDSDB_APIS,
            'SKIP_PYTHON_ALIAS'       => SKIP_PYTHON_ALIAS,
            'SYS_PIP_VERSION'         => SYS_PIP_VERSION,
            'SYS_SWAPPINESS'          => SYS_SWAPPINESS,
            'INCLUDE_CLIENT_MARIADB'  => INCLUDE_CLIENT_MARIADB,
            'INCLUDE_CLIENT_MYCLI'    => INCLUDE_CLIENT_MYCLI,
            'SYS_ON_LOGIN'            => SYS_ON_LOGIN
        }

    # end of the FEATURES file
    info_file.close
end
