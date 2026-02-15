"use client";

import { KpiCards } from "@/components/overview/kpi-cards";
import { ApplicationsChart } from "@/components/overview/applications-chart";

export default function UserOverviewPage() {
  return (
    <div className="space-y-6">
      <KpiCards />
      <ApplicationsChart />
    </div>
  );
}
