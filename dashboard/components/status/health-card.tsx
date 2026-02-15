"use client";

import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { Separator } from "@/components/ui/separator";
import { useBotStatus } from "@/hooks/use-bot-status";
import { useStats } from "@/hooks/use-stats";
import { format, parseISO } from "date-fns";

function formatUptime(seconds: number): string {
  const d = Math.floor(seconds / 86400);
  const h = Math.floor((seconds % 86400) / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const parts = [];
  if (d > 0) parts.push(`${d}d`);
  if (h > 0) parts.push(`${h}h`);
  parts.push(`${m}m`);
  return parts.join(" ");
}

function Row({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="flex items-center justify-between py-1.5">
      <span className="text-sm text-muted-foreground">{label}</span>
      <span className="text-sm font-medium">{children}</span>
    </div>
  );
}

export function HealthCard() {
  const { data: status, isLoading: statusLoading } = useBotStatus();
  const { data: stats, isLoading: statsLoading } = useStats();
  const isLoading = statusLoading || statsLoading;

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Bot Health</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          {Array.from({ length: 8 }).map((_, i) => (
            <Skeleton key={i} className="h-5 w-full" />
          ))}
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          Bot Health
          <Badge variant={status?.running ? "default" : "destructive"}>
            {status?.running ? "Running" : "Stopped"}
          </Badge>
        </CardTitle>
      </CardHeader>
      <CardContent>
        <Row label="PID">{status?.pid ?? "-"}</Row>
        <Row label="Uptime">
          {status?.uptime_seconds
            ? formatUptime(status.uptime_seconds)
            : "-"}
        </Row>
        <Row label="Interval">
          {status?.interval ? `${status.interval}s (${Math.round(status.interval / 60)}min)` : "-"}
        </Row>
        <Row label="GUI Mode">
          {status?.gui_mode != null ? (status.gui_mode ? "Yes" : "No") : "-"}
        </Row>

        <Separator className="my-2" />

        <Row label="CPU">
          {status?.cpu_percent != null ? (
            <div className="flex items-center gap-2">
              <div className="w-20 h-2 rounded-full bg-secondary overflow-hidden">
                <div
                  className="h-full bg-primary rounded-full"
                  style={{
                    width: `${Math.min(100, status.cpu_percent)}%`,
                  }}
                />
              </div>
              <span>{status.cpu_percent.toFixed(1)}%</span>
            </div>
          ) : (
            "-"
          )}
        </Row>
        <Row label="Memory">
          {status?.memory_mb != null
            ? `${status.memory_mb.toFixed(1)} MB`
            : "-"}
        </Row>

        <Separator className="my-2" />

        <Row label="Last Check">
          {stats?.last_check_time
            ? format(parseISO(stats.last_check_time), "MMM d, HH:mm")
            : "-"}
        </Row>
        <Row label="Last Listing Found">
          {stats?.last_listing_found
            ? format(parseISO(stats.last_listing_found), "MMM d, HH:mm")
            : "-"}
        </Row>
      </CardContent>
    </Card>
  );
}
