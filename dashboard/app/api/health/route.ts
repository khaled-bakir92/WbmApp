import { NextResponse } from "next/server";

const API_URL = process.env.API_URL || "http://localhost:8000";
const API_TOKEN = process.env.API_TOKEN || "";

export async function GET() {
  try {
    const res = await fetch(`${API_URL}/health`, {
      headers: { Authorization: `Bearer ${API_TOKEN}` },
    });
    const data = await res.json();
    return NextResponse.json(data, { status: res.status });
  } catch {
    return NextResponse.json(
      { status: "unhealthy", error: "Backend unreachable" },
      { status: 503 }
    );
  }
}
