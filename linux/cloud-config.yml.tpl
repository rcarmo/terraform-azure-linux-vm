#cloud-config

write_files:
  # Basic configuration
  - path: /etc/ssh/sshd_config
    permissions: 0644
    # strengthen SSH cyphers
    content: |
      Port ${ssh_port}
      Protocol 2
      HostKey /etc/ssh/ssh_host_ed25519_key
      KexAlgorithms curve25519-sha256@libssh.org
      Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
      MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com
      UsePrivilegeSeparation yes
      KeyRegenerationInterval 3600
      ServerKeyBits 1024
      SyslogFacility AUTH
      LogLevel INFO
      LoginGraceTime 120
      PermitRootLogin prohibit-password
      StrictModes yes
      RSAAuthentication yes
      PubkeyAuthentication yes
      IgnoreRhosts yes
      RhostsRSAAuthentication no
      HostbasedAuthentication no
      PermitEmptyPasswords no
      ChallengeResponseAuthentication no
      PasswordAuthentication no
      X11Forwarding yes
      X11DisplayOffset 10
      PrintMotd no
      PrintLastLog yes
      TCPKeepAlive yes
      AcceptEnv LANG LC_*
      Subsystem sftp /usr/
      UsePAM yes
  - path: /etc/fail2ban/jail.d/override-ssh-port.conf
    permissions: 0644
    content: |
      [sshd]
      enabled = true
      port    = ${ssh_port}
      logpath = %(sshd_log)s
      backend = %(sshd_backend)s
  # Development Stack
  - path: /etc/nginx/sites-available/default
    permissions: 0644
    content: |
      server {
        listen 80 default_server;
        listen [::]:80 default_server;
        root /var/www/html;
        index index.html index.htm;
        server_name _;
        location / {
          # First attempt to serve request as file, then
          # as directory, then fall back to displaying a 404.
          try_files $uri $uri/ =404;
        }
      }
      include /home/${paas_username}/.piku/nginx/*.conf;
  - path: /etc/incron.d/paas
    permissions: 0644
    content: |
      /home/${paas_username}/.piku/nginx IN_MODIFY,IN_NO_LOOP /bin/systemctl reload nginx
  - path: /etc/systemd/system/uwsgi.service
    permissions: 8644
    content: |
      [Unit]
      Description=uWSGI Emperor
      After=syslog.target

      [Service]
      ExecStart=/usr/bin/uwsgi --ini /home/${paas_username}/.piku/uwsgi/uwsgi.ini
      User=${paas_username}
      Group=www-data
      RuntimeDirectory=uwsgi
      Restart=always
      KillSignal=SIGQUIT
      Type=notify
      StandardError=syslog
      NotifyAccess=all

      [Install]
      WantedBy=multi-user.target

# The Docker official repository does not ship 18.04/bionic packages at this time
#apt:
#  sources:
#    docker_ce.list:
#      source: "deb https://download.docker.com/linux/ubuntu $RELEASE stable"
#      keyserver: p80.pool.sks-keyservers.net
#      keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88

packages:
  - audispd-plugins
  - auditd
  - curl
  - docker-compose
  - docker.io
  - fail2ban
  - htop
  - language-pack-en-base
  - tmux
  - vim
  - wget
  # dev stack
  - build-essential
  - certbot
  - git
  - incron
  - libjpeg-dev
  - libxml2-dev
  - libxslt1-dev
  - nginx
  - python-certbot-nginx
  - python-dev
  - python-pip  
  - python-virtualenv 
  - python3-dev
  - python3-pip  
  - python3-virtualenv 
  - uwsgi 
  - uwsgi-plugin-asyncio-python3
  - uwsgi-plugin-gevent-python
  - uwsgi-plugin-python
  - uwsgi-plugin-python3
  - uwsgi-plugin-tornado-python
  - zlib1g-dev

package_update: true
package_upgrade: true
package_reboot_if_required: true

timezone: Europe/Lisbon

runcmd:
  - usermod -G docker ${admin_username}
  - systemctl enable docker
  - systemctl enable nginx
  - systemctl enable incron
  - systemctl enable uwsgi
  - apt-get update
  - DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
  - DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
  - reboot

  # TODO: swap using waagent.conf
