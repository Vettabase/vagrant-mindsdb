# vagrant-immudb

Vagrantfile for a box containing MindsDB server and MariaDB client.


## Configuration

When creating the Vagrant machine, it is possible to configure the resulting box
by editing the configuration file. To avoid setting a property in the
configuration file, just leave it blank. Don't delete any key from the file.

The default configuration file is `config.yaml`. It is possible to use a different
file by setting the `CONFIG` configuration variable.

Each setting in the configuration file can be overridden with an environment
variable.

Settings that are not set in the configuration file nor using environment
variables will use the default values hardcoded in the Vagrantfile.

Environment variables can be passed in this way:

```
VAR1=VALUE1 VAR2=VALUE2 vagrant up
```


### Generic settings

These are the generic settings.

| Config File       | Environment       | Default              | Description |
| ----------------- | ----------------- | -------------------- | ----------- |
| `box`             | `BOX`             | `'ubuntu/bionic64'`  | The name of the base box (the VM operating system).
| `provider`        | `PROVIDER`        | `'virtualbox'`       | The Vagrant provider to use, case-insensitive.

Currently, the only tested basebox is Ubuntu Focal 64 bits. We could add more
systems. More importantly, you may want to use a database Vagrant box as a base,
so the MindsDB and the data source will be located on the same VM.

Also, currently the only supported provider is VirtualBox.

If you need to user another base boxes or another provider, don't hesitate to open
a feature request.

### Provider options

Some settings are passed to the providers that support them, to determine the
characteristics of the guest system.

* YAML dictionary: `vm`
* Variables prefix: `VM_`

| Config File  | Environment  | Default        | Description |
| ------------ | ------------ | -------------- | ----------- |
| `vm.name`    | `VM_NAME`    | `''`           | Name of the VM, used by the provider.
| `vm.description` | `VM_DESC` | `''`          | Human-readable description of the VM, used by the provider.
| `vm.hotplug` | `VM_HOTPLUG` | `'on'`         | Wether hotplug should be ON or OFF for the VM.
| `vm.cpu`     | `VM_CPU`     | `2`            | Number of vCPU's in the VM.
| `vm.ram`     | `VM_RAM`     | `4096` (4G)    | Amount of RAM in M.

Use these options to give more resources to the VM if needed,
or to give it less resources if your host system is struggling.

### MindsDB

These settings affect the configuration of MindsDB itself.

* YAML dictionary: `mindsdb.`
* Variables prefix: `MINDSDB_`

| Config File          | Environment         | Default      | Description |
| -------------------- | ------------------- | ------------ | ----------- |
| `mindsdb.version`    | `MINDSDB_VERSION`   | `''`        | Install this Python version, rather than
the latest. Note that it must be Python 3.

### Private networking

To add the guest system to a private network (if the provider supports this),
use these settings.

* YAML dictionary: `private_network.`
* Variables prefix: `PNET_`

| Config File | Environment | Default | Description |
| ----------- | ----------- | ------- | ----------- |
| `private_network.enable` | `PNET_ENABLE` | `'NO'` | Set to 'YES' (case insensitive) to enable private networking.
| `private_network.name`   | `PNET_NAME`   | `''`   | Useful if you use multiple private networks.
| `private_network.ip`     | `PNET_IP`     | `''`   | Specify an IP (version 4 or 6), or leave blank to automatically assign one via DHCP.

This feature is useful to let MindsDB get data from other Vagrant machines.

### Exposing ports to the host

You can expose some ports to the host system using these settings.

* YAML dictionary: `ports.`
* Variables prefix: `PORT_`

| Config File     | Environment    | Default value  | Default port | Description |
| --------------- | -------------- | -------------- | ------------ | ----------- |
| `ports.immudb`  | `PORT_IMMUDB`  | `''`           | 3322         | immudb connections.
| `ports.metrics` | `PORT_METRICS` | `''`           | 9497         | Prometheus exporter.
| `ports.web`     | `PORT_WEB`     | `''`           | 8080         | Web console.
| `ports.immugw`  | `PORT_IMMUGW`  | `''`           | 3323 or IMMUGW_PORT | immugw.

By default, no port is exposed. To expose a port, set the corresponding variable
to `DEFAULT` (to use the default port number) or to a port number (to map it to
a different host system port). The guest system will always use the default ports.

This feature is useful to use any MySQL-compatible client installed on your host system,
and work with a MindsDB Vagrant machine.

### Synced Folders

To setup synced folders, set the `synced_folders` property in the configuration file.
Currently, no environment variable can overwrite it.

`synced_folders` is an array. Here's an example of how to populate it:

```
synced_folders:
  - { host: '.', guest: '/Vagrant' }
```

By default, no synced folder is created. Use this feature to easily share configuration
files with a MindsDB Vagrant machine.

### Guest system

These settings affect the configuration of the guest system.

* YAML dictionary: `guest_system`
* Variables prefix: `SYS_`

| Config File                       | Environment          | Default  | Description |
| --------------------------------- | -------------------- | -------- | ----------- |
| `guest_system.skip_python_alias`  | `SKIP_PYTHON_ALIAS`  | `''`     | Set to any value to use `python` as an alias for `python3`.
| `guest_system.pip_version`        | `SYS_PIP_VERSION`    | `''`     | Install this Pip version, rather than the latest.
| `guest_system.swappiness`         | `SYS_SWAPPINESS`     | `1`      | Linux swappiness level. Swappiness can save a process from being killes when it requires too much memory, but it can also severly damage a database server performance. MindsDB is not expected to be an exception.


## Usage

To start using MindsDB, start the Vagrant machine with `vagrant up` and connect to it
with `vagrant ssh`. Once you're in, just type `mysql` to connect MindsDB.

To connect MindsDB to the data sources, you should make those resources reachable for
MindsDB. With our Vagrantfile, you can use one of the following methods:

* Use another basebox. For example, to let MindsDB connect MariaDB, use a MariaDB Vagrant box
  as a basebox.
* Connect to another Vagrant machine using a Vagrant private network. With this method
  you can connect to any type of virtual machine, container, or remote server, provided
  that a Vagrant provider exists and support private networking.

### Using a non-default basebox

TO-DO

### Using private networking

TO-DO

## Packaging

To create a box from this Vagrantfile:
* Create a VM as documented above, using the desired provider.
* Run `vagrant package --output <filename>`.


## Copyright and Contacts

This repository is distributed under the terms of the GNU AGPL, version 3. Copyright: Vettabase Ltd.

To contact us:

- info@vettabase.com
- https://vettabase.com

MindsDB is open source software:
https://mindsdb.com/
