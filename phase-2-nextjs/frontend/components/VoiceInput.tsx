"use client";

import React, { useState, useEffect } from 'react';
import { Mic } from 'lucide-react';

interface VoiceInputProps {
    onSpeechResult: (text: string) => void;
    // We strictly enforce English, so no language prop needed for now,
    // or we can keep it optional if we want future extensibility but ignore it.
    // Simplifying for now as per "English only" request.
    isDisabled?: boolean;
}

export default function VoiceInput({ onSpeechResult, isDisabled = false }: VoiceInputProps) {
    const [isListening, setIsListening] = useState(false);
    const [recognition, setRecognition] = useState<any>(null);

    useEffect(() => {
        // Initialize Speech Recognition
        const SpeechRecognition = (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;

        if (SpeechRecognition) {
            const recognitionInstance = new SpeechRecognition();
            recognitionInstance.continuous = false;
            recognitionInstance.interimResults = false;
            recognitionInstance.lang = 'en-US'; // Force English

            recognitionInstance.onstart = () => {
                setIsListening(true);
            };

            recognitionInstance.onend = () => {
                setIsListening(false);
            };

            recognitionInstance.onerror = (event: any) => {
                console.error('Speech recognition error', event.error);
                setIsListening(false);
                if (event.error === 'not-allowed') {
                    alert('Microphone access denied. Please allow microphone permissions.');
                } else if (event.error === 'no-speech') {
                    // Ignore no-speech
                } else {
                    // content blocked is common in some browsers if not https
                    console.warn(`Voice error: ${event.error}`);
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
            alert('Your browser does not support Voice Input. Try Chrome or Edge.');
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

    if (isDisabled) return null;

    return (
        <button
            type="button"
            onClick={toggleListening}
            className={`p-2 rounded-full transition-all duration-300 flex items-center justify-center relative ${isListening
                ? 'bg-red-500 text-white animate-pulse ring-2 ring-red-200'
                : 'text-gray-400 hover:text-teal-600 hover:bg-gray-100'
                } ${!recognition ? 'opacity-50 cursor-not-allowed' : ''}`}
            title={isListening ? 'Listening... Click to stop' : 'Click to speak'}
        >
            {isListening ? (
                <Mic className="w-5 h-5 animate-bounce" />
            ) : (
                <Mic className="w-5 h-5" />
            )}
        </button>
    );
}
