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
          try_files $uri $uri/ =404;
        }
      }
      include /home/${paas_username}/.piku/nginx/*.conf;
  - path: /etc/incron.d/paas
    permissions: 0644
    content: |
      /home/${paas_username}/.piku/nginx IN_MODIFY,IN_NO_LOOP /bin/systemctl reload nginx
  - path: /tmp/pubkey
    permissions: 0644
    content: |
      ${ssh_key}


packages:
  - audispd-plugins
  - auditd
  - curl
  - docker-compose
  - docker.io # NOTE: The Docker official repository does not ship 18.04/bionic packages at this time
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
  - uwsgi # TODO: sort out when .ini file needs to be created
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
  - update-locale LANG=en_US.UTF-8
  # Get our mini-PaaS
  - adduser --disabled-password --gecos 'PaaS' --ingroup www-data ${paas_username}
  - su - ${paas_username} -c "wget https://raw.githubusercontent.com/rcarmo/piku/master/piku.py && python3 ~/piku.py setup && python3 ~/piku.py setup:ssh /tmp/pubkey"
  # Make uWSGI aware of it
  - ln /home/${paas_username}/.piku/uwsgi/uwsgi.ini /etc/uwsgi/apps-enabled/piku.ini
  # Enable and start services
  - usermod -G docker ${admin_username}
  - usermod -G docker ${paas_username}
  - systemctl enable nginx
  - systemctl enable incron
  - systemctl enable uwsgi # this is mapped to SYS V scripts on 18.04
  - systemctl start nginx
  - systemctl start incron
  - systemctl start uwsgi

  # TODO: swap using waagent.conf
