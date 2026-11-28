systemctl status falco
journalctl -u falco --no-pager | tail -30

#alerts

cat /var/log/syslog | grep falco
journalctl -u falco -f

#rules path

ls /etc/falco/
cat /etc/falco/falco_rules.yaml
cat /etc/falco/rules.d/
