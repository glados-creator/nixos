# Set your node's IP and the global FSID (run this on each node)
export IP=<this_node_ip_address>
export FSID=<your-global-fsid>

# Create necessary directories
sudo -u ceph mkdir -p /etc/ceph
sudo -u ceph mkdir -p /var/lib/ceph/bootstrap-osd
sudo -u ceph mkdir -p /var/lib/ceph/mon/ceph-$(hostname)

# Generate the admin keyring
sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'

# Generate the bootstrap-osd keyring
sudo ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'

# Combine them into the monitor keyring
# Create the mon keyring file and import the admin keyring in one step:
sudo ceph-authtool -C /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring

# Now import the bootstrap-osd keyring (file already exists, so no -C needed):
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring
sudo chown ceph:ceph /tmp/ceph.mon.keyring


### INIT

# Run these commands ONLY on stivan
export IP=<stivan_ip_address>
export FSID=<your-global-fsid>

# Create the initial monitor map
sudo monmaptool --create --add stitan $IP --fsid $FSID /tmp/monmap

# Format the monitor storage with the map and keys
sudo -u ceph ceph-mon --mkfs -i mon-$(hostname) --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

sudo cp /tmp/ceph.mon.keyring /var/lib/ceph/mon/ceph-stitan/keyring
sudo chown ceph:ceph /var/lib/ceph/mon/ceph-stitan/keyring

# Start the monitor
sudo -u ceph ceph-mon -i $(hostname) --public-addr $IP

# MGR

sudo -u ceph mkdir -p /var/lib/ceph/mgr/ceph-$(hostname)
sudo cp /etc/ceph/ceph.client.admin.keyring /var/lib/ceph/mgr/ceph-$(hostname)/keyring
# Create a key for mgr.stitan
sudo ceph auth get-or-create mgr.$(hostname) mon 'allow profile mgr' osd 'allow *' mds 'allow *' -o /var/lib/ceph/mgr/ceph-$(hostname)/keyring
sudo chown -R ceph:ceph /var/lib/ceph/mgr/ceph-$(hostname)

# Start the MGR daemon (run in background or use screen/tmux)
sudo -u ceph ceph-mgr -i $(hostname)


# ADD OSD
sudo ceph-volume lvm prepare --data /dev/sdb
sudo ceph-volume lvm activate --all


### ALTERNATIVE

ceph mgr module ls
# Enable each module
sudo ceph mgr module enable cephadm
sudo ceph mgr module enable osd_perf_query
sudo ceph mgr module enable osd_support
sudo ceph mgr module enable prometheus
# sudo ceph mgr module enable rook # need kube-config ?
sudo ceph mgr module enable selftest
sudo ceph mgr module enable smb
sudo ceph mgr module enable stats

sudo cephadm bootstrap --mon-ip <stivan_IP>

sudo ceph mgr module enable dashboard
sudo ceph dashboard set-login-credentials admin -i (file with password)