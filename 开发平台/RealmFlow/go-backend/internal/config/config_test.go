package config

import "testing"

func TestDBDriver(t *testing.T) {
	cases := []struct {
		name string
		url  string
		want string
	}{
		{name: "sqlite", url: "file:test.db", want: "sqlite"},
		{name: "postgres", url: "postgres://user:pass@localhost/db", want: "postgres"},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			cfg := Config{DatabaseURL: tc.url}
			if got := cfg.DBDriver(); got != tc.want {
				t.Fatalf("DBDriver() = %q, want %q", got, tc.want)
			}
		})
	}
}
