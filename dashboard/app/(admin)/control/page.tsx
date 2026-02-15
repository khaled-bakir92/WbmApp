"use client";

import { StatusIndicator } from "@/components/control/status-indicator";
import { BotControls } from "@/components/control/bot-controls";

export default function ControlPage() {
  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <StatusIndicator />
      <BotControls />
    </div>
  );
}
