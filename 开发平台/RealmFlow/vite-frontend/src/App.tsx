import { Navigate, NavLink, Route, Routes } from "react-router-dom";
import { createContext, useContext, useEffect, useMemo, useState } from "react";
import { api } from "./api/client";

type Theme = "dark" | "light";

const ThemeContext = createContext<{
  theme: Theme;
  toggleTheme: () => void;
} | null>(null);

function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error("useTheme must be used within ThemeProvider");
  }
  return context;
}

function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<Theme>(() => {
    const saved = window.localStorage.getItem("realmflow-theme");
    return saved === "light" ? "light" : "dark";
  });

  useEffect(() => {
    document.documentElement.dataset.theme = theme;
    window.localStorage.setItem("realmflow-theme", theme);
  }, [theme]);

  const value = useMemo(
    () => ({
      theme,
      toggleTheme: () => setTheme((current) => (current === "dark" ? "light" : "dark")),
    }),
    [theme],
  );

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

function Shell() {
  const { theme, toggleTheme } = useTheme();

  const navItems = [
    { path: "/dashboard", label: "Dashboard" },
    { path: "/forward", label: "Forward" },
    { path: "/tunnel", label: "Tunnel" },
    { path: "/node", label: "Node" },
    { path: "/monitor", label: "Monitor" },
    { path: "/limit", label: "Limit" },
    { path: "/user", label: "User" },
    { path: "/group", label: "Group" },
    { path: "/panel-sharing", label: "Panel Sharing" },
    { path: "/config", label: "Config" },
  ];

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="brand">
          <div className="brand-mark">RF</div>
          <div>
            <strong>RealmFlow</strong>
            <span>FLVX-style control panel</span>
          </div>
        </div>

        <nav className="nav-list">
          {navItems.map((item) => (
            <NavLink key={item.path} to={item.path} className={({ isActive }) => (isActive ? "nav-link active" : "nav-link")}>
              {item.label}
            </NavLink>
          ))}
        </nav>

        <div className="sidebar-footer">
          <span>Backend API</span>
          <code>{api.defaults.baseURL}</code>
        </div>
      </aside>

      <main className="main-panel">
        <header className="topbar">
          <div>
            <p className="eyebrow">Project rebuild</p>
            <h1>RealmFlow</h1>
          </div>

          <div className="topbar-actions">
            <button className="ghost-button" type="button" onClick={toggleTheme}>
              {theme === "dark" ? "Light mode" : "Dark mode"}
            </button>
            <div className="user-chip">
              <span className="dot" />
              jack
            </div>
          </div>
        </header>

        <section className="content-frame">
          <Routes>
            <Route path="/" element={<Navigate replace to="/dashboard" />} />
            <Route path="/dashboard" element={<SectionPage title="Dashboard" description="Overview cards, traffic charts, and quick actions will live here." />} />
            <Route path="/forward" element={<SectionPage title="Forward" description="Forward CRUD, batch actions, import/export, and diagnosis will be implemented here." />} />
            <Route path="/tunnel" element={<SectionPage title="Tunnel" description="Tunnel lifecycle, chain routes, and traffic controls will be implemented here." />} />
            <Route path="/node" element={<SectionPage title="Node" description="Node lifecycle, install command generation, and monitoring status will live here." />} />
            <Route path="/monitor" element={<SectionPage title="Monitor" description="Dashboards and live telemetry views will be wired here." />} />
            <Route path="/limit" element={<SectionPage title="Limit" description="Traffic limit rules and related editors will be implemented here." />} />
            <Route path="/user" element={<SectionPage title="User" description="User CRUD, quotas, status control, and profile actions will live here." />} />
            <Route path="/group" element={<SectionPage title="Group" description="User and tunnel group management will be implemented here." />} />
            <Route path="/panel-sharing" element={<SectionPage title="Panel Sharing" description="Federation and panel-to-panel sharing flows will live here." />} />
            <Route path="/config" element={<SectionPage title="Config" description="Global panel settings, theme hooks, and runtime config editing will live here." />} />
          </Routes>
        </section>
      </main>
    </div>
  );
}

function SectionPage({ title, description }: { title: string; description: string }) {
  return (
    <article className="page-card">
      <p className="eyebrow">Module shell</p>
      <h2>{title}</h2>
      <p>{description}</p>
      <div className="page-grid">
        <div className="metric-card">
          <span>API</span>
          <strong>Ready for integration</strong>
        </div>
        <div className="metric-card">
          <span>UI</span>
          <strong>Placeholder scaffold</strong>
        </div>
        <div className="metric-card">
          <span>Status</span>
          <strong>Phase 1 bootstrap</strong>
        </div>
      </div>
    </article>
  );
}

export default function App() {
  return (
    <ThemeProvider>
      <Shell />
    </ThemeProvider>
  );
}
