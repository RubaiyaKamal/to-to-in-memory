"use client";

import { ReactNode } from "react";

interface ActionButtonProps {
    icon: ReactNode;
    title: string;
    description: string;
    count?: number;
    color: string;
    onClick: () => void;
    isActive?: boolean;
}

export function ActionButton({
    icon,
    title,
    description,
    count,
    color,
    onClick,
    isActive = false,
}: ActionButtonProps) {
    const colorClasses = {
        teal: "bg-[#B2E6D4] hover:bg-[#9DD9C3]",      // Pastel turquoise
        blue: "bg-[#C7CEEA] hover:bg-[#B3BCD9]",      // Lavender blue
        amber: "bg-[#FFE4B5] hover:bg-[#FFD89A]",     // Moccasin
        green: "bg-[#D5F4E6] hover:bg-[#BFE8D5]",     // Mint
        red: "bg-[#FFD3E1] hover:bg-[#FFBDCF]",       // Light rose
    };

    const borderClasses = {
        teal: "border-[#9DD9C3]",
        blue: "border-[#B3BCD9]",
        amber: "border-[#FFD89A]",
        green: "border-[#BFE8D5]",
        red: "border-[#FFBDCF]",
    };

    const textColorClasses = {
        teal: "text-teal-800",
        blue: "text-blue-800",
        amber: "text-amber-900",
        green: "text-green-800",
        red: "text-rose-800",
    };

    return (
        <button
            onClick={onClick}
            className={`
                relative p-6 rounded-xl shadow-lg transition-all duration-300 transform hover:scale-105 hover:shadow-2xl
                ${colorClasses[color as keyof typeof colorClasses]}
                ${textColorClasses[color as keyof typeof textColorClasses]}
                group overflow-hidden
                ${isActive ? `ring-4 ${borderClasses[color as keyof typeof borderClasses]} scale-105` : ""}
            `}
        >
            {/* Background Pattern */}
            <div className="absolute inset-0 opacity-10">
                <div className="absolute inset-0 bg-white transform rotate-12 scale-150"></div>
            </div>

            {/* Content */}
            <div className="relative z-10">
                <div className="flex items-start justify-between mb-3">
                    <div className="p-3 bg-white/40 rounded-lg backdrop-blur-sm">
                        {icon}
                    </div>
                    {count !== undefined && (
                        <div className="px-3 py-1 bg-white/50 rounded-full backdrop-blur-sm">
                            <span className="text-sm font-bold">{count}</span>
                        </div>
                    )}
                </div>

                <h3 className="text-xl font-bold mb-1">{title}</h3>
                <p className="text-sm opacity-90">{description}</p>
            </div>

            {/* Hover Effect */}
            <div className="absolute inset-0 bg-white/0 group-hover:bg-white/10 transition-all duration-300"></div>
        </button>
    );
}
