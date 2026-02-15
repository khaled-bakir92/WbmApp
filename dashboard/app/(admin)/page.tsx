"use client";

import { KpiCards } from "@/components/overview/kpi-cards";
import { ApplicationsChart } from "@/components/overview/applications-chart";
import { RecentActivity } from "@/components/overview/recent-activity";

export default function OverviewPage() {
  return (
    <div className="space-y-6">
      <KpiCards />
      <div className="grid gap-6 lg:grid-cols-2">
        <ApplicationsChart />
        <RecentActivity />
      </div>
    </div>
  );
}
