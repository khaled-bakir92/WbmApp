"use client";

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { getFilterConfig, updateFilterConfig } from "@/lib/api";
import { toast } from "sonner";
import type { FilterConfig } from "@/lib/types";

export function useFilterConfig() {
  const queryClient = useQueryClient();

  const query = useQuery({
    queryKey: ["filter-config"],
    queryFn: getFilterConfig,
    retry: (failureCount, error) => {
      // Don't retry on 404 (filter not yet created)
      if (error.message.includes("404")) return false;
      return failureCount < 2;
    },
  });

  const mutation = useMutation({
    mutationFn: (data: FilterConfig) => updateFilterConfig(data),
    onSuccess: () => {
      toast.success("Filter saved");
      queryClient.invalidateQueries({ queryKey: ["filter-config"] });
    },
    onError: (err: Error) => {
      toast.error(err.message);
    },
  });

  return { query, mutation };
}
