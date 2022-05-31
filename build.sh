VERSION_MINDSDB=$( cat VERSION-mindsdb )
VERSION_VAGRANTFILE=$( cat VERSION-vagrantfile )

vagrant destroy --force
vagrant up
vagrant package --output boxes/mindsdb-$VERSION_MINDSDB-$VERSION_VAGRANTFILE.box
