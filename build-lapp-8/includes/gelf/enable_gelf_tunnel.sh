cp /root/.ssh/gelf.key.mounted /root/.ssh/gelf.key
chmod 600 /root/.ssh/gelf.key
dos2unix /root/.ssh/gelf.key
ssh -o StrictHostKeyChecking=no -L 127.0.0.1:12201:127.0.0.1:12201 -p61107 gelf@graylog.3pth.com -f -N