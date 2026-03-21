import { useState } from 'react'
import { Card, Select, Table, Row, Col } from 'antd'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'

export const Monitor = () => {
  const [trafficData] = useState([
    { time: '00:00', upload: 100, download: 200 },
    { time: '04:00', upload: 150, download: 300 },
    { time: '08:00', upload: 300, download: 500 },
    { time: '12:00', upload: 250, download: 400 },
    { time: '16:00', upload: 400, download: 600 },
    { time: '20:00', upload: 350, download: 550 },
    { time: '23:59', upload: 200, download: 350 },
  ])

  const columns = [
    { title: '时间', dataIndex: 'timestamp', key: 'timestamp' },
    { title: '上传', dataIndex: 'upload', key: 'upload' },
    { title: '下载', dataIndex: 'download', key: 'download' },
    { title: '总计', dataIndex: 'total', key: 'total' },
  ]

  return (
    <div>
      <h1>监控统计</h1>
      
      <Row gutter={16} style={{ marginBottom: 24 }}>
        <Col span={12}>
          <Select style={{ width: '100%' }} defaultValue="24h" options={[
            { label: '24小时', value: '24h' },
            { label: '7天', value: '7d' },
            { label: '30天', value: '30d' },
          ]} />
        </Col>
        <Col span={12}>
          <Select style={{ width: '100%' }} defaultValue="all" options={[
            { label: '全部节点', value: 'all' },
          ]} />
        </Col>
      </Row>

      <Card title="流量趋势" style={{ marginBottom: 24 }}>
        <ResponsiveContainer width="100%" height={300}>
          <LineChart data={trafficData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="time" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="upload" name="上传" stroke="#8884d8" />
            <Line type="monotone" dataKey="download" name="下载" stroke="#82ca9d" />
          </LineChart>
        </ResponsiveContainer>
      </Card>

      <Card title="流量记录">
        <Table columns={columns} dataSource={[]} rowKey="id" />
      </Card>
    </div>
  )
}
