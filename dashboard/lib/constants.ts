import {
  LayoutDashboard,
  List,
  Activity,
  Play,
  Settings,
  User,
} from "lucide-react";

export const ADMIN_NAV_ITEMS = [
  { href: "/", label: "Overview", icon: LayoutDashboard },
  { href: "/listings", label: "Listings", icon: List },
  { href: "/status", label: "Status", icon: Activity },
  { href: "/control", label: "Control", icon: Play },
  { href: "/settings", label: "Settings", icon: Settings },
] as const;

export const NAV_ITEMS = ADMIN_NAV_ITEMS;

export const USER_NAV_ITEMS = [
  { href: "/user", label: "Overview", icon: LayoutDashboard },
  { href: "/user/listings", label: "Listings", icon: List },
  { href: "/user/profile", label: "Profile", icon: User },
] as const;

export const POLLING = {
  BOT_STATUS: 5000,
  STATS: 30000,
  WEEKLY_STATS: 60000,
  LOGS: 10000,
  LISTINGS: 30000,
} as const;

export const DEFAULT_INTERVAL = 900;
export const MIN_INTERVAL = 60;
export const MAX_INTERVAL = 86400;
