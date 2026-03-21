import apiClient from './client'

export interface LoginRequest {
  username: string
  password: string
}

export interface LoginResponse {
  token: string
  user: {
    id: number
    username: string
    role: string
  }
}

export const authApi = {
  login: (data: LoginRequest) =>
    apiClient.post<LoginResponse>('/auth/login', data),
  
  logout: () =>
    apiClient.post('/auth/logout'),
  
  me: () =>
    apiClient.get('/auth/me'),
}
