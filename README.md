# go-openvpn-github-connector


## Compile from source
1. `GOOS=linux GOARCH=amd64 go build -o bin/go-openvpn-github-connector.bin main.go`


## Install/Setup go-openvpn-github-connector on Ubuntu Server 20.04 64-bit
### Install OpenVPN plugin
1. Copy `bin/go-openvpn-github-connector.bin` to Ubuntu server
1. SSH into Ubunut server
1. `mkdir -p /usr/local/lib/openvpn/plugin`
1. `mv go-openvpn-github-connector.bin /usr/local/lib/openvpn/plugin/go-openvpn-github-connector.bin`

### Setup github plugin
1. `vim /etc/go-openvpn-github-connector/settings.yaml` and set:
```yaml
organization: '<Github org>'
team: '<github team in org>'
token: '<Github USER token>'
# Depth 0 - typically, client cert
cert_depth: 0
```

### Setup OpenVPN server
1. `vim /etc/openvpn/server.conf` and append:
    ```
    tls-verify "/usr/local/lib/openvpn/plugin/go-openvpn-github-connector.bin 0 cn"
    verify-client-cert require
    ```
1. `systemctl restart openvpn@server`

### Setup OpenVPN client generation script
1. `sudo su`
1. `visduo`
1. Append to the END OF THE FILE (EOF): `ALL ALL=NOPASSWD: /etc/openvpn/generate_client_vpn.sh`


## Generate OpenVPN cert with script
1. SSH into OpenVPN server as a user
1. `sudo /etc/openvpn/generate_client_vpn.sh`
1. Logout 
1. `scp -r <user>@<OpenVPN IP addr>:~/openvpn_<user>_client.ovpn ~/Desktop/openvpn_<user>_client.ovpn`

## Suppported versions
* `go1.17.5`
* `Ubuntu server 20.04 64-bit`
* `OpenVPN 2.4.7`

## References
* [Download and install](https://go.dev/doc/install)
* [Building and linking dynamically from a go binary](https://stackoverflow.com/questions/19431296/building-and-linking-dynamically-from-a-go-binary)
* [Call C code from Golang](https://medium.com/@vivek2793/call-c-code-from-golang-8783c6b58a5c)
* [EMBEDDED DEVELOPMENT WITH C AND GOLANG (CGO)](https://www.lobaro.com/embedded-development-with-c-and-golang-cgo/)
* [go-authy-openvpn/src/main.go ](https://github.com/3fs/go-authy-openvpn/blob/master/src/main.go#L86)
* [auth-script-openvpn/auth_script.c](https://github.com/matevzmihalic/auth-script-openvpn/blob/master/auth_script.c)
* [Set up SSH public key authentication to connect to a remote system](https://kb.iu.edu/d/aews)
* [Go by Example: Exit](https://gobyexample.com/exit)
* [Golang: How do I convert command line arguments to integers?](https://stackoverflow.com/questions/24319352/golang-how-do-i-convert-command-line-arguments-to-integers)
* [3 ways to split a string into a slice](https://yourbasic.org/golang/split-string-into-slice/)
* [Go by Example: Command-Line Arguments](https://gobyexample.com/command-line-arguments)
* [Reference manual for OpenVPN 2.4](https://openvpn.net/community-resources/reference-manual-for-openvpn-2-4/)
* [[Troubleshooting]Check the CN of the client certificate](https://forums.openvpn.net/viewtopic.php?t=15901)
* []()
* []()
* []()
* []()
* []()
* []()
* []()
* []()
