# Add missing quick action buttons
$file = "c:\Users\Lap Zone\to-do-in-memory\phase-2-nextjs\frontend\components\FloatingChatbot.tsx"
$content = Get-Content $file -Raw -Encoding UTF8

# Find the Help button and add the new buttons before it
$helpButton = @'
                                <button
                                    onClick={() => handleQuickAction(language === "en" ? "Help" : "مدد")}
                                    className="text-xs px-3 py-1.5 bg-purple-100 text-purple-700 rounded-full hover:bg-purple-200 transition-colors"
                                >
                                    {language === "en" ? "❓ Help" : "❓ مدد"}
                                </button>
'@

$newButtons = @'
                                <button
                                    onClick={() => handleQuickAction(language === "en" ? "Complete a task" : "کام مکمل کریں")}
                                    className="text-xs px-3 py-1.5 bg-green-100 text-green-700 rounded-full hover:bg-green-200 transition-colors"
                                >
                                    {language === "en" ? "✅ Complete" : "✅ مکمل کریں"}
                                </button>
                                <button
                                    onClick={() => handleQuickAction(language === "en" ? "Update a task" : "کام اپ ڈیٹ کریں")}
                                    className="text-xs px-3 py-1.5 bg-yellow-100 text-yellow-700 rounded-full hover:bg-yellow-200 transition-colors"
                                >
                                    {language === "en" ? "✏️ Update" : "✏️ اپ ڈیٹ"}
                                </button>
                                <button
                                    onClick={() => handleQuickAction(language === "en" ? "Delete a task" : "کام حذف کریں")}
                                    className="text-xs px-3 py-1.5 bg-red-100 text-red-700 rounded-full hover:bg-red-200 transition-colors"
                                >
                                    {language === "en" ? "🗑️ Delete" : "🗑️ حذف کریں"}
                                </button>
                                <button
                                    onClick={() => handleQuickAction(language === "en" ? "Help" : "مدد")}
                                    className="text-xs px-3 py-1.5 bg-purple-100 text-purple-700 rounded-full hover:bg-purple-200 transition-colors"
                                >
                                    {language === "en" ? "❓ Help" : "❓ مدد"}
                                </button>
'@

$content = $content -replace [regex]::Escape($helpButton), $newButtons

Set-Content $file $content -Encoding UTF8 -NoNewline

Write-Host "Added 3 new quick action buttons: Complete, Update, Delete"
