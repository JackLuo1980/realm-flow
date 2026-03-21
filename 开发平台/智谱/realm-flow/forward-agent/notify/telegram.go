package notify

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

type TelegramNotifier struct {
	botToken string
	chatID   string
}

type TelegramMessage struct {
	ChatID    string `json:"chat_id"`
	Text      string `json:"text"`
	ParseMode string `json:"parse_mode,omitempty"`
}

func NewTelegramNotifier(botToken, chatID string) *TelegramNotifier {
	return &TelegramNotifier{
		botToken: botToken,
		chatID:   chatID,
	}
}

func (n *TelegramNotifier) Send(message string) error {
	apiURL := fmt.Sprintf("https://api.telegram.org/bot%s/sendMessage", n.botToken)

	msg := TelegramMessage{
		ChatID:    n.chatID,
		Text:      message,
		ParseMode: "HTML",
	}

	jsonData, err := json.Marshal(msg)
	if err != nil {
		return err
	}

	resp, err := http.Post(apiURL, "application/json", bytes.NewReader(jsonData))
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("telegram API returned status %d", resp.StatusCode)
	}

	return nil
}

func (n *TelegramNotifier) SendAlert(alertType, message string) error {
	formatted := formatAlert(alertType, message)
	return n.Send(formatted)
}

func formatAlert(alertType, message string) string {
	var emoji string
	switch alertType {
	case "traffic_alert":
		emoji = "📊"
	case "traffic_exceed":
		emoji = "⚠️"
	case "node_down":
		emoji = "🔴"
	case "node_online":
		emoji = "🟢"
	case "forward_down":
		emoji = "❌"
	case "server_high_load":
		emoji = "⚡"
	default:
		emoji = "🔔"
	}

	return fmt.Sprintf("%s <b>%s</b>\n\n%s", emoji, alertType, message)
}

type Notification struct {
	Type    string
	Title   string
	Message string
}

type NotifyManager struct {
	telegram *TelegramNotifier
	channels []chan Notification
}

func NewNotifyManager(botToken, chatID string) *NotifyManager {
	return &NotifyManager{
		telegram: NewTelegramNotifier(botToken, chatID),
		channels: make([]chan Notification, 0),
	}
}

func (m *NotifyManager) AddChannel() chan Notification {
	ch := make(chan Notification, 100)
	m.channels = append(m.channels, ch)
	return ch
}

func (m *NotifyManager) Start() {
	for _, ch := range m.channels {
		go m.processChannel(ch)
	}
}

func (m *NotifyManager) Stop() {
	for _, ch := range m.channels {
		close(ch)
	}
}

func (m *NotifyManager) processChannel(ch chan Notification) {
	for notification := range ch {
		if err := m.telegram.SendAlert(notification.Type, notification.Message); err != nil {
			log.Printf("Failed to send notification: %v", err)
		}
	}
}

func (m *NotifyManager) SendTrafficAlert(userID uint, message string) {
	notification := Notification{
		Type:    "traffic_alert",
		Title:   "流量告警",
		Message: message,
	}
	m.send(notification)
}

func (m *NotifyManager) SendNodeDown(nodeID uint, message string) {
	notification := Notification{
		Type:    "node_down",
		Title:   "节点离线",
		Message: message,
	}
	m.send(notification)
}

func (m *NotifyManager) SendNodeOnline(nodeID uint, message string) {
	notification := Notification{
		Type:    "node_online",
		Title:   "节点上线",
		Message: message,
	}
	m.send(notification)
}

func (m *NotifyManager) SendForwardDown(forwardID uint, message string) {
	notification := Notification{
		Type:    "forward_down",
		Title:   "转发故障",
		Message: message,
	}
	m.send(notification)
}

func (m *NotifyManager) send(notification Notification) {
	for _, ch := range m.channels {
		select {
		case ch <- notification:
		default:
			log.Printf("Notification channel full, dropping notification")
		}
	}
}
