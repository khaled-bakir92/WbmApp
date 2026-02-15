"use client";

import { useQuery } from "@tanstack/react-query";
import { getBotStats, getWeeklyStats } from "@/lib/api";
import { POLLING } from "@/lib/constants";

export function useStats() {
  return useQuery({
    queryKey: ["bot-stats"],
    queryFn: getBotStats,
    refetchInterval: POLLING.STATS,
  });
}

export function useWeeklyStats() {
  return useQuery({
    queryKey: ["weekly-stats"],
    queryFn: getWeeklyStats,
    refetchInterval: POLLING.WEEKLY_STATS,
  });
}
