#!/bin/bash
cat <<EOF > /root/index.html
<html><body><h1>Hello World</h1>
<p>This page was created from a startup script.</p>
</body></html>
EOF

gsutil cp /root/index.html gs://ari-project-1982

sh /docker-setup/shutdown-script.sh