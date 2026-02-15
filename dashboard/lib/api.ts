// Client-side fetch functions — calls the local Next.js proxy (no token exposed)

import type {
  BotStatusResponse,
  BotActionResponse,
  BotStartRequest,
  BotStats,
  WeeklyStatsResponse,
  LogsResponse,
  FilterConfig,
  UserConfigResponse,
  UserConfigUpdate,
  PaginatedListingsResponse,
} from "./types";

async function fetchApi<T>(url: string, options?: RequestInit): Promise<T> {
  const res = await fetch(url, options);
  if (!res.ok) {
    const body = await res.json().catch(() => ({ detail: res.statusText }));
    throw new Error(body.detail || `API error: ${res.status}`);
  }
  return res.json();
}

// Bot lifecycle
export const getBotStatus = () =>
  fetchApi<BotStatusResponse>("/api/bot/status");

export const startBot = (data: BotStartRequest) =>
  fetchApi<BotActionResponse>("/api/bot/start", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });

export const stopBot = () =>
  fetchApi<BotActionResponse>("/api/bot/stop", { method: "POST" });

export const restartBot = (data: BotStartRequest) =>
  fetchApi<BotActionResponse>("/api/bot/restart", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });

// Monitoring
export const getBotStats = () =>
  fetchApi<BotStats>("/api/monitor/stats");

export const getWeeklyStats = () =>
  fetchApi<WeeklyStatsResponse>("/api/monitor/stats/weekly");

export const getLogs = (lines: number = 100) =>
  fetchApi<LogsResponse>(`/api/monitor/logs?lines=${lines}`);

export const getListings = (params: {
  page?: number;
  per_page?: number;
  search?: string;
  status?: string;
}) => {
  const searchParams = new URLSearchParams();
  if (params.page) searchParams.set("page", String(params.page));
  if (params.per_page) searchParams.set("per_page", String(params.per_page));
  if (params.search) searchParams.set("search", params.search);
  if (params.status) searchParams.set("status", params.status);
  return fetchApi<PaginatedListingsResponse>(
    `/api/monitor/listings?${searchParams.toString()}`
  );
};

export const clearKnownListings = () =>
  fetchApi<{ success: boolean; message: string }>("/api/monitor/known-listings", {
    method: "DELETE",
  });

// Configuration
export const getFilterConfig = () =>
  fetchApi<FilterConfig>("/api/config/filter");

export const updateFilterConfig = (data: FilterConfig) =>
  fetchApi<FilterConfig>("/api/config/filter", {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });

export const getUserConfig = () =>
  fetchApi<UserConfigResponse>("/api/config/user");

export const updateUserConfig = (data: UserConfigUpdate) =>
  fetchApi<UserConfigResponse>("/api/config/user", {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });

// Health
export const getHealth = () =>
  fetchApi<{ status: string }>("/api/health");
