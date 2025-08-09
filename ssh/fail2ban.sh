#!/bin/bash

# Script para configuração robusta do Fail2ban
# Execute como root

# Verificar se está rodando como root
if [[ $EUID -ne 0 ]]; then
   echo "Execute como root"
   exit 1
fi

# Instalar fail2ban
apt update && apt install fail2ban iptables-persistent -y

# Backup das configurações existentes
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.backup.$(date +%Y%m%d)

# Criar configuração principal jail.local
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
# Configurações globais
bantime = 3600
findtime = 600
maxretry = 3
backend = systemd

# IPs que nunca serão banidos (adicione seus IPs administrativos)
ignoreip = 127.0.0.1/8 ::1
# ignoreip = 127.0.0.1/8 ::1 192.168.1.0/24 10.0.0.0/8

# Configurações de email (opcional)
# destemail = admin@seudominio.com
# sender = fail2ban@seudominio.com
# mta = sendmail

# Configurações de ban
banaction = iptables-multiport
banaction_allports = iptables-allports
protocol = tcp
chain = INPUT
port = 0:65535

# SSH - Proteção crítica
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200
findtime = 300

# SSH - Proteção adicional contra força bruta
[sshd-ddos]
enabled = true
port = ssh
filter = sshd-ddos
logpath = /var/log/auth.log
maxretry = 10
bantime = 1800
findtime = 120

# Apache/Nginx - Ataques HTTP
[apache-auth]
enabled = true
port = http,https
filter = apache-auth
logpath = /var/log/apache2/error.log
maxretry = 5
bantime = 3600

[apache-badbots]
enabled = true
port = http,https
filter = apache-badbots
logpath = /var/log/apache2/access.log
maxretry = 2
bantime = 7200

[apache-noscript]
enabled = true
port = http,https
filter = apache-noscript
logpath = /var/log/apache2/access.log
maxretry = 3
bantime = 3600

[apache-overflows]
enabled = true
port = http,https
filter = apache-overflows
logpath = /var/log/apache2/error.log
maxretry = 2
bantime = 7200

[apache-nohome]
enabled = true
port = http,https
filter = apache-nohome
logpath = /var/log/apache2/access.log
maxretry = 2
bantime = 3600

[apache-botsearch]
enabled = true
port = http,https
filter = apache-botsearch
logpath = /var/log/apache2/access.log
maxretry = 2
bantime = 7200

# Nginx equivalents
[nginx-http-auth]
enabled = true
port = http,https
filter = nginx-http-auth
logpath = /var/log/nginx/error.log
maxretry = 5
bantime = 3600

[nginx-noscript]
enabled = true
port = http,https
filter = nginx-noscript
logpath = /var/log/nginx/access.log
maxretry = 6
bantime = 3600

[nginx-badbots]
enabled = true
port = http,https
filter = nginx-badbots
logpath = /var/log/nginx/access.log
maxretry = 2
bantime = 7200

[nginx-noproxy]
enabled = true
port = http,https
filter = nginx-noproxy
logpath = /var/log/nginx/access.log
maxretry = 2
bantime = 7200

[nginx-limit-req]
enabled = true
port = http,https
filter = nginx-limit-req
logpath = /var/log/nginx/error.log
maxretry = 10
bantime = 600
findtime = 600

# FTP
[vsftpd]
enabled = true
port = ftp,ftp-data,ftps,ftps-data
filter = vsftpd
logpath = /var/log/vsftpd.log
maxretry = 3
bantime = 3600

# Email services
[postfix]
enabled = true
port = smtp,465,submission
filter = postfix
logpath = /var/log/mail.log
maxretry = 5
bantime = 3600

[dovecot]
enabled = true
port = pop3,pop3s,imap,imaps,submission,465,sieve
filter = dovecot
logpath = /var/log/mail.log
maxretry = 5
bantime = 3600

# MySQL/MariaDB
[mysqld-auth]
enabled = true
port = 3306
filter = mysqld-auth
logpath = /var/log/mysql/error.log
maxretry = 3
bantime = 7200

# MongoDB
[mongodb-auth]
enabled = true
port = 27017
filter = mongodb-auth
logpath = /var/log/mongodb/mongod.log
maxretry = 3
bantime = 7200

# Recidiva - Ban permanente para IPs recorrentes
[recidive]
enabled = true
filter = recidive
logpath = /var/log/fail2ban.log
banaction = iptables-allports
bantime = 86400
findtime = 86400
maxretry = 3
EOF

# Criar filtros customizados
mkdir -p /etc/fail2ban/filter.d

# Filtro para MongoDB
cat > /etc/fail2ban/filter.d/mongodb-auth.conf << 'EOF'
[Definition]
failregex = ^.*\[conn\d+\] authenticate db: .* { authenticate: .*, nonce: .*, user: .*, key: .* }.*failure.*$
ignoreregex =
EOF

# Filtro customizado para ataques de força bruta HTTP
cat > /etc/fail2ban/filter.d/http-bruteforce.conf << 'EOF'
[Definition]
failregex = ^<HOST> -.*"(GET|POST).*(wp-login\.php|xmlrpc\.php|admin|login).*" (403|404|401)
ignoreregex =
EOF

# Jail para o filtro customizado
cat >> /etc/fail2ban/jail.local << 'EOF'

# Filtro customizado para ataques HTTP
[http-bruteforce]
enabled = true
port = http,https
filter = http-bruteforce
logpath = /var/log/apache2/access.log
          /var/log/nginx/access.log
maxretry = 10
bantime = 3600
findtime = 600
EOF

# Configurar ação personalizada para logs detalhados
cat > /etc/fail2ban/action.d/iptables-multiport-log.conf << 'EOF'
[INCLUDES]
before = iptables-common.conf

[Definition]
actionstart = <iptables> -N f2b-<name>
              <iptables> -A f2b-<name> -j <returntype>
              <iptables> -I <chain> -p <protocol> -m multiport --dports <port> -j f2b-<name>

actionstop = <iptables> -D <chain> -p <protocol> -m multiport --dports <port> -j f2b-<name>
             <iptables> -F f2b-<name>
             <iptables> -X f2b-<name>

actioncheck = <iptables> -n -L <chain> | grep -q 'f2b-<name>[ \t]'

actionban = <iptables> -I f2b-<name> 1 -s <ip> -j <blocktype>
            echo "`date` [FAIL2BAN] Banned IP <ip> for <name>" >> /var/log/fail2ban-bans.log

actionunban = <iptables> -D f2b-<name> -s <ip> -j <blocktype>
              echo "`date` [FAIL2BAN] Unbanned IP <ip> for <name>" >> /var/log/fail2ban-bans.log

[Init]
EOF

# Configurar logrotate para os logs do fail2ban
cat > /etc/logrotate.d/fail2ban-custom << 'EOF'
/var/log/fail2ban-bans.log {
    weekly
    rotate 12
    compress
    delaycompress
    missingok
    notifempty
    create 640 root adm
}
EOF

# Criar script de monitoramento
cat > /usr/local/bin/fail2ban-status.sh << 'EOF'
#!/bin/bash

echo "=== FAIL2BAN STATUS REPORT ==="
echo "Data: $(date)"
echo

echo "=== JAILS ATIVAS ==="
fail2ban-client status | grep "Jail list:" | sed 's/.*://; s/,/\n/g' | while read jail; do
    jail=$(echo $jail | xargs)
    if [ ! -z "$jail" ]; then
        echo "--- $jail ---"
        fail2ban-client status $jail | grep "Currently banned" | sed 's/.*:/Banidos:/'
        fail2ban-client status $jail | grep "Total banned" | sed 's/.*:/Total banidos:/'
        echo
    fi
done

echo "=== ÚLTIMOS BANS (últimas 24h) ==="
if [ -f /var/log/fail2ban-bans.log ]; then
    grep "$(date +'%Y-%m-%d')" /var/log/fail2ban-bans.log | tail -20
else
    echo "Log de bans não encontrado"
fi

echo
echo "=== TOP 10 IPs BANIDOS ==="
fail2ban-client banned | sort | uniq -c | sort -nr | head -10

echo
echo "=== REGRAS IPTABLES ATIVAS ==="
iptables -L | grep f2b
EOF

chmod +x /usr/local/bin/fail2ban-status.sh

# Configurar cron para relatórios diários
cat > /etc/cron.daily/fail2ban-report << 'EOF'
#!/bin/bash
/usr/local/bin/fail2ban-status.sh > /var/log/fail2ban-daily-report.log 2>&1
EOF

chmod +x /etc/cron.daily/fail2ban-report

# Configurar systemd override para fail2ban
mkdir -p /etc/systemd/system/fail2ban.service.d
cat > /etc/systemd/system/fail2ban.service.d/override.conf << 'EOF'
[Service]
Restart=always
RestartSec=5
EOF

# Verificar configuração
echo "Verificando configuração..."
fail2ban-client -t

# Habilitar e iniciar serviços
systemctl daemon-reload
systemctl enable fail2ban
systemctl restart fail2ban

# Configurar iptables para persistir as regras
iptables-save > /etc/iptables/rules.v4

echo "=== CONFIGURAÇÃO CONCLUÍDA ==="
echo "Para monitorar: /usr/local/bin/fail2ban-status.sh"
echo "Logs principais:"
echo "  - /var/log/fail2ban.log"
echo "  - /var/log/fail2ban-bans.log"
echo
echo "Comandos úteis:"
echo "  fail2ban-client status"
echo "  fail2ban-client status [jail-name]"
echo "  fail2ban-client unban [ip]"
echo "  tail -f /var/log/fail2ban.log"
