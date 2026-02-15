"use client";

import { useState, useEffect, useCallback } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { useQueryClient } from "@tanstack/react-query";
import { useListings } from "@/hooks/use-listings";
import { clearKnownListings } from "@/lib/api";
import { ListingsFilters } from "@/components/listings/listings-filters";
import { ListingsTable } from "@/components/listings/listings-table";
import { ListingsPagination } from "@/components/listings/listings-pagination";
import { Button } from "@/components/ui/button";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { Trash2 } from "lucide-react";

export function ListingsContent({
  showClearButton = true,
  basePath = "/listings",
}: {
  showClearButton?: boolean;
  basePath?: string;
}) {
  const router = useRouter();
  const searchParams = useSearchParams();

  const [search, setSearch] = useState(searchParams.get("search") || "");
  const [debouncedSearch, setDebouncedSearch] = useState(search);
  const [status, setStatus] = useState(searchParams.get("status") || "");
  const [page, setPage] = useState(Number(searchParams.get("page")) || 1);
  const [perPage, setPerPage] = useState(
    Number(searchParams.get("per_page")) || 20
  );

  // Debounce search
  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedSearch(search);
      setPage(1);
    }, 300);
    return () => clearTimeout(timer);
  }, [search]);

  // Sync URL
  const syncUrl = useCallback(() => {
    const params = new URLSearchParams();
    if (debouncedSearch) params.set("search", debouncedSearch);
    if (status) params.set("status", status);
    if (page > 1) params.set("page", String(page));
    if (perPage !== 20) params.set("per_page", String(perPage));
    const qs = params.toString();
    router.replace(qs ? `${basePath}?${qs}` : basePath, { scroll: false });
  }, [debouncedSearch, status, page, perPage, router, basePath]);

  useEffect(() => {
    syncUrl();
  }, [syncUrl]);

  const queryClient = useQueryClient();
  const [clearing, setClearing] = useState(false);

  const handleClearKnownListings = async () => {
    setClearing(true);
    try {
      await clearKnownListings();
      queryClient.invalidateQueries({ queryKey: ["listings"] });
      queryClient.invalidateQueries({ queryKey: ["bot-stats"] });
    } finally {
      setClearing(false);
    }
  };

  const { data, isLoading } = useListings({
    page,
    per_page: perPage,
    search: debouncedSearch,
    status,
  });

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <ListingsFilters
          search={search}
          onSearchChange={setSearch}
          status={status}
          onStatusChange={(v) => {
            setStatus(v);
            setPage(1);
          }}
          totalCount={data?.total_count ?? 0}
        />
        {showClearButton && (
          <AlertDialog>
            <AlertDialogTrigger asChild>
              <Button variant="destructive" size="sm">
                <Trash2 className="h-4 w-4 mr-2" />
                Known Listings leeren
              </Button>
            </AlertDialogTrigger>
            <AlertDialogContent>
              <AlertDialogHeader>
                <AlertDialogTitle>Known Listings leeren?</AlertDialogTitle>
                <AlertDialogDescription>
                  Alle bekannten Listings werden entfernt. Beim nächsten Bot-Check
                  werden alle aktuellen Angebote als neu erkannt. Bewerbungen bleiben erhalten.
                </AlertDialogDescription>
              </AlertDialogHeader>
              <AlertDialogFooter>
                <AlertDialogCancel>Abbrechen</AlertDialogCancel>
                <AlertDialogAction onClick={handleClearKnownListings} disabled={clearing}>
                  {clearing ? "Wird geleert..." : "Ja, leeren"}
                </AlertDialogAction>
              </AlertDialogFooter>
            </AlertDialogContent>
          </AlertDialog>
        )}
      </div>
      <ListingsTable listings={data?.listings ?? []} isLoading={isLoading} />
      {data && data.total_pages > 1 && (
        <ListingsPagination
          page={page}
          totalPages={data.total_pages}
          perPage={perPage}
          onPageChange={setPage}
          onPerPageChange={(v) => {
            setPerPage(v);
            setPage(1);
          }}
        />
      )}
    </div>
  );
}
