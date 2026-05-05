#!/bin/bash
set -e

# Wait for MariaDB to be ready
echo "Waiting for MariaDB..."
until mysqladmin ping -h"mariadb" -u"root" -p"admin" --silent; do
    sleep 1
done
echo "MariaDB is ready!"

if [ ! -d "/home/frappe/frappe-bench/apps/frappe" ]; then
    echo "Initializing Frappe Bench..."
    bench init --skip-redis-config-generation --skip-assets frappe-bench
fi

cd /home/frappe/frappe-bench

# Set up hosts
bench set-mariadb-host mariadb
bench set-redis-cache-host redis://redis-cache:6379
bench set-redis-queue-host redis://redis-queue:6379
bench set-redis-socketio-host redis://redis-socketio:6379

# Remove redis, watch from Procfile
sed -i '/redis/d' ./Procfile
sed -i '/watch/d' ./Procfile

# Install ERPNext
if [ ! -d "apps/erpnext" ]; then
    echo "Getting ERPNext..."
    bench get-app --skip-assets erpnext
fi

# Install HRMS
if [ ! -d "apps/hrms" ]; then
    echo "Installing HRMS..."
    # We will try to link it first, if fails we copy
    ln -s /workspace apps/hrms || cp -r /workspace apps/hrms
    bench setup app hrms || true
fi

# Create site if it doesn't exist
if [ ! -f "sites/hrms.localhost/site_config.json" ]; then
    echo "Creating new site hrms.localhost..."
    rm -rf sites/hrms.localhost
    bench new-site hrms.localhost \
        --force \
        --mariadb-root-password admin \
        --admin-password admin \
        --no-mariadb-socket
    
    bench --site hrms.localhost install-app erpnext
    bench --site hrms.localhost install-app hrms
    bench --site hrms.localhost set-config developer_mode 1
fi

echo "Starting Bench..."
bench start