package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"

	"github.com/CptOfEvilMinions/go-openvpn-github-connector/pkg/api"
	"github.com/CptOfEvilMinions/go-openvpn-github-connector/pkg/config"
)

func main() {
	if len(os.Args) != 3 {
		os.Exit(-1)
	}

	// Only triage client cert
	// If depth is zero, we know that this is the final
	// certificate in the chain (i.e. the client certificate),
	// and the one we are interested in examining.
	// If so, parse out the common name substring in
	// the X509 subject string.
	certDepth, err := strconv.Atoi(os.Args[1])
	if err != nil {
		fmt.Println("Depth input parameter must be integer")
		os.Exit(-1)
	}
	if certDepth != 0 {
		os.Exit(0)
	}

	// Get cert common name from cmd args
	cnArg := os.Args[2]
	clientCertCommonname := strings.Split(cnArg, "CN=")[1]
	if clientCertCommonname == "" {
		os.Exit(-1)
	}
	log.Printf("%s attempting to authenticate", clientCertCommonname)

	// Read our config based on the config supplied
	cfg, err := config.NewConfig("/etc/go-openvpn-github-connector/settings.yaml")
	if err != nil {
		log.Printf("Error opening config file: %s\n", err.Error())
		os.Exit(-1)
	}

	// Init HTTP client
	api.InitHTTPclient(cfg)

	// Check if username exists in Github team
	writeStatus(
		api.HttpClient.CheckListOfUsersInTeam(clientCertCommonname, cfg),
		clientCertCommonname,
	)
}

func writeStatus(success bool, username string) {
	if success {
		log.Printf("Authorization was successful for user %s\n", username)
		os.Exit(0)
	}
	log.Printf("Authorization WAS NOT successful for user %s\n", username)
	os.Exit(-1)
}
