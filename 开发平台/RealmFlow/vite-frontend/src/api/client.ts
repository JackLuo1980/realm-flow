import axios, { AxiosHeaders } from "axios";

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL ?? "http://127.0.0.1:6365",
  timeout: 15000,
});

api.interceptors.request.use((config) => {
  const token = window.localStorage.getItem("realmflow-token");
  if (token) {
    config.headers = AxiosHeaders.from(config.headers);
    config.headers.set("Authorization", token);
  }
  return config;
});
