"use client";

import { usePathname } from "next/navigation";
import { NAV_ITEMS } from "@/lib/constants";
import type { LucideIcon } from "lucide-react";

type NavItem = { href: string; label: string; icon: LucideIcon };

export function Header({
  navItems = NAV_ITEMS as unknown as NavItem[],
}: {
  navItems?: NavItem[];
}) {
  const pathname = usePathname();
  const currentNav = navItems.find((item) => item.href === pathname);

  return (
    <header className="hidden md:flex h-14 items-center border-b px-6 bg-card">
      <h1 className="text-lg font-semibold">
        {currentNav?.label ?? "Dashboard"}
      </h1>
    </header>
  );
}
