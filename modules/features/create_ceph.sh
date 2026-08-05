# Set your node's IP and the global FSID (run this on each node)
export IP=<this_node_ip_address>
export FSID=<your-global-fsid>

# Create necessary directories
sudo -u ceph mkdir -p /etc/ceph
sudo -u ceph mkdir -p /var/lib/ceph/bootstrap-osd
sudo -u ceph mkdir -p /tmp/monmap
sudo -u ceph mkdir -p /var/lib/ceph/mon/ceph-$(hostname)

# Generate the admin keyring
sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'

# Generate the bootstrap-osd keyring
sudo ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'

# Combine them into the monitor keyring
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring
sudo chown ceph:ceph /tmp/ceph.mon.keyring


### INIT

# Run these commands ONLY on stivan
export IP=<stivan_ip_address>
export FSID=<your-global-fsid>

# Create the initial monitor map
sudo monmaptool --create --add stivan $IP --fsid $FSID /tmp/monmap

# Format the monitor storage with the map and keys
sudo -u ceph ceph-mon --mkfs -i mon-$(hostname) --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring


### ALTERNATIVE

curl --silent --remote-name --location https://github.com/ceph/ceph/raw/quincy/src/cephadm/cephadm
chmod +x cephadm
./cephadm add-repo --release quincy
./cephadm install

sudo ./cephadm bootstrap --mon-ip <stivan_IP>