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
wipefs -a /dev/sdb
sudo ceph-volume lvm prepare --data /dev/sdb --no-systemd
sudo ceph-volume lvm activate --all
ceph osd tree

# DESTROY OSD
ceph osd purge 0 --yes-i-really-mean-it
ceph-volume lvm zap /dev/sdb --destroy

# DESTROY POOL
ceph osd pool rm <pool> --yes-i-really-mean-it

# DESTROY CEPHFS
ceph config set mon mon_allow_pool_delete true
ceph fs volume ls
ceph fs volume rm <cephfs> --yes-i-really-mean-it

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
ceph dashboard create-self-signed-cert
ceph dashboard ac-user-create <username> -i <file-containing-password> administrator

ceph config set mgr mgr/dashboard/server_addr $IP
ceph config set mgr mgr/dashboard/server_port $PORT

# CRUSH RULES AUTOBALANCER
ceph balancer on
ceph balancer mode upmap

# allow multiple cephfs ?
ceph fs flag set enable_multiple true --yes-i-really-mean-it

# maintenance

# pools 
ceph osd pool ls detail          # every pool: size, min_size, pg_num, crush_rule, autoscale mode, etc.
ceph osd lspools                 # just names + IDs
ceph osd pool autoscale-status   # what the autoscaler is doing/proposing per pool
# osd
ceph osd tree                    # what you've been using — weight = capacity in TiB
ceph osd df                      # per-OSD: weight, used%, actual usage, PG count — better for spotting imbalance
ceph osd df tree                 # same but grouped by host, easiest to eyeball
# crush 
ceph osd crush rule ls            # list rule names
ceph osd crush rule dump          # full detail (failure domain, device class filter, steps)
ceph osd crush rule dump replicated_rule   # just the default one
ceph osd crush tree               # bucket hierarchy (root → host → osd), similar to osd tree but pure CRUSH view

ceph osd pool autoscale-status

# CREATE MDS
mkdir -p /var/lib/ceph/mds/ceph-stitan
ceph auth get-or-create mds.stitan mon 'allow profile mds' mgr 'allow profile mds' mds 'allow *' osd 'allow *' \
  -o /var/lib/ceph/mds/ceph-stitan/keyring
chown -R ceph:ceph /var/lib/ceph/mds/ceph-stitan
chmod 600 /var/lib/ceph/mds/ceph-stitan/keyring

# CREATE cephfs

# bhole - general backups
ceph osd pool create bhole_meta
ceph osd pool create bhole_data
ceph osd pool set bhole_data bulk true
ceph fs new bhole bhole_meta bhole_data

# subvolumes
ceph fs subvolumegroup create <vol_name> <group_name> [--size <size_in_bytes>]
ceph fs subvolumegroup create bhole k8s-colosseum 
ceph fs subvolume create bhole vicus-default k8s-colosseum
ceph fs subvolume create bhole vicus-dmz k8s-colosseum
ceph fs subvolume create bhole vicus-private k8s-colosseum
ceph fs subvolume create bhole vicus-public k8s-colosseum

ceph fs subvolume create bhole lilnas

ceph fs subvolume ls bhole --group-name k8s-colosseum



fileSystems."/mnt/bhole" = {
  device = "192.168.1.14:6789:/";
  fsType = "ceph";
  options = [
    "name=bhole"
    "secretfile=/etc/ceph/bhole.secret"
    "fs=bhole"
    "_netdev"
    "noatime"
  ];
};

ceph auth get-or-create client.bhole mon 'allow rw fsname=bhole' mds 'allow rw fsname=bhole' osd 'allow rw tag cephfs data=bhole' mgr 'allow rw'

ceph auth print-key client.bhole > /etc/ceph/bhole.secret

mkdir -p /mnt/bhole
mount -t ceph 192.168.1.14:6789:/ /mnt/bhole -o name=bhole,secretfile=/etc/ceph/bhole.secret,fs=bhole