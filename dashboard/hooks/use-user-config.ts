"use client";

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { getUserConfig, updateUserConfig } from "@/lib/api";
import { toast } from "sonner";
import type { UserConfigUpdate } from "@/lib/types";

export function useUserConfig() {
  const queryClient = useQueryClient();

  const query = useQuery({
    queryKey: ["user-config"],
    queryFn: getUserConfig,
  });

  const mutation = useMutation({
    mutationFn: (data: UserConfigUpdate) => updateUserConfig(data),
    onSuccess: () => {
      toast.success("Settings saved");
      queryClient.invalidateQueries({ queryKey: ["user-config"] });
    },
    onError: (err: Error) => {
      toast.error(err.message);
    },
  });

  return { query, mutation };
}
