"use client";

import { useState, useEffect } from "react";
import { usePathname } from "next/navigation";
import Link from "next/link";
import { signOut, getUser, User } from "@/lib/auth";

export function Header() {
    const [mounted, setMounted] = useState(false);
    const [user, setUser] = useState<User | null>(null);
    const pathname = usePathname();

    useEffect(() => {
        setMounted(true);
        setUser(getUser());
    }, []);

    const handleSignOut = () => {
        if (confirm("Are you sure you want to sign out?")) {
            signOut();
        }
    };

    return (
        <header className="navbar-gradient text-white shadow-lg">
            <div className="container mx-auto px-4 py-4">
                <div className="flex justify-between items-center">
                    {/* Logo Section */}
                    <div className="flex items-center gap-3">
                        <div className="bg-white/10 backdrop-blur-sm p-2 rounded-lg">
                            <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
                            </svg>
                        </div>
                        <div>
                            <h1 className="text-2xl font-bold">Todo App</h1>
                            <p className="text-xs text-white/80">Stay Organized</p>
                        </div>
                    </div>

                    {/* Navigation Links */}
                    {mounted && user && (
                        <nav className="flex items-center gap-2">
                            <Link
                                href="/tasks"
                                className={`px-4 py-2 rounded-lg transition-all duration-200 ${
                                    pathname === "/tasks"
                                        ? "bg-white text-[#0D9488] font-semibold"
                                        : "bg-white/10 hover:bg-white/20 text-white"
                                }`}
                            >
                                Tasks
                            </Link>
                            <Link
                                href="/history"
                                className={`px-4 py-2 rounded-lg transition-all duration-200 ${
                                    pathname === "/history"
                                        ? "bg-white text-[#0D9488] font-semibold"
                                        : "bg-white/10 hover:bg-white/20 text-white"
                                }`}
                            >
                                History
                            </Link>
                        </nav>
                    )}

                    {/* User Section */}
                    {mounted && user && (
                        <div className="flex items-center gap-4">
                            <div className="text-right hidden sm:block">
                                <p className="text-sm font-medium">{user.email}</p>
                                <p className="text-xs text-white/70">Signed in</p>
                            </div>
                            <button
                                onClick={handleSignOut}
                                className="bg-white/20 hover:bg-white/30 backdrop-blur-sm text-white text-sm px-4 py-2 rounded-lg transition-all duration-200"
                            >
                                Sign Out
                            </button>
                        </div>
                    )}
                </div>
            </div>
        </header>
    );
}
