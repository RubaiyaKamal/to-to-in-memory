import { useState, useEffect } from 'react';
import { Mic } from 'lucide-react';

interface VoiceInputProps {
    onSpeechResult: (text: string) => void;
}

export default function VoiceInput({ onSpeechResult }: VoiceInputProps) {
    const [isListening, setIsListening] = useState(false);
    const [recognition, setRecognition] = useState<any>(null);

    useEffect(() => {
        // Initialize Speech Recognition
        const SpeechRecognition = (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;

        if (SpeechRecognition) {
            const recognitionInstance = new SpeechRecognition();
            recognitionInstance.continuous = false;
            recognitionInstance.interimResults = false;

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
                    // Ignore no-speech, just stop
                } else if (event.error === 'network') {
                    alert('Voice input network error. This language model might not be available offline or in your region.');
                } else {
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
        } else {
            console.warn('Web Speech API not supported in this browser.');
        }
    }, [onSpeechResult]); // Re-init not needed usually, but logic depends on instance.

    const toggleListening = () => {
        if (!recognition) {
            alert('Your browser does not support Voice Input. Try Chrome or Edge.');
            return;
        }

        if (isListening) {
            recognition.stop();
        } else {
            // User requested to disable Urdu voice input due to network errors.
            // Always defaulting to English.
            recognition.lang = 'en-US';
            try {
                recognition.start();
            } catch (e) {
                console.error("Failed to start recognition:", e);
                // Sometimes legacy error if already started
            }
        }
    };

    return (
        <button
            type="button"
            onClick={toggleListening}
            className={`p-3.5 rounded-xl transition-all duration-300 flex items-center justify-center shadow-sm relative ${isListening
                ? 'bg-red-500 text-white animate-pulse shadow-md ring-2 ring-red-200'
                : 'bg-teal-50 text-teal-600 hover:bg-teal-100 border border-teal-100'
                } ${!recognition ? 'opacity-50 cursor-not-allowed' : ''}`}
            title={isListening ? 'Listening... Click to stop' : 'Click to speak'}
        >
            {isListening ? (
                <div className="relative">
                    <Mic className="w-5 h-5 animate-bounce" />
                    <span className="absolute -top-1 -right-1 flex h-2 w-2">
                        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-white opacity-75"></span>
                        <span className="relative inline-flex rounded-full h-2 w-2 bg-white"></span>
                    </span>
                </div>
            ) : (
                <Mic className="w-5 h-5" />
            )}
        </button>
    );
}
