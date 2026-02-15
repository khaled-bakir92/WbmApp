"use client";

import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  CardDescription,
} from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import { useWeeklyStats } from "@/hooks/use-stats";
import { format, parseISO } from "date-fns";

export function ApplicationsChart() {
  const { data, isLoading, isError } = useWeeklyStats();

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Applications (7 days)</CardTitle>
        </CardHeader>
        <CardContent>
          <Skeleton className="h-[250px] w-full" />
        </CardContent>
      </Card>
    );
  }

  if (isError || !data) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Applications (7 days)</CardTitle>
        </CardHeader>
        <CardContent className="text-center text-muted-foreground py-12">
          Failed to load chart data
        </CardContent>
      </Card>
    );
  }

  const chartData = data.days.map((d) => ({
    date: format(parseISO(d.date), "EEE"),
    fullDate: d.date,
    count: d.count,
  }));

  return (
    <Card>
      <CardHeader>
        <CardTitle>Applications (7 days)</CardTitle>
        <CardDescription>
          {data.total} total application{data.total !== 1 ? "s" : ""} this week
        </CardDescription>
      </CardHeader>
      <CardContent className="min-w-0">
        {data.total === 0 ? (
          <div className="flex items-center justify-center h-[250px] text-muted-foreground">
            No applications in the last 7 days
          </div>
        ) : (
          <ResponsiveContainer width="100%" height={250}>
            <BarChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" className="stroke-border" />
              <XAxis dataKey="date" className="text-xs" />
              <YAxis allowDecimals={false} className="text-xs" />
              <Tooltip
                contentStyle={{
                  backgroundColor: "hsl(var(--card))",
                  border: "1px solid hsl(var(--border))",
                  borderRadius: "var(--radius)",
                }}
                labelFormatter={(_, payload) => {
                  if (payload?.[0]?.payload?.fullDate) {
                    return format(
                      parseISO(payload[0].payload.fullDate),
                      "MMM d, yyyy"
                    );
                  }
                  return "";
                }}
              />
              <Bar
                dataKey="count"
                fill="hsl(var(--primary))"
                radius={[4, 4, 0, 0]}
              />
            </BarChart>
          </ResponsiveContainer>
        )}
      </CardContent>
    </Card>
  );
}
