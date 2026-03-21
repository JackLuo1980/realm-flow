import { useState } from 'react'
import { Table, Button, Modal, Form, Input, Select, Tag, message, Popconfirm } from 'antd'
import { PlusOutlined, EditOutlined, DeleteOutlined, PlayCircleOutlined, PauseCircleOutlined } from '@ant-design/icons'

interface Forward {
  id: number
  tunnel_id: number
  name: string
  listen_port: number
  listen_ip: string
  target_addr: string
  target_port: number
  protocol: string
  engine: string
  enabled: boolean
  status: string
}

export const Forwards = () => {
  const [forwards] = useState<Forward[]>([])
  const [loading] = useState(false)
  const [modalVisible, setModalVisible] = useState(false)
  const [editingForward, setEditingForward] = useState<Forward | null>(null)
  const [form] = Form.useForm()

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id' },
    { title: '名称', dataIndex: 'name', key: 'name' },
    { title: '监听', dataIndex: 'listen_port', key: 'listen_port', render: (_: any, record: Forward) => `${record.listen_ip}:${record.listen_port}` },
    { title: '目标', dataIndex: 'target_addr', key: 'target_addr', render: (_: any, record: Forward) => `${record.target_addr}:${record.target_port}` },
    { title: '协议', dataIndex: 'protocol', key: 'protocol' },
    {
      title: '引擎',
      dataIndex: 'engine',
      key: 'engine',
      render: (engine: string) => (
        <Tag color={engine === 'nftables' ? 'blue' : 'green'}>{engine}</Tag>
      ),
    },
    {
      title: '状态',
      dataIndex: 'status',
      key: 'status',
      render: (status: string) => (
        <Tag color={status === 'running' ? 'success' : 'default'}>
          {status === 'running' ? '运行中' : '已停止'}
        </Tag>
      ),
    },
    {
      title: '操作',
      key: 'action',
      render: (_: any, record: Forward) => (
        <>
          <Button icon={record.status === 'running' ? <PauseCircleOutlined /> : <PlayCircleOutlined />} />
          <Button icon={<EditOutlined />} onClick={() => handleEdit(record)} style={{ marginLeft: 8 }} />
          <Popconfirm title="确定删除吗？" onConfirm={() => handleDelete(record.id)}>
            <Button icon={<DeleteOutlined />} danger style={{ marginLeft: 8 }} />
          </Popconfirm>
        </>
      ),
    },
  ]

  const handleEdit = (forward: Forward) => {
    setEditingForward(forward)
    form.setFieldsValue(forward)
    setModalVisible(true)
  }

  const handleDelete = async (_id: number) => {
    message.success('删除成功')
  }

  const handleSubmit = async (_values: any) => {
    message.success(editingForward ? '更新成功' : '创建成功')
    setModalVisible(false)
    form.resetFields()
  }

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 16 }}>
        <h1>转发管理</h1>
        <Button type="primary" icon={<PlusOutlined />} onClick={() => { setEditingForward(null); setModalVisible(true) }}>
          添加转发
        </Button>
      </div>
      <Table columns={columns} dataSource={forwards} loading={loading} rowKey="id" />
      
      <Modal
        title={editingForward ? '编辑转发' : '添加转发'}
        open={modalVisible}
        onCancel={() => setModalVisible(false)}
        onOk={() => form.submit()}
      >
        <Form form={form} onFinish={handleSubmit} layout="vertical">
          <Form.Item name="tunnel_id" label="隧道" rules={[{ required: true }]}>
            <Select options={[]} />
          </Form.Item>
          <Form.Item name="name" label="名称">
            <Input />
          </Form.Item>
          <Form.Item name="listen_ip" label="监听IP" initialValue="0.0.0.0">
            <Input />
          </Form.Item>
          <Form.Item name="listen_port" label="监听端口" rules={[{ required: true }]}>
            <Input type="number" />
          </Form.Item>
          <Form.Item name="target_addr" label="目标地址" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="target_port" label="目标端口" rules={[{ required: true }]}>
            <Input type="number" />
          </Form.Item>
          <Form.Item name="protocol" label="协议" initialValue="tcp">
            <Select options={[{ label: 'TCP', value: 'tcp' }, { label: 'UDP', value: 'udp' }]} />
          </Form.Item>
          <Form.Item name="engine" label="引擎" initialValue="nftables">
            <Select options={[{ label: 'nftables', value: 'nftables' }, { label: 'realm', value: 'realm' }]} />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  )
}
