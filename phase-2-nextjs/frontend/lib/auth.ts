/**
 * Simple authentication utilities for Phase II
 * Note: This is a simplified implementation. Better Auth will be integrated in a future iteration.
 */

export interface User {
    id: string;
    email: string;
    name?: string;
}

/**
 * Store JWT token
 */
export function setToken(token: string): void {
    if (typeof window !== "undefined") {
        localStorage.setItem("auth_token", token);
    }
}

/**
 * Get JWT token
 */
export function getToken(): string | null {
    if (typeof window !== "undefined") {
        return localStorage.getItem("auth_token");
    }
    return null;
}

/**
 * Remove JWT token
 */
export function removeToken(): void {
    if (typeof window !== "undefined") {
        localStorage.removeItem("auth_token");
        localStorage.removeItem("user");
    }
}

/**
 * Store user data
 */
export function setUser(user: User): void {
    if (typeof window !== "undefined") {
        localStorage.setItem("user", JSON.stringify(user));
    }
}

/**
 * Get user data
 */
export function getUser(): User | null {
    if (typeof window !== "undefined") {
        const userStr = localStorage.getItem("user");
        if (userStr) {
            try {
                return JSON.parse(userStr);
            } catch {
                return null;
            }
        }
    }
    return null;
}

/**
 * Check if user is authenticated
 */
export function isAuthenticated(): boolean {
    return getToken() !== null && getUser() !== null;
}

/**
 * Sign out user
 */
export function signOut(): void {
    removeToken();
    if (typeof window !== "undefined") {
        window.location.href = "/signin";
    }
}
