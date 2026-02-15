// TypeScript interfaces mirroring FastAPI Pydantic models

export interface BotStatusResponse {
  running: boolean;
  pid: number | null;
  start_time: string | null;
  uptime_seconds: number | null;
  interval: number | null;
  gui_mode: boolean | null;
  cpu_percent: number | null;
  memory_mb: number | null;
}

export interface BotActionResponse {
  success: boolean;
  message: string;
  pid: number | null;
}

export interface BotStartRequest {
  interval: number;
  gui: boolean;
}

export interface BotStats {
  known_listings_count: number;
  applied_listings_count: number;
  last_check_time: string | null;
  last_listing_found: string | null;
  total_forms_submitted: number;
  total_errors_24h: number;
  bot_running: boolean;
  total_listings_last_check: number;
  filtered_listings_last_check: number;
}

export interface DailyApplicationCount {
  date: string;
  count: number;
}

export interface WeeklyStatsResponse {
  days: DailyApplicationCount[];
  total: number;
}

export interface LogsResponse {
  lines: string[];
  total_lines: number;
  file_size_bytes: number;
}

export interface FilterConfig {
  max_warmmiete: number;
  min_zimmer: number;
  wbs_required: boolean | null;
  excluded_areas: string[];
}

export interface UserData {
  anrede: string;
  name: string;
  vorname: string;
  strasse: string;
  plz: string;
  ort: string;
  email: string;
  telefon: string;
}

export interface NotificationEmail {
  sender: string;
  recipient: string;
  password: string;
  smtp_server: string;
  smtp_port: number;
}

export interface UserConfigResponse {
  user_data: UserData;
  notification_email: {
    sender: string;
    recipient: string;
    password: string;
    smtp_server: string;
    smtp_port: number;
  };
}

export interface UserConfigUpdate {
  user_data?: UserData;
  notification_email?: NotificationEmail;
}

export interface AppliedListing {
  id: string | null;
  titel: string;
  adresse: string;
  area: string;
  warmmiete: string;
  zimmer: string;
  has_wbs: boolean;
  url: string;
  applied_at: string | null;
  verification_status: string | null;
}

export interface PaginatedListingsResponse {
  listings: AppliedListing[];
  total_count: number;
  page: number;
  per_page: number;
  total_pages: number;
}
