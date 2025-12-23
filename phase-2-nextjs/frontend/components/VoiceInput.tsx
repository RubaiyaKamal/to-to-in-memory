"use client";

import React, { useState, useEffect } from "react";
import { Mic, MicOff } from "lucide-react";

interface VoiceInputProps {
    onSpeechResult: (text: string) => void;
    disabled?: boolean;
}

export function VoiceInput({ onSpeechResult, disabled }: VoiceInputProps) {
    const [isListening, setIsListening] = useState(false);
    const [recognition, setRecognition] = useState<any>(null);

    useEffect(() => {
        // Initialize Speech Recognition
        const SpeechRecognition =
            (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;

        if (SpeechRecognition) {
            const recognitionInstance = new SpeechRecognition();
            recognitionInstance.continuous = false;
            recognitionInstance.interimResults = false;
            recognitionInstance.lang = "en-US"; // Hardcoded to English as per request

            recognitionInstance.onstart = () => {
                setIsListening(true);
            };

            recognitionInstance.onend = () => {
                setIsListening(false);
            };

            recognitionInstance.onerror = (event: any) => {
                console.error("Speech recognition error", event.error);
                setIsListening(false);
                if (event.error === "not-allowed") {
                    alert("Microphone access denied. Please allow microphone permissions.");
                } else if (event.error !== "no-speech") {
                    alert(`Voice error: ${event.error}`);
                }
            };

            recognitionInstance.onresult = (event: any) => {
                const transcript = event.results[0][0].transcript;
                if (transcript) {
                    onSpeechResult(transcript);
                }
            };

            setRecognition(recognitionInstance);
        }
    }, [onSpeechResult]);

    const toggleListening = () => {
        if (!recognition) {
            alert("Your browser does not support Voice Input. Try Chrome or Edge.");
            return;
        }

        if (isListening) {
            recognition.stop();
        } else {
            try {
                recognition.start();
            } catch (e) {
                console.error("Failed to start recognition:", e);
            }
        }
    };

    return (
        <button
            type="button"
            onClick={toggleListening}
            disabled={disabled || !recognition}
            className={`w-10 h-10 rounded-full flex items-center justify-center transition-all duration-300 shadow-sm relative ${isListening
                    ? "bg-red-500 text-white animate-pulse shadow-md ring-2 ring-red-200"
                    : "bg-teal-50 text-teal-600 hover:bg-teal-100 border border-teal-100"
                } ${disabled || !recognition ? "opacity-30 cursor-not-allowed shadow-none" : ""}`}
            title={isListening ? "Listening... Click to stop" : "Click to speak (English)"}
        >
            {isListening ? (
                <div className="relative">
                    <Mic className="w-4 h-4" />
                    <span className="absolute -top-1 -right-1 flex h-2 w-2">
                        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-white opacity-75"></span>
                        <span className="relative inline-flex rounded-full h-2 w-2 bg-white"></span>
                    </span>
                </div>
            ) : (
                <Mic className="w-4 h-4" />
            )}
        </button>
    );
}
