import { NavLink } from "react-router-dom";

const links = [
  ["/dashboard", "Dashboard"],
  ["/forward", "Forward"],
  ["/tunnel", "Tunnel"],
  ["/node", "Node"],
  ["/monitor", "Monitor"],
  ["/limit", "Limit"],
  ["/user", "User"],
  ["/group", "Group"],
  ["/panel-sharing", "Panel Sharing"],
  ["/config", "Config"],
];

export function AdminLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="admin-layout">
      <aside className="admin-sidebar">
        <div className="brand compact">
          <div className="brand-mark">RF</div>
          <div>
            <strong>RealmFlow</strong>
            <span>Admin</span>
          </div>
        </div>
        <nav className="nav-list">
          {links.map(([to, label]) => (
            <NavLink key={to} to={to} className={({ isActive }) => (isActive ? "nav-link active" : "nav-link")}>
              {label}
            </NavLink>
          ))}
        </nav>
      </aside>
      <div className="admin-content">{children}</div>
    </div>
  );
}

