import { createBrowserRouter, Navigate } from 'react-router-dom'
import { Layout } from './components/Layout'
import { Login } from './pages/Login'
import { Dashboard } from './pages/Dashboard'
import { Users } from './pages/Users'
import { Nodes } from './pages/Nodes'
import { Tunnels } from './pages/Tunnels'
import { Forwards } from './pages/Forwards'
import { Monitor } from './pages/Monitor'

export const router = createBrowserRouter([
  {
    path: '/login',
    element: <Login />,
  },
  {
    path: '/',
    element: <Layout />,
    children: [
      {
        index: true,
        element: <Navigate to="/dashboard" replace />,
      },
      {
        path: 'dashboard',
        element: <Dashboard />,
      },
      {
        path: 'users',
        element: <Users />,
      },
      {
        path: 'nodes',
        element: <Nodes />,
      },
      {
        path: 'tunnels',
        element: <Tunnels />,
      },
      {
        path: 'forwards',
        element: <Forwards />,
      },
      {
        path: 'monitor',
        element: <Monitor />,
      },
    ],
  },
])
