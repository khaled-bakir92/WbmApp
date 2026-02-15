import { Sidebar } from "@/components/layout/sidebar";
import { MobileNav } from "@/components/layout/mobile-nav";
import { Header } from "@/components/layout/header";
import { logout } from "@/app/login/actions";

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex min-h-screen">
      <Sidebar onLogout={logout} />
      <div className="flex-1 md:ml-60">
        <MobileNav onLogout={logout} />
        <Header />
        <main className="p-4 md:p-6">{children}</main>
      </div>
    </div>
  );
}
