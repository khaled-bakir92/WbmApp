"use client";

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { format, parseISO } from "date-fns";
import type { AppliedListing } from "@/lib/types";

interface ListingsTableProps {
  listings: AppliedListing[];
  isLoading: boolean;
}

export function ListingsTable({ listings, isLoading }: ListingsTableProps) {
  if (isLoading) {
    return (
      <div className="rounded-md border overflow-x-auto">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Title</TableHead>
              <TableHead>Address</TableHead>
              <TableHead>Area</TableHead>
              <TableHead>Rent</TableHead>
              <TableHead>Rooms</TableHead>
              <TableHead>WBS</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Applied</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {Array.from({ length: 5 }).map((_, i) => (
              <TableRow key={i}>
                {Array.from({ length: 8 }).map((_, j) => (
                  <TableCell key={j}>
                    <Skeleton className="h-4 w-20" />
                  </TableCell>
                ))}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    );
  }

  if (listings.length === 0) {
    return (
      <div className="rounded-md border p-8 text-center text-muted-foreground">
        No listings match your search
      </div>
    );
  }

  return (
    <div className="rounded-md border overflow-x-auto">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Title</TableHead>
            <TableHead className="hidden sm:table-cell">Address</TableHead>
            <TableHead className="hidden md:table-cell">Area</TableHead>
            <TableHead>Rent</TableHead>
            <TableHead className="hidden sm:table-cell">Rooms</TableHead>
            <TableHead className="hidden lg:table-cell">WBS</TableHead>
            <TableHead>Status</TableHead>
            <TableHead className="hidden md:table-cell">Applied</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {listings.map((listing, i) => (
            <TableRow key={listing.id || i}>
              <TableCell className="font-medium max-w-[200px] truncate">
                {listing.url ? (
                  <a
                    href={listing.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="hover:underline"
                  >
                    {listing.titel}
                  </a>
                ) : (
                  listing.titel
                )}
              </TableCell>
              <TableCell className="hidden sm:table-cell max-w-[150px] truncate">
                {listing.adresse}
              </TableCell>
              <TableCell className="hidden md:table-cell">
                {listing.area}
              </TableCell>
              <TableCell>{listing.warmmiete} &euro;</TableCell>
              <TableCell className="hidden sm:table-cell">
                {listing.zimmer}
              </TableCell>
              <TableCell className="hidden lg:table-cell">
                {listing.has_wbs ? (
                  <Badge variant="outline">WBS</Badge>
                ) : (
                  <span className="text-muted-foreground">-</span>
                )}
              </TableCell>
              <TableCell>
                <Badge
                  variant={
                    listing.verification_status === "verified"
                      ? "default"
                      : listing.verification_status === "unverified"
                        ? "outline"
                        : "secondary"
                  }
                >
                  {listing.verification_status === "verified"
                    ? "Applied"
                    : listing.verification_status === "unverified"
                      ? "Not Applied"
                      : listing.verification_status || "unknown"}
                </Badge>
              </TableCell>
              <TableCell className="hidden md:table-cell whitespace-nowrap">
                {listing.applied_at
                  ? format(parseISO(listing.applied_at), "MMM d, HH:mm")
                  : "-"}
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
