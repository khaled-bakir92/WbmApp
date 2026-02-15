"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { Activity, FileText, List, AlertTriangle } from "lucide-react";
import { useStats } from "@/hooks/use-stats";

export function KpiCards() {
  const { data: stats, isLoading, isError } = useStats();

  if (isLoading) {
    return (
      <div className="grid gap-4 grid-cols-2 lg:grid-cols-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <Card key={i}>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <Skeleton className="h-4 w-24" />
              <Skeleton className="h-4 w-4" />
            </CardHeader>
            <CardContent>
              <Skeleton className="h-7 w-16" />
            </CardContent>
          </Card>
        ))}
      </div>
    );
  }

  if (isError || !stats) {
    return (
      <div className="grid gap-4 grid-cols-2 lg:grid-cols-4">
        <Card className="col-span-full">
          <CardContent className="pt-6 text-center text-muted-foreground">
            Failed to load stats. Is the backend running?
          </CardContent>
        </Card>
      </div>
    );
  }

  const cards = [
    {
      title: "Bot Status",
      value: (
        <Badge variant={stats.bot_running ? "default" : "destructive"}>
          {stats.bot_running ? "Running" : "Stopped"}
        </Badge>
      ),
      icon: Activity,
    },
    {
      title: "Applications",
      value: stats.total_forms_submitted,
      icon: FileText,
    },
    {
      title: "Known Listings",
      value: stats.known_listings_count,
      icon: List,
    },
    {
      title: "Errors (24h)",
      value: stats.total_errors_24h,
      icon: AlertTriangle,
    },
  ];

  return (
    <div className="grid gap-4 grid-cols-2 lg:grid-cols-4">
      {cards.map((card) => (
        <Card key={card.title}>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              {card.title}
            </CardTitle>
            <card.icon className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{card.value}</div>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}
