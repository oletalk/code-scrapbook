package main

import (
	"fmt"
	"io"
	"log"
	"os"

	"github.com/pkg/sftp"
	"golang.org/x/crypto/ssh"
)

func downloadFile(remotePath string, localFilename string) error {
	cache_dir := os.Getenv("CACHE_DIR")
	log.Println("downloading file from SFTP location...")
	sftpClient, err := getClient()
	if err != nil {
		log.Println("Failed to open sftp connection:", err)
		return err
	}
	remoteFile, err := sftpClient.Open(remotePath)
	if err != nil {
		log.Println("Failed to open remote file:", err)
		return err
	}
	defer sftpClient.Close()
	defer remoteFile.Close()
	log.Println("Creating file locally")
	localFile, err := os.Create(cache_dir + "/" + localFilename)
	if err != nil {
		log.Println("Failed to create local file:", err)
		return err
	}
	defer func() {
		if cerr := localFile.Close(); cerr != nil && err == nil {
			// err = cerr
			log.Println("Problem closing local file:", cerr)
		}
	}()

	// copy file remote to local
	_, err = io.Copy(localFile, remoteFile)
	if err != nil {
		log.Println("Failed to download file:", err)
		return err
	}
	return nil
}

func getClient() (*sftp.Client, error) {
	// SFTP connection parameters

	host := os.Getenv("SFTP_HOST")
	port := 22
	user := os.Getenv("SFTP_USER")
	password := os.Getenv("SFTP_PASSWORD")

	config := &ssh.ClientConfig{
		User: user,
		Auth: []ssh.AuthMethod{
			ssh.Password(password),
		},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}

	// connect
	conn, err := ssh.Dial("tcp", fmt.Sprintf("%s:%d", host, port), config)
	if err != nil {
		log.Println("Failed to connect to SSH server", err)
		return nil, err
	}

	// open SFTP session
	sftpClient, err := sftp.NewClient(conn)
	if err != nil {
		log.Println("Failed to open SFTP session: ", err)
		return nil, err
	}
	return sftpClient, nil
}
