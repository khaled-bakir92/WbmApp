import { NextRequest, NextResponse } from "next/server";

const API_URL = process.env.API_URL || "http://localhost:8000";
const API_TOKEN = process.env.API_TOKEN || "";

async function proxyRequest(req: NextRequest, params: Promise<{ path: string[] }>) {
  const { path } = await params;
  const pathStr = path.join("/");
  const target = `${API_URL}/api/monitor/${pathStr}`;
  const url = new URL(target);

  req.nextUrl.searchParams.forEach((v, k) => url.searchParams.set(k, v));

  const headers: HeadersInit = {
    Authorization: `Bearer ${API_TOKEN}`,
  };

  const contentType = req.headers.get("content-type");
  if (contentType) headers["Content-Type"] = contentType;

  const res = await fetch(url.toString(), {
    method: req.method,
    headers,
    body: ["POST", "PUT", "PATCH"].includes(req.method) ? await req.text() : undefined,
  });

  // Handle binary responses (screenshots)
  if (pathStr.startsWith("screenshots/") && pathStr !== "screenshots") {
    const contentType = res.headers.get("content-type");
    if (contentType?.startsWith("image/")) {
      const buffer = await res.arrayBuffer();
      return new NextResponse(buffer, {
        status: res.status,
        headers: { "Content-Type": contentType },
      });
    }
  }

  const data = await res.json();
  return NextResponse.json(data, { status: res.status });
}

export async function GET(req: NextRequest, ctx: { params: Promise<{ path: string[] }> }) {
  return proxyRequest(req, ctx.params);
}

export async function POST(req: NextRequest, ctx: { params: Promise<{ path: string[] }> }) {
  return proxyRequest(req, ctx.params);
}

export async function PUT(req: NextRequest, ctx: { params: Promise<{ path: string[] }> }) {
  return proxyRequest(req, ctx.params);
}

export async function DELETE(req: NextRequest, ctx: { params: Promise<{ path: string[] }> }) {
  return proxyRequest(req, ctx.params);
}
