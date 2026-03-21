import { useState } from 'react'
import { Table, Button, Modal, Form, Input, Tag, message, Popconfirm } from 'antd'
import { PlusOutlined, EditOutlined, DeleteOutlined, CopyOutlined } from '@ant-design/icons'

interface Node {
  id: number
  name: string
  host: string
  port: number
  status: string
  api_key: string
}

export const Nodes = () => {
  const [nodes] = useState<Node[]>([])
  const [loading] = useState(false)
  const [modalVisible, setModalVisible] = useState(false)
  const [editingNode, setEditingNode] = useState<Node | null>(null)
  const [form] = Form.useForm()

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id' },
    { title: '名称', dataIndex: 'name', key: 'name' },
    { title: '主机', dataIndex: 'host', key: 'host' },
    { title: '端口', dataIndex: 'port', key: 'port' },
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
      title: 'API Key',
      dataIndex: 'api_key',
      key: 'api_key',
      render: (key: string) => (
        <span>{key?.substring(0, 8)}... <Button icon={<CopyOutlined />} size="small" /></span>
      ),
    },
    {
      title: '操作',
      key: 'action',
      render: (_: any, record: Node) => (
        <>
          <Button icon={<EditOutlined />} onClick={() => handleEdit(record)} />
          <Popconfirm title="确定删除吗？" onConfirm={() => handleDelete(record.id)}>
            <Button icon={<DeleteOutlined />} danger style={{ marginLeft: 8 }} />
          </Popconfirm>
        </>
      ),
    },
  ]

  const handleEdit = (node: Node) => {
    setEditingNode(node)
    form.setFieldsValue(node)
    setModalVisible(true)
  }

  const handleDelete = async (_id: number) => {
    message.success('删除成功')
  }

  const handleSubmit = async (_values: any) => {
    message.success(editingNode ? '更新成功' : '创建成功')
    setModalVisible(false)
    form.resetFields()
  }

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 16 }}>
        <h1>节点管理</h1>
        <Button type="primary" icon={<PlusOutlined />} onClick={() => { setEditingNode(null); setModalVisible(true) }}>
          添加节点
        </Button>
      </div>
      <Table columns={columns} dataSource={nodes} loading={loading} rowKey="id" />
      
      <Modal
        title={editingNode ? '编辑节点' : '添加节点'}
        open={modalVisible}
        onCancel={() => setModalVisible(false)}
        onOk={() => form.submit()}
      >
        <Form form={form} onFinish={handleSubmit} layout="vertical">
          <Form.Item name="name" label="名称" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="host" label="主机" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="port" label="端口" initialValue={6365}>
            <Input type="number" />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  )
}
