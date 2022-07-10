# vagrant-immudb

Vagrantfile for a box containing MindsDB server and MariaDB client.

This Vagrantfile is used, with default values, to build the
`vettabase/mindsdb` Vagrant box:

https://app.vagrantup.com/vettabase/boxes/mindsdb


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
| `box`             | `BOX`             | `'ubuntu/focal64'`   | The name of the base box (the VM operating system).
| `provider`        | `PROVIDER`        | `'virtualbox'`       | The Vagrant provider to use, case-insensitive.

Currently, these baseboxes are supported:
- `ubuntu/jammy64`
- `ubuntu/focal64`
- `debian/bullseye64`

It is reasonable to expect that most boxes running an Ubuntu Focal system will just work.
We could add more systems. More importantly, you may want to use a database Vagrant box
as a base, so the MindsDB and the data source will be located on the same VM.

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
| `vm.cpu`     | `VM_CPU`     | `1`            | Number of vCPU's in the VM.
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
| `mindsdb.apis`       | `MINDSDB_APIS`      | `''`         | MindsDB APIs/protocols to expose. Supported
comma-separated values: `mysql`, `http`, `mongodb`. Leave empty to expose them all.

### Private networking

Private networking is a Vagrant feature that allows guest system to communicate
with each other. In our case this is useful to allow MindsDB to connect to databases
that run on other guest systems.

To add the guest system to a private network (if the provider supports this),
use these settings.

* YAML dictionary: `private_network.`
* Variables prefix: `PNET_`

| Config File | Environment | Default | Description |
| ----------- | ----------- | ------- | ----------- |
| `private_network.enable` | `PNET_ENABLE` | `'NO'` | Set to 'YES' (case insensitive) to enable private networking.
| `private_network.name`   | `PNET_NAME`   | `''`   | Useful if you use multiple private networks.
| `private_network.ip`     | `PNET_IP`     | `''`   | Specify an IP (version 4 or 6), or leave blank to automatically assign one via DHCP.

### Exposing ports to the host

Vagrant allows you to expose a guest system's ports to the host. In our case,
this allows any MariaDB or MySQL compatible client installed on the host system
to connect to MindsDB.

You can expose some ports to the host system using these settings.

* YAML dictionary: `ports.`
* Variables prefix: `PORT_`

| Config File     | Environment    | Default value  | Default port | Description |
| --------------- | -------------- | -------------- | ------------ | ----------- |
| `ports....`  | `PORT_...`  | `''`           | ...          | ...

By default, no port is exposed. To expose a port, set the corresponding variable
to `DEFAULT` (to use the default port number) or to a port number (to map it to
a different host system port). The guest system will always use the default ports.

### Synced folders

Synced folders are a Vagrant feature that allows a Vagrant machine to share a
directory with the host system. You can also allows to make a directory in
the host system accessible from multiple Vagrant machines.

In our case, synced folders allow you to use configuration files, SQL files, or
data files generated by other Vagrant machines or by the host system. Similarly,
the results of an MindsDB query can be written to a file and shared with other
systems.

To setup synced folders, set the `synced_folders` property in the configuration file.
Currently, no environment variable can overwrite it.

`synced_folders` is an array. Here's an example of how to populate it:

```
synced_folders:
  - { host: '.', guest: '/Vagrant' }
```

By default, a "/vagrant" folder is created that maps to the Vagrantfile directory.

### Guest system

These settings affect the configuration of the guest system.

* YAML dictionary: `guest_system`
* Variables prefix: `SYS_`

| Config File                       | Environment          | Default  | Description |
| --------------------------------- | -------------------- | -------- | ----------- |
| `guest_system.skip_python_alias`  | `SKIP_PYTHON_ALIAS`  | `''`     | Set to any value to use `python` as an alias for `python3`.
| `guest_system.pip_version`        | `SYS_PIP_VERSION`    | `''`     | Install this Pip version, rather than the latest. Untested. Don't change it unless you know what you are doing.
| `guest_system.on_login`           | `SYS_ON_LOGIN`       | `''`     | Command to run when `vagrant` user logs in. The intended use is running a MySQL client. Leave blank to skip such command. `AUTO` chooses automatically the client to launch: `mycli` or `mysql`, in order of preference.
| `guest_system.swappiness`         | `SYS_SWAPPINESS`     | `1`      | Linux swappiness level. Swappiness can save a process from being killes when it requires too much memory, but it can also severly damage a database server performance. MindsDB is not expected to be an exception.

### Features / components

Specific features or components can be added to, or removed from the guest system
by using these settings:

* YAML dictionary: `include.`
* Variables prefix: `INCLUDE_`

| Config File                | Environment               | Default  | Description |
| -------------------------- | ------------------------- | -------- | ----------- |
| `include.clients.mariadb`  | `INCLUDE_CLIENT_MARIADB`  | `1`      | Set exactly to `1` to include MariaDB client.
| `include.clients.mycli`    | `INCLUDE_CLIENT_MYCLI`    | `1`      | Set exactly to `1` to include mycli client.


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

### Specifying a custom basebox

A way to allow MindsDB to communicate with a target database is to
run them both on the same Vagrant machine.

To do so, you may instruct the Vagrantfile to use a basebox that runs
the target database. A new box, running MindsDB, will be built starting
from the specified basebox.

You can do this by passing the `BOX` environment variable:

```
BOX=another_box vagrant up
```

Or by changing the value of `box` in the `config.yaml` file.

See "Generic settings" to know which OSs are supported.

### Using private networking

Private networking allows Vagrant machines to communicate with
each other. This is usually the best way to enable communication
between two or more programs that we want to run inside Vagrant.

To use private networking, we must set `private_network.enable`
or `PNET_ENABLE` to `yes`. We can also specify a network name with
`private_network.name` or `PNET_NAME`. Remember that  Vagrant
machine can only communicate with machines in the same network.
Finally, we can optionally specify an IP address via
`private_network.ip` or `PNET_IP`. If we don't specify an IP,
one will be assigned by the Vagrant DHCP service, which is
usually the best choice.

Configuration file example:

```
private_network:
  enable: yes
  name: cyberspace
  ip:
```

Environment variables example:

```
PNET_ENABLE=yes PNET_NAME=cyberspace vagrant up
```

### Example: Build a MindsDB image to communicate with MariaDB

This is an example that shows how to apply the concepts explained
above to let MindsDB communicate with MariaDB and with MariaDB clients
running outside of its Vagrant machine.

Here's the situation:
* MariaDB runs in another VM, called cyberspace.
* We want to be able to connect to the MindsDB VM using a MariaDB GUI.

First of all, let's configure the access to the private network
as shown above:

```
private_network:
  enable: yes
  name: cyberspace
  ip:
```

The ports we may need to connect to are exposed by default. But
their numbers are not standard. If we want MindsDB MySQL interface
to listen on the 3306 port, we can do this:

```
ports:
  mysql: 3306
  http:
  mongodb:
```

Then just spin the machine:

```
vagrant up
```

It's as simple as that!

For various reasons, you may need to know the IPs of your MindsDB
and MariaDB machines. To get a machine's IP, move to their environment
(the path shown by `vagrant global-status`) and run:

```
vagrant ssh -c 'hostname -i'
```

## Packaging

To create a box from this Vagrantfile:
* Create a VM as documented above, using the desired provider.
* Run `vagrant package --output <filename>`.

If you're ok with default options, you can just use the official
Vagrant box from Vettabase:

```
https://app.vagrantup.com/vettabase/boxes/mindsdb
```


## To Do

Our To-Do is our GitHub Issues tab:

https://github.com/Vettabase/vagrant-mindsdb/issues


## Copyright and Contacts

This repository is distributed under the terms of the GNU AGPL, version 3. Copyright: Vettabase Ltd.

To contact us:

- info@vettabase.com
- https://vettabase.com

MindsDB is open source software:
https://mindsdb.com/
