// Keyword Research Tool for DeskGame.xyz
// This script helps analyze and suggest keywords for the website

class KeywordAnalyzer {
    constructor() {
        this.currentKeywords = {
            homepage: [
                'wood block jam',
                'puzzle game',
                'online game',
                'free game',
                'brain game',
                'block puzzle',
                'strategy game'
            ],
            news: [
                'game updates',
                'events',
                'tips',
                'Wood Block Jam',
                'DeskGame'
            ]
        };
        
        this.recommendedKeywords = {
            primary: [
                'wood block jam',
                'puzzle games online',
                'free puzzle games',
                'block puzzle game',
                'online puzzle games',
                'brain training games'
            ],
            longTail: [
                'free online puzzle games no download',
                'wood block jam game play online',
                'brain training puzzle games',
                'strategy puzzle games free',
                'block puzzle games for free',
                'online brain games no registration'
            ],
            related: [
                'mind games',
                'logic puzzles',
                'brain teasers',
                'casual games',
                'puzzle solving games',
                'intellectual games'
            ],
            brand: [
                'deskgame.xyz',
                'deskgame puzzle',
                'deskgame online',
                'deskgame free games'
            ]
        };
    }

    // Analyze current keyword density
    analyzeKeywordDensity(content, keywords) {
        const results = {};
        const words = content.toLowerCase().split(/\s+/);
        const totalWords = words.length;
        
        keywords.forEach(keyword => {
            const keywordWords = keyword.toLowerCase().split(/\s+/);
            let count = 0;
            
            for (let i = 0; i <= words.length - keywordWords.length; i++) {
                let match = true;
                for (let j = 0; j < keywordWords.length; j++) {
                    if (words[i + j] !== keywordWords[j]) {
                        match = false;
                        break;
                    }
                }
                if (match) count++;
            }
            
            const density = (count / totalWords) * 100;
            results[keyword] = {
                count: count,
                density: density.toFixed(2) + '%',
                status: density > 2 ? 'high' : density > 1 ? 'medium' : 'low'
            };
        });
        
        return results;
    }

    // Generate keyword suggestions based on current content
    generateSuggestions(baseKeywords) {
        const suggestions = [];
        
        baseKeywords.forEach(keyword => {
            // Add variations
            suggestions.push(keyword + ' online');
            suggestions.push('free ' + keyword);
            suggestions.push(keyword + ' game');
            suggestions.push('play ' + keyword);
            suggestions.push(keyword + ' no download');
        });
        
        return [...new Set(suggestions)]; // Remove duplicates
    }

    // Check keyword competition (simplified)
    checkCompetition(keyword) {
        // This is a simplified version - in reality, you'd use APIs
        const highCompetition = ['puzzle games', 'online games', 'free games'];
        const mediumCompetition = ['wood block jam', 'block puzzle', 'brain games'];
        
        if (highCompetition.includes(keyword)) {
            return { level: 'high', difficulty: 'difficult' };
        } else if (mediumCompetition.includes(keyword)) {
            return { level: 'medium', difficulty: 'moderate' };
        } else {
            return { level: 'low', difficulty: 'easy' };
        }
    }

    // Generate SEO recommendations
    generateSEORecommendations() {
        return {
            title: [
                'Include primary keyword in title',
                'Keep title under 60 characters',
                'Make title compelling and click-worthy'
            ],
            description: [
                'Include primary and secondary keywords',
                'Keep description under 160 characters',
                'Write compelling meta description'
            ],
            content: [
                'Use keywords naturally in content',
                'Include keywords in headings (H1, H2, H3)',
                'Add keywords to image alt tags',
                'Create internal links with keyword-rich anchor text'
            ],
            technical: [
                'Optimize page loading speed',
                'Ensure mobile responsiveness',
                'Add structured data markup',
                'Create XML sitemap'
            ]
        };
    }

    // Export keyword data
    exportKeywords() {
        const data = {
            current: this.currentKeywords,
            recommended: this.recommendedKeywords,
            timestamp: new Date().toISOString()
        };
        
        const dataStr = JSON.stringify(data, null, 2);
        const dataBlob = new Blob([dataStr], {type: 'application/json'});
        
        const link = document.createElement('a');
        link.href = URL.createObjectURL(dataBlob);
        link.download = `deskgame-keywords-${new Date().toISOString().split('T')[0]}.json`;
        link.click();
    }

    // Display keyword analysis
    displayAnalysis() {
        console.log('=== DeskGame.xyz Keyword Analysis ===');
        console.log('Current Keywords:', this.currentKeywords);
        console.log('Recommended Keywords:', this.recommendedKeywords);
        console.log('SEO Recommendations:', this.generateSEORecommendations());
    }
}

// Usage example
const keywordAnalyzer = new KeywordAnalyzer();

// Display analysis in console
keywordAnalyzer.displayAnalysis();

// Export functionality for browser
if (typeof window !== 'undefined') {
    window.keywordAnalyzer = keywordAnalyzer;
    console.log('Keyword analyzer available as window.keywordAnalyzer');
}
