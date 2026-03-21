package model

import "testing"

func TestNotifyConfigZeroValue(t *testing.T) {
	var cfg NotifyConfig
	if cfg.Enabled || cfg.TrafficThreshold != 0 {
		t.Fatalf("zero value NotifyConfig should be empty, got %+v", cfg)
	}
}
