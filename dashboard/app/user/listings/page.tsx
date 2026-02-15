"use client";

import { Suspense } from "react";
import { ListingsContent } from "@/components/listings/listings-content";
import { Skeleton } from "@/components/ui/skeleton";

export default function UserListingsPage() {
  return (
    <Suspense
      fallback={
        <div className="space-y-4">
          <Skeleton className="h-10 w-full max-w-sm" />
          <Skeleton className="h-[400px] w-full" />
        </div>
      }
    >
      <ListingsContent showClearButton={false} basePath="/user/listings" />
    </Suspense>
  );
}
