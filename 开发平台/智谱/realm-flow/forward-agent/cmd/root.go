package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var cfgFile string

var rootCmd = &cobra.Command{
	Use:   "forward-agent",
	Short: "RealmFlow 转发代理",
	Long: `forward-agent 是 RealmFlow 的轻量级客户端，
支持 nftables 和 realm 两种转发引擎。`,
	Run: func(cmd *cobra.Command, args []string) {
		cmd.Help()
	},
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func init() {
	cobra.OnInitialize(initConfig)

	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "配置文件路径")
	rootCmd.PersistentFlags().String("panel-url", "", "面板地址")
	rootCmd.PersistentFlags().String("api-key", "", "API Key")
	rootCmd.PersistentFlags().Int("node-id", 0, "节点 ID")

	viper.BindPFlag("panel_url", rootCmd.PersistentFlags().Lookup("panel-url"))
	viper.BindPFlag("api_key", rootCmd.PersistentFlags().Lookup("api-key"))
	viper.BindPFlag("node_id", rootCmd.PersistentFlags().Lookup("node-id"))
}

func initConfig() {
	if cfgFile != "" {
		viper.SetConfigFile(cfgFile)
	} else {
		viper.AddConfigPath("/etc/forward-agent/")
		viper.AddConfigPath(".")
		viper.SetConfigName("config")
	}

	viper.SetConfigType("yaml")
	viper.AutomaticEnv()

	if err := viper.ReadInConfig(); err == nil {
		fmt.Println("Using config file:", viper.ConfigFileUsed())
	}
}
