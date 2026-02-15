import { SignJWT, jwtVerify } from "jose";

const COOKIE_NAME = "admin-session";
const SECRET = new TextEncoder().encode(process.env.AUTH_SECRET);

export { COOKIE_NAME };

export function verifyCredentials(username: string, password: string): boolean {
  return (
    username === process.env.ADMIN_USERNAME &&
    password === process.env.ADMIN_PASSWORD
  );
}

export async function signToken(): Promise<string> {
  return new SignJWT({ role: "admin" })
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime("7d")
    .sign(SECRET);
}

export async function verifyToken(
  token: string
): Promise<{ role: string } | null> {
  try {
    const { payload } = await jwtVerify(token, SECRET);
    return payload as { role: string };
  } catch {
    return null;
  }
}
