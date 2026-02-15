import { NextRequest, NextResponse } from "next/server";
import { verifyToken, COOKIE_NAME } from "@/lib/auth";

const ADMIN_PATHS = ["/", "/listings", "/status", "/control", "/settings"];

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const token = request.cookies.get(COOKIE_NAME)?.value;
  const isValid = token ? await verifyToken(token) : null;

  // Authenticated user visiting /login → redirect to dashboard
  if (pathname === "/login") {
    if (isValid) {
      return NextResponse.redirect(new URL("/", request.url));
    }
    return NextResponse.next();
  }

  // Admin paths without valid session → redirect to login
  if (ADMIN_PATHS.includes(pathname) && !isValid) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/", "/listings", "/status", "/control", "/settings", "/login"],
};
