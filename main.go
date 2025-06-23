package main

// #cgo CFLAGS: -Wall -Wextra
// #include <stdint.h>
// typedef struct {
//     int32_t  block_header_height;
//     int32_t  mweb_header_height;
//     int32_t  mweb_utxos_height;
//     uint32_t block_time;
// } StatusResponse;
import "C"

import (
	"context"
	"fmt"
	"sync"

	"github.com/ltcmweb/mwebd"
	"github.com/ltcmweb/mwebd/proto"
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
	server := serverRegistry[uintptr(id)]
	var selectedPort int

	if port != 0 {
		selectedPort = int(port)
		go server.Start(int(port))
	} else {
		port, err := server.Start(int(port))
		selectedPort = int(port)
		if err != nil {
			panic(err)
		}
	}
	serverRegistryMu.Unlock()
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

//export Status
func Status(id C.uintptr_t) *C.StatusResponse {
	server := serverRegistry[uintptr(id)]
	response, err := server.Status(context.Background(), &proto.StatusRequest{})
	if err != nil {
		panic(err)
	}

	s := C.malloc(C.sizeof_StatusResponse)
	resp := (*C.StatusResponse)(s)
	resp.block_header_height = C.int32_t(response.BlockHeaderHeight)
	resp.mweb_header_height = C.int32_t(response.MwebHeaderHeight)
	resp.mweb_utxos_height = C.int32_t(response.MwebUtxosHeight)
	resp.block_time = C.uint32_t(response.BlockTime)
	return resp

}

func main() {}
