import { useState, useEffect } from 'react'
import { Row, Col, Card, Statistic, Table, Tag, Spin } from 'antd'
import { ArrowUpOutlined, CloudServerOutlined, SwapOutlined, UserOutlined, UploadOutlined } from '@ant-design/icons'
import { monitorAPI } from '../api/monitor'
import type { DashboardStats } from '../api/monitor'

export const Dashboard = () => {
	const [stats, setStats] = useState<DashboardStats>({
		total_nodes: 0,
		online_nodes: 0,
		total_tunnels: 0,
		active_tunnels: 0,
		total_users: 0,
		today_traffic: 0,
	})
	const [loading, setLoading] = useState(true)

	const formatTraffic = (bytes: number) => {
		if (bytes < 1024) return `${bytes} B`
		if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(2)} KB`
		if (bytes < 1024 * 1024 * 1024) return `${(bytes / (1024 * 1024)).toFixed(2)} MB`
		return `${(bytes / (1024 * 1024 * 1024)).toFixed(2)} GB`
	}

	useEffect(() => {
		const fetchDashboardData = async () => {
			try {
				setLoading(true)
				const data = await monitorAPI.getDashboard()
				setStats(data)
			} catch (error) {
				console.error('Failed to fetch dashboard data:', error)
			} finally {
				setLoading(false)
			}
		}

		fetchDashboardData()

		const interval = setInterval(fetchDashboardData, 30000)
		return () => clearInterval(interval)
	}, [])

	const columns = [
		{
			title: '节点',
			dataIndex: 'node',
			key: 'node',
		},
		{
			title: '状态',
			dataIndex: 'status',
			key: 'status',
			render: (status: string) => (
				<Tag color={status === 'online' ? 'success' : 'error'}>
					{status === 'online' ? '在线' : '离线'}
				</Tag>
			),
		},
		{
			title: '流量',
			dataIndex: 'traffic',
			key: 'traffic',
			render: (traffic: number) => formatTraffic(traffic),
		},
	]

	if (loading) {
		return (
			<div style={{ textAlign: 'center', padding: '50px' }}>
				<Spin size="large" />
			</div>
		)
	}

	return (
		<div>
			<h1>仪表盘</h1>
			<Row gutter={16} style={{ marginTop: 24 }}>
				<Col span={6}>
					<Card>
						<Statistic
							title="节点总数"
							value={stats.total_nodes}
							prefix={<CloudServerOutlined />}
						/>
					</Card>
				</Col>
				<Col span={6}>
					<Card>
						<Statistic
							title="在线节点"
							value={stats.online_nodes}
							valueStyle={{ color: '#3f8600' }}
							prefix={<ArrowUpOutlined />}
						/>
					</Card>
				</Col>
				<Col span={6}>
					<Card>
						<Statistic
							title="隧道总数"
							value={stats.total_tunnels}
							prefix={<SwapOutlined />}
						/>
					</Card>
				</Col>
				<Col span={6}>
					<Card>
						<Statistic
							title="活跃用户"
							value={stats.total_users}
							prefix={<UserOutlined />}
						/>
					</Card>
				</Col>
			</Row>
			<Row gutter={16} style={{ marginTop: 16 }}>
				<Col span={12}>
					<Card>
						<Statistic
							title="活跃隧道"
							value={stats.active_tunnels}
							prefix={<SwapOutlined />}
						/>
					</Card>
				</Col>
				<Col span={12}>
					<Card>
						<Statistic
							title="今日流量"
							value={formatTraffic(stats.today_traffic)}
							prefix={<UploadOutlined />}
						/>
					</Card>
				</Col>
			</Row>
			<Card title="节点状态" style={{ marginTop: 24 }}>
				<Table columns={columns} dataSource={[]} rowKey="id" />
			</Card>
		</div>
	)
}
