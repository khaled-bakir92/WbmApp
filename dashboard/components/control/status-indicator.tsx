"use client";

import { cn } from "@/lib/utils";
import { useBotStatus } from "@/hooks/use-bot-status";

export function StatusIndicator() {
  const { data: status } = useBotStatus();
  const running = status?.running ?? false;

  return (
    <div className="flex flex-col items-center gap-4 py-8">
      <div className="relative">
        <div
          className={cn(
            "h-16 w-16 rounded-full",
            running ? "bg-green-500" : "bg-red-500"
          )}
        />
        {running && (
          <div className="absolute inset-0 h-16 w-16 rounded-full bg-green-500 animate-ping opacity-30" />
        )}
      </div>
      <p className="text-xl font-semibold">
        Bot is {running ? "Running" : "Stopped"}
      </p>
    </div>
  );
}
