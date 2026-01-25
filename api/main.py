"""WBM Bot REST API - Main Entry Point"""
import secrets
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

from .config import get_settings
from .routers import lifecycle, configuration, monitoring


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan handler for startup/shutdown events."""
    settings = get_settings()

    # Ensure directories exist
    settings.ensure_directories()

    # Generate token if not set
    if not settings.api_token:
        token = settings.generate_token_if_missing()
        print(f"\n{'='*60}")
        print("API TOKEN GENERATED (save this, it won't be shown again):")
        print(f"  {token}")
        print(f"{'='*60}\n")

    yield

    # Shutdown: nothing special needed
    # The bot process will continue running independently


# Create FastAPI app
app = FastAPI(
    title="WBM Bot API",
    description="REST API for controlling the WBM Apartment Bot",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS - disabled by default for security
# Uncomment and configure if needed for web frontend
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["https://your-domain.com"],
#     allow_credentials=True,
#     allow_methods=["GET", "POST", "PUT", "DELETE"],
#     allow_headers=["Authorization", "Content-Type"],
# )


# Include routers
app.include_router(lifecycle.router)
app.include_router(configuration.router)
app.include_router(monitoring.router)


@app.get("/", tags=["Root"])
async def root():
    """API root endpoint - health check."""
    return {
        "name": "WBM Bot API",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs",
    }


@app.get("/health", tags=["Root"])
async def health_check():
    """Health check endpoint for monitoring systems."""
    return {"status": "healthy"}


# Global exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Handle uncaught exceptions."""
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": f"Internal server error: {str(exc)}"},
    )


if __name__ == "__main__":
    import uvicorn

    settings = get_settings()
    uvicorn.run(
        "api.main:app",
        host=settings.api_host,
        port=settings.api_port,
        reload=True,
    )
