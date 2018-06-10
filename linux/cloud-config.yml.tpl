#cloud-config

write_files:
  - path: /etc/ssh/sshd_config
    permissions: 0644
    # strenghten SSH cyphers
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

# The Docker official repository does not ship 18.04/bionic packages at this time
#apt:
#  sources:
#    docker_ce.list:
#      source: "deb https://download.docker.com/linux/ubuntu $RELEASE stable"
#      keyserver: p80.pool.sks-keyservers.net
#      keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88

packages:
  - docker.io
  - docker-compose
  - vim
  - curl
  - fail2ban
  - htop
  - wget
  - auditd
  - audispd-plugins

package_update: true
package_upgrade: true
package_reboot_if_required: true

timezone: Europe/Lisbon

runcmd:
  - usermod -G docker ${admin_username}
  - systemctl enable docker
  - systemctl start docker
  - apt-get update
  - DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
  - DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
  - reboot

  # TODO: swap using waagent.conf