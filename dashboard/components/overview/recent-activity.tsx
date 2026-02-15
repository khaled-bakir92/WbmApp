"use client";

import Link from "next/link";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { useLogs } from "@/hooks/use-logs";

function getLogLevel(line: string) {
  if (line.includes(" - ERROR - ")) return "error";
  if (line.includes(" - WARNING - ")) return "warning";
  return "info";
}

export function RecentActivity() {
  const { data, isLoading } = useLogs(5);

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Recent Activity</CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          {Array.from({ length: 5 }).map((_, i) => (
            <Skeleton key={i} className="h-4 w-full" />
          ))}
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle>Recent Activity</CardTitle>
        <Link
          href="/status"
          className="text-sm text-muted-foreground hover:underline"
        >
          View all logs
        </Link>
      </CardHeader>
      <CardContent>
        {!data || data.lines.length === 0 ? (
          <p className="text-sm text-muted-foreground">No recent activity</p>
        ) : (
          <div className="space-y-1.5">
            {data.lines.map((line, i) => {
              const level = getLogLevel(line);
              return (
                <p
                  key={i}
                  className={`text-xs font-mono truncate ${
                    level === "error"
                      ? "text-red-500"
                      : level === "warning"
                        ? "text-yellow-500"
                        : "text-muted-foreground"
                  }`}
                >
                  {line.trim()}
                </p>
              );
            })}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
