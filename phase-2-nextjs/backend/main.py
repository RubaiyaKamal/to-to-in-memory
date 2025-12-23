"""FastAPI application entry point."""

import os

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from db import init_db
from routes import chat, health, tasks

# Load environment variables
load_dotenv()

# Create FastAPI app
app = FastAPI(
    title="Todo API",
    version="1.0.0",
    description="RESTful API for Todo application with JWT authentication",
)

# CORS configuration
cors_origins = os.getenv("CORS_ORIGINS", "http://localhost:3000").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router)
app.include_router(tasks.router, prefix="/api")
app.include_router(chat.router, prefix="/api")


@app.on_event("startup")
def on_startup() -> None:
    """Initialize database on startup."""
    init_db()


@app.get("/")
def root() -> dict[str, str]:
    """Root endpoint."""
    return {"message": "Todo API - See /docs for API documentation"}
