package main

// #include <stdint.h>
import "C"

import (
	"fmt"
	"github.com/ltcmweb/mwebd"
	"sync"
)

// Global registry to keep Go objects alive
var (
	serverRegistry   = make(map[uintptr]*mwebd.Server)
	serverRegistryMu sync.Mutex
	serverCounter    uintptr = 1
)

//export CreateServer
func CreateServer(chain, dataDir, peer, proxy *C.char) C.uintptr_t {
	args := &mwebd.ServerArgs{
		Chain:     C.GoString(chain),
		DataDir:   C.GoString(dataDir),
		PeerAddr:  C.GoString(peer),
		ProxyAddr: C.GoString(proxy),
	}
	server, err := mwebd.NewServer2(args)
	if err != nil {
		fmt.Print("error")
		panic(err)
	}

	serverRegistryMu.Lock()
	id := serverCounter
	serverRegistry[id] = server
	serverCounter++
	serverRegistryMu.Unlock()

	return C.uintptr_t(id)

}

//export StartServer
func StartServer(id C.uintptr_t, port C.int) C.int {
	serverRegistryMu.Lock()
	defer serverRegistryMu.Unlock()
	server := serverRegistry[uintptr(id)]
	// go waitForParent(server)
	selectedPort, err := server.Start(int(port))
	if err != nil {
		panic(err)
	}
	return C.int(selectedPort)
}

//export StopServer
func StopServer(id C.uintptr_t) {
	server := serverRegistry[uintptr(id)]
	server.Stop()
	serverRegistryMu.Lock()
	delete(serverRegistry, uintptr(id))
	serverRegistryMu.Unlock()
}

func main() {}
