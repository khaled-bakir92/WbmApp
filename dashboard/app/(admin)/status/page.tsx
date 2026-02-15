"use client";

import { HealthCard } from "@/components/status/health-card";
import { LogViewer } from "@/components/status/log-viewer";

export default function StatusPage() {
  return (
    <div className="space-y-6">
      <div className="grid gap-6 lg:grid-cols-3">
        <div className="lg:col-span-1">
          <HealthCard />
        </div>
        <div className="lg:col-span-2">
          <LogViewer />
        </div>
      </div>
    </div>
  );
}
