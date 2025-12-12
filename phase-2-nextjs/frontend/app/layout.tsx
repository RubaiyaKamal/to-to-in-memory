import type { Metadata } from "next";
import { Header } from "@/components/Header";
import { FloatingChatbot } from "@/components/FloatingChatbot";
import "./globals.css";

export const metadata: Metadata = {
    title: "Todo App",
    description: "A modern todo application with authentication",
};

export default function RootLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    return (
        <html lang="en">
            <body className="bg-gray-50 min-h-screen">
                <Header />
                <main className="container mx-auto px-4 py-8">
                    {children}
                </main>
                <FloatingChatbot />
            </body>
        </html>
    );
}
