"use client";

import { useQuery, keepPreviousData } from "@tanstack/react-query";
import { getListings } from "@/lib/api";

export function useListings(params: {
  page: number;
  per_page: number;
  search: string;
  status: string;
}) {
  return useQuery({
    queryKey: ["listings", params],
    queryFn: () => getListings(params),
    placeholderData: keepPreviousData,
  });
}
