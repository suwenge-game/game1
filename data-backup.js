// Data Backup and Export System for Content Management
// This script helps backup and restore content data

class DataManager {
    constructor() {
        this.storageKey = 'deskgame_content';
    }

    // Export all content to JSON
    exportData() {
        const data = this.getAllContent();
        const dataStr = JSON.stringify(data, null, 2);
        const dataBlob = new Blob([dataStr], {type: 'application/json'});
        
        const link = document.createElement('a');
        link.href = URL.createObjectURL(dataBlob);
        link.download = `deskgame-content-backup-${new Date().toISOString().split('T')[0]}.json`;
        link.click();
        
        return data.length;
    }

    // Import content from JSON file
    importData(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = (e) => {
                try {
                    const data = JSON.parse(e.target.result);
                    if (Array.isArray(data)) {
                        localStorage.setItem(this.storageKey, JSON.stringify(data));
                        resolve(data.length);
                    } else {
                        reject('Invalid data format');
                    }
                } catch (error) {
                    reject('Invalid JSON file');
                }
            };
            reader.readAsText(file);
        });
    }

    // Get all content
    getAllContent() {
        const stored = localStorage.getItem(this.storageKey);
        return stored ? JSON.parse(stored) : [];
    }

    // Create backup reminder
    createBackupReminder() {
        const lastBackup = localStorage.getItem('last_backup_date');
        const today = new Date().toDateString();
        
        if (lastBackup !== today) {
            this.showBackupNotification();
        }
    }

    // Show backup notification
    showBackupNotification() {
        const notification = document.createElement('div');
        notification.className = 'fixed top-4 right-4 bg-blue-500 text-white p-4 rounded-lg shadow-lg z-50 max-w-sm';
        notification.innerHTML = `
            <div class="flex justify-between items-start">
                <div>
                    <h4 class="font-semibold mb-2">💾 Backup Reminder</h4>
                    <p class="text-sm mb-3">Your content is stored locally. Consider backing up your data regularly.</p>
                    <button onclick="dataManager.exportData()" class="bg-white text-blue-500 px-3 py-1 rounded text-sm font-medium">
                        Export Data
                    </button>
                </div>
                <button onclick="this.parentElement.parentElement.remove()" class="text-white hover:text-gray-200 ml-2">
                    ×
                </button>
            </div>
        `;
        
        document.body.appendChild(notification);
        
        // Auto remove after 10 seconds
        setTimeout(() => {
            if (notification.parentElement) {
                notification.remove();
            }
        }, 10000);
    }

    // Save backup date
    saveBackupDate() {
        localStorage.setItem('last_backup_date', new Date().toDateString());
    }
}

// Initialize data manager
const dataManager = new DataManager();

// Add backup functionality to admin page
if (window.location.pathname.includes('admin')) {
    document.addEventListener('DOMContentLoaded', () => {
        // Add backup buttons to admin page
        const buttonContainer = document.querySelector('#contentList').parentElement;
        const backupSection = document.createElement('div');
        backupSection.className = 'mt-6 p-4 bg-yellow-50 border border-yellow-200 rounded-lg';
        backupSection.innerHTML = `
            <h3 class="text-lg font-semibold text-yellow-800 mb-2">📦 Data Management</h3>
            <p class="text-sm text-yellow-700 mb-3">
                Your content is stored in your browser's local storage. 
                To prevent data loss, regularly export your content.
            </p>
            <div class="flex space-x-3">
                <button onclick="dataManager.exportData()" 
                        class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded text-sm font-medium">
                    📤 Export Data
                </button>
                <label class="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded text-sm font-medium cursor-pointer">
                    📥 Import Data
                    <input type="file" accept=".json" onchange="dataManager.importData(this.files[0]).then(count => alert('Imported ' + count + ' items')).catch(err => alert('Import failed: ' + err))" class="hidden">
                </label>
            </div>
        `;
        buttonContainer.appendChild(backupSection);

        // Show backup reminder
        dataManager.createBackupReminder();
    });
}
