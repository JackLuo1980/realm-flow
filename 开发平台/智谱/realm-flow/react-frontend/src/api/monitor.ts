import axios from 'axios'

const API_BASE = (import.meta as any).env?.VITE_API_BASE_URL || 'http://localhost:6365/api'

export interface DashboardStats {
	total_nodes: number
	online_nodes: number
	total_tunnels: number
	active_tunnels: number
	total_users: number
	today_traffic: number
}

export interface TrafficStats {
	upload: number
	download: number
	total: number
}

export const monitorAPI = {
	getDashboard: async () => {
		const response = await axios.get<DashboardStats>(`${API_BASE}/monitor/dashboard`)
		return response.data
	},

	getUserTraffic: async (userId: number, from?: string, to?: string) => {
		const params = new URLSearchParams()
		if (from) params.append('from', from)
		if (to) params.append('to', to)
		const response = await axios.get<TrafficStats>(`${API_BASE}/monitor/traffic/user/${userId}?${params}`)
		return response.data
	},

	getNodeTraffic: async (nodeId: number, from?: string, to?: string) => {
		const params = new URLSearchParams()
		if (from) params.append('from', from)
		if (to) params.append('to', to)
		const response = await axios.get<TrafficStats>(`${API_BASE}/monitor/traffic/node/${nodeId}?${params}`)
		return response.data
	},

	getTunnelTraffic: async (tunnelId: number, from?: string, to?: string) => {
		const params = new URLSearchParams()
		if (from) params.append('from', from)
		if (to) params.append('to', to)
		const response = await axios.get<TrafficStats>(`${API_BASE}/monitor/traffic/tunnel/${tunnelId}?${params}`)
		return response.data
	},

	getForwardTraffic: async (forwardId: number, from?: string, to?: string) => {
		const params = new URLSearchParams()
		if (from) params.append('from', from)
		if (to) params.append('to', to)
		const response = await axios.get<TrafficStats>(`${API_BASE}/monitor/traffic/forward/${forwardId}?${params}`)
		return response.data
	},

	getServerStatus: async () => {
		const response = await axios.get(`${API_BASE}/monitor/server`)
		return response.data
	},

	getServerStatusByID: async (nodeId: number) => {
		const response = await axios.get(`${API_BASE}/monitor/server/${nodeId}`)
		return response.data
	},
}
