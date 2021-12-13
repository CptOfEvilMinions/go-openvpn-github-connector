#!/bin/bash
set -e


if [ -f /etc/openvpn/easy-rsa/pki/reqs/${SUDO_USER}.req ]
then
    echo "[*] - Openvpn client cert already exists - exitting"
    echo "[*] - Regenerating OpenVPN client config - /home/${SUDO_USER}/openvpn_${SUDO_USER}_client.ovpn"
else
	# Change directory
    cd /etc/openvpn/easy-rsa

    # Generate client config
    echo "" | ./easyrsa gen-req ${SUDO_USER} nopass

    # Sign client key
    echo "yes" | ./easyrsa sign-req client ${SUDO_USER}
fi

# Copy client cert to home directory
cp /etc/openvpn/easy-rsa/pki/ca.crt                     /home/${SUDO_USER}/openvpn_ca.crt
cp /etc/openvpn/easy-rsa/pki/issued/${SUDO_USER}.crt    /home/${SUDO_USER}/openvpn_${SUDO_USER}.crt
cp /etc/openvpn/easy-rsa/pki/private/${SUDO_USER}.key   /home/${SUDO_USER}/openvpn_${SUDO_USER}.key
chown ${SUDO_USER}:${SUDO_USER} \
    /home/${SUDO_USER}/openvpn_ca.crt \
    /home/${SUDO_USER}/openvpn_${SUDO_USER}.crt \
    /home/${SUDO_USER}/openvpn_${SUDO_USER}.key

# Get public IP
JUMPBOX_PUBLIC_IP=$(curl -s ifconfig.me)

cat > /home/${SUDO_USER}/openvpn_${SUDO_USER}_client.ovpn << EOF
client
dev tun
proto udp
remote ${JUMPBOX_PUBLIC_IP} 1194
cipher AES-256-CBC
auth SHA512
auth-nocache
tls-version-min 1.2
tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA256
resolv-retry infinite
compress lz4
nobind
persist-key
persist-tun
mute-replay-warnings
verb 3
EOF

# Append server CA, user cert, and user key to OpenVPN config
echo -e "<ca>\n$(cat /home/${SUDO_USER}/openvpn_ca.crt)\n</ca>" >> /home/${SUDO_USER}/openvpn_${SUDO_USER}_client.ovpn
echo -e "<cert>\n$(cat /home/${SUDO_USER}/openvpn_${SUDO_USER}.crt | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')\n</cert>" >> /home/${SUDO_USER}/openvpn_${SUDO_USER}_client.ovpn
echo -e "<key>\n$(cat /home/${SUDO_USER}/openvpn_${SUDO_USER}.key)\n</key>" >> /home/${SUDO_USER}/openvpn_${SUDO_USER}_client.ovpn

# Set permissions
chown ${SUDO_USER}:${SUDO_USER} /home/${SUDO_USER}/openvpn_${SUDO_USER}_client.ovpn

echo "[*] - OpenVPN client config generated - /home/${SUDO_USER}/openvpn_${SUDO_USER}_client.ovpn"
