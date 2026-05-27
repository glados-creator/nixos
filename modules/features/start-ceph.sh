fuck me 
proper tuto
https://blog.stephane-robert.info/docs/services/stockage/ceph/
THERE IS A DASHBOARD

THIS WORKS
CREATE MONITOR

# 1. Use the FSID from your actual ceph.conf
FSID=$(grep ^fsid /etc/ceph/ceph.conf | cut -d= -f2 | tr -d ' ')
# or just copy the value: 25c7a498-9c9e-4572-bb73-12425e93ada1

# 2. Define IPs (adjust to your actual network)
ASTRA_IP="192.168.1.12"
JUPITER_IP="192.168.1.16"
STITAN_IP="192.168.1.22"

# Stop and remove the monitor data
systemctl stop ceph-mon-astra.service
rm -rf /var/lib/ceph/mon/ceph-astra

# Create a new keyring that contains both mon. and client.admin keys
ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring

# Create the monitor with this combined keyring
ceph-mon --mkfs -i astra --fsid "$FSID" --keyring /tmp/ceph.mon.keyring

# Fix ownership
chown -R ceph:ceph /var/lib/ceph/mon/ceph-astra /etc/ceph

# Restart
systemctl start ceph-mon-astra.service

# Test
ceph -s

ceph config set mon auth_allow_insecure_global_id_reclaim false
systemctl restart ceph-mon-astra.service

CREATE MANAGER 


# Create a keyring for the manager
ceph auth get-or-create mgr.astra mon 'allow profile mgr' osd 'allow *' mds 'allow *' -o /etc/ceph/ceph.mgr.astra.keyring

# Create systemd service for NixOS (if not auto-generated)
# On NixOS, you might need to define the service in configuration.nix.
# For manual start:
ceph-mgr -i astra --keyring /etc/ceph/ceph.mgr.astra.keyring

systemctl daemon-reload
systemctl enable --now ceph-mgr-astra.service
systemctl restart ceph*.target

# file fix
mkdir -p /var/lib/ceph/mgr/ceph-astra
ceph auth get-or-create mgr.astra mon 'allow profile mgr' osd 'allow *' mds 'allow *' -o /var/lib/ceph/mgr/ceph-astra/keyring
chown -R ceph:ceph /var/lib/ceph/mgr/ceph-astra
chmod 600 /var/lib/ceph/mgr/ceph-astra/keyring

ADD OSD

mkdir -p /var/lib/ceph/bootstrap-osd
chown ceph:ceph /var/lib/ceph/bootstrap-osd

# 2. Generate or retrieve the bootstrap-osd keyring (get-or-create will create if missing)
ceph auth get-or-create client.bootstrap-osd mon 'allow profile bootstrap-osd' -o /var/lib/ceph/bootstrap-osd/ceph.keyring

# Create OSD (zap first if needed)
ceph-volume lvm zap /dev/sdb --destroy
ceph-volume lvm create --data /dev/sdb

ceph-volume lvm activate --all --no-systemd

CREATE MDS
# Create keyring for mds.astra
ceph auth get-or-create mds.astra mon 'allow profile mds' osd 'allow *' mds 'allow *' -o /etc/ceph/ceph.mds.astra.keyring

# Create MDS data directory
mkdir -p /var/lib/ceph/mds/ceph-astra
chown ceph:ceph /var/lib/ceph/mds/ceph-astra
ceph-mds -i astra --keyring /etc/ceph/ceph.mds.astra.keyring

Create CephFS filesystem
# Create two pools (metadata and data)
ceph osd pool create cephfs_metadata 32 32
ceph osd pool create cephfs_data 64 64

# Create the filesystem
ceph fs new cephfs cephfs_metadata cephfs_data

# Verify
ceph fs ls
ceph mds stat

Mount CephFS (on client)
# Kernel driver
mount -t ceph 192.168.1.12:6789:/ /mnt/cephfs -o name=admin,secretfile=/etc/ceph/ceph.client.admin.keyring

# Or FUSE
ceph-fuse /mnt/cephfs




=============
OLD


On astra (the first monitor)

# 1. Use the FSID from your actual ceph.conf
FSID=$(grep ^fsid /etc/ceph/ceph.conf | cut -d= -f2 | tr -d ' ')
# or just copy the value: 25c7a498-9c9e-4572-bb73-12425e93ada1

# 2. Define IPs (adjust to your actual network)
ASTRA_IP="192.168.1.12"
JUPITER_IP="192.168.1.16"
STITAN_IP="192.168.1.22"

# 3. Create monitor map with IPs
monmaptool --create --add astra $ASTRA_IP --add jupiter $JUPITER_IP --add stitan $STITAN_IP --fsid $FSID /tmp/monmap

# 2. Create the monitor keyring
ceph-authtool --create-keyring /etc/ceph/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'

# 3. Create the monitor directory and mkfs
mkdir -p /var/lib/ceph/mon/ceph-astra
ceph-mon --mkfs -i astra --fsid "$FSID" --keyring /etc/ceph/ceph.mon.keyring

# 4. Create the admin keyring
ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *'

# 5. Add admin key to monitor’s keyring
ceph-authtool /var/lib/ceph/mon/ceph-astra/keyring --import-keyring /etc/ceph/ceph.client.admin.keyring

# 6. Fix ownership
chown -R ceph:ceph /var/lib/ceph/mon /etc/ceph

# 7. Start the monitor
systemctl start ceph-mon-astra.service
systemctl enable ceph-mon-astra.service

On jupiter (second monitor)

scp /etc/ceph/ceph.client.admin.keyring glados@jupiter:/home/glados/
scp /etc/ceph/ceph.mon.keyring glados@jupiter:/home/glados/

mv /home/glados/ceph.client.admin.keyring /etc/ceph/

# 1. Get the monitor map from the existing cluster
ceph mon getmap -o /tmp/monmap

# 2. Create the monitor directory and mkfs using the map
mkdir -p /var/lib/ceph/mon/ceph-jupiter
ceph-mon --mkfs -i jupiter --monmap /tmp/monmap

# 3. Copy the admin keyring (optional but convenient)
cp /etc/ceph/ceph.client.admin.keyring /etc/ceph/

# 4. Fix ownership
chown -R ceph:ceph /var/lib/ceph/mon /etc/ceph

# 5. Start the monitor
systemctl start ceph-mon-jupiter.service
systemctl enable ceph-mon-jupiter.service

# Add each OSD. The --data flag points to your pre-formatted partition.
sudo ceph-volume lvm prepare --bluestore --data /dev/sda1
sudo ceph-volume lvm prepare --bluestore --data /dev/sdb1
sudo ceph-volume lvm prepare --bluestore --data /dev/sdc1

# Activate all prepared OSDs
sudo ceph-volume lvm activate --all

