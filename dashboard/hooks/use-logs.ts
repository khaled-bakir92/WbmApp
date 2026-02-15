"use client";

import { useQuery } from "@tanstack/react-query";
import { getLogs } from "@/lib/api";
import { POLLING } from "@/lib/constants";

export function useLogs(lines: number = 100) {
  return useQuery({
    queryKey: ["logs", lines],
    queryFn: () => getLogs(lines),
    refetchInterval: POLLING.LOGS,
  });
}
