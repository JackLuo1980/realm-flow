import { useState } from 'react'
import { Table, Button, Modal, Form, Input, Select, Tag, message, Popconfirm } from 'antd'
import { PlusOutlined, EditOutlined, DeleteOutlined, EyeOutlined } from '@ant-design/icons'

interface Tunnel {
  id: number
  name: string
  user_id: number
  node_id: number
  remote_addr: string
  remote_port: number
  default_engine: string
  status: string
}

export const Tunnels = () => {
  const [tunnels] = useState<Tunnel[]>([])
  const [loading] = useState(false)
  const [modalVisible, setModalVisible] = useState(false)
  const [editingTunnel, setEditingTunnel] = useState<Tunnel | null>(null)
  const [form] = Form.useForm()

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id' },
    { title: '名称', dataIndex: 'name', key: 'name' },
    { title: '远程地址', dataIndex: 'remote_addr', key: 'remote_addr' },
    { title: '远程端口', dataIndex: 'remote_port', key: 'remote_port' },
    {
      title: '默认引擎',
      dataIndex: 'default_engine',
      key: 'default_engine',
      render: (engine: string) => (
        <Tag color={engine === 'nftables' ? 'blue' : 'green'}>{engine}</Tag>
      ),
    },
    {
      title: '状态',
      dataIndex: 'status',
      key: 'status',
      render: (status: string) => (
        <Tag color={status === 'active' ? 'success' : 'default'}>
          {status === 'active' ? '启用' : '禁用'}
        </Tag>
      ),
    },
    {
      title: '操作',
      key: 'action',
      render: (_: any, record: Tunnel) => (
        <>
          <Button icon={<EyeOutlined />} />
          <Button icon={<EditOutlined />} onClick={() => handleEdit(record)} style={{ marginLeft: 8 }} />
          <Popconfirm title="确定删除吗？" onConfirm={() => handleDelete(record.id)}>
            <Button icon={<DeleteOutlined />} danger style={{ marginLeft: 8 }} />
          </Popconfirm>
        </>
      ),
    },
  ]

  const handleEdit = (tunnel: Tunnel) => {
    setEditingTunnel(tunnel)
    form.setFieldsValue(tunnel)
    setModalVisible(true)
  }

  const handleDelete = async (_id: number) => {
    message.success('删除成功')
  }

  const handleSubmit = async (_values: any) => {
    message.success(editingTunnel ? '更新成功' : '创建成功')
    setModalVisible(false)
    form.resetFields()
  }

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 16 }}>
        <h1>隧道管理</h1>
        <Button type="primary" icon={<PlusOutlined />} onClick={() => { setEditingTunnel(null); setModalVisible(true) }}>
          添加隧道
        </Button>
      </div>
      <Table columns={columns} dataSource={tunnels} loading={loading} rowKey="id" />
      
      <Modal
        title={editingTunnel ? '编辑隧道' : '添加隧道'}
        open={modalVisible}
        onCancel={() => setModalVisible(false)}
        onOk={() => form.submit()}
      >
        <Form form={form} onFinish={handleSubmit} layout="vertical">
          <Form.Item name="name" label="名称" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="node_id" label="节点" rules={[{ required: true }]}>
            <Select options={[]} />
          </Form.Item>
          <Form.Item name="remote_addr" label="远程地址">
            <Input />
          </Form.Item>
          <Form.Item name="remote_port" label="远程端口">
            <Input type="number" />
          </Form.Item>
          <Form.Item name="default_engine" label="默认引擎" initialValue="nftables">
            <Select options={[{ label: 'nftables', value: 'nftables' }, { label: 'realm', value: 'realm' }]} />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  )
}
