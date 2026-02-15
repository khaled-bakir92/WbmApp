"use client";

import { Sidebar } from "@/components/layout/sidebar";
import { MobileNav } from "@/components/layout/mobile-nav";
import { Header } from "@/components/layout/header";
import { USER_NAV_ITEMS } from "@/lib/constants";

const navItems = [...USER_NAV_ITEMS];

export default function UserLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex min-h-screen">
      <Sidebar navItems={navItems} homeHref="/user" />
      <div className="flex-1 md:ml-60">
        <MobileNav navItems={navItems} />
        <Header navItems={navItems} />
        <main className="p-4 md:p-6">{children}</main>
      </div>
    </div>
  );
}
