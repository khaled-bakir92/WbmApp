"use client";

import { useQuery } from "@tanstack/react-query";
import { getBotStatus } from "@/lib/api";
import { POLLING } from "@/lib/constants";

export function useBotStatus() {
  return useQuery({
    queryKey: ["bot-status"],
    queryFn: getBotStatus,
    refetchInterval: POLLING.BOT_STATUS,
  });
}
