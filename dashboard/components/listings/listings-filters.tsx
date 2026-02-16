"use client";

import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Search } from "lucide-react";

interface ListingsFiltersProps {
  search: string;
  onSearchChange: (value: string) => void;
  status: string;
  onStatusChange: (value: string) => void;
  totalCount: number;
}

export function ListingsFilters({
  search,
  onSearchChange,
  status,
  onStatusChange,
  totalCount,
}: ListingsFiltersProps) {
  return (
    <div className="flex flex-col sm:flex-row gap-3 items-start sm:items-center">
      <div className="relative flex-1 w-full sm:max-w-sm">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
        <Input
          placeholder="Search title, address, area..."
          value={search}
          onChange={(e) => onSearchChange(e.target.value)}
          className="pl-9"
        />
      </div>
      <Select value={status || "all"} onValueChange={(v) => onStatusChange(v === "all" ? "" : v)}>
        <SelectTrigger className="w-full sm:w-[160px]">
          <SelectValue placeholder="All statuses" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">All statuses</SelectItem>
          <SelectItem value="verified">Applied</SelectItem>
          <SelectItem value="unverified">Not Applied</SelectItem>
        </SelectContent>
      </Select>
      <span className="text-sm text-muted-foreground whitespace-nowrap">
        {totalCount} result{totalCount !== 1 ? "s" : ""}
      </span>
    </div>
  );
}
