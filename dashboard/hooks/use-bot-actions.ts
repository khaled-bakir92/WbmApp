"use client";

import { useMutation, useQueryClient } from "@tanstack/react-query";
import { startBot, stopBot, restartBot } from "@/lib/api";
import { toast } from "sonner";
import type { BotStartRequest } from "@/lib/types";

export function useBotActions() {
  const queryClient = useQueryClient();

  const invalidate = () => {
    queryClient.invalidateQueries({ queryKey: ["bot-status"] });
    queryClient.invalidateQueries({ queryKey: ["bot-stats"] });
  };

  const start = useMutation({
    mutationFn: (data: BotStartRequest) => startBot(data),
    onSuccess: (data) => {
      toast.success(data.message);
      invalidate();
    },
    onError: (err: Error) => {
      toast.error(err.message);
    },
  });

  const stop = useMutation({
    mutationFn: () => stopBot(),
    onSuccess: (data) => {
      toast.success(data.message);
      invalidate();
    },
    onError: (err: Error) => {
      toast.error(err.message);
    },
  });

  const restart = useMutation({
    mutationFn: (data: BotStartRequest) => restartBot(data),
    onSuccess: (data) => {
      toast.success(data.message);
      invalidate();
    },
    onError: (err: Error) => {
      toast.error(err.message);
    },
  });

  return { start, stop, restart };
}
