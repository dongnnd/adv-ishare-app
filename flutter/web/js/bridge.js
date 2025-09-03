// RustDesk Web Bridge
// This file provides JavaScript bridge functions for RustDesk web client

console.log('Loading RustDesk Web Bridge...');

// Main bridge object
window.rustdesk = {
    data: {},
    callbacks: {},
    
    // Main bridge functions
    getByName: function(name, arg) {
        console.log('getByName:', name, arg);
        
        switch(name) {
            case 'remember':
                return localStorage.getItem('remember') || 'false';
            case 'screen_info':
                return JSON.stringify({
                    width: window.screen.width,
                    height: window.screen.height,
                    scale: window.devicePixelRatio
                });
            case 'local_os':
                return navigator.platform.includes('Mac') ? 'Mac OS' : 
                       navigator.platform.includes('Win') ? 'Windows' : 'Linux';
            case 'version':
                return '1.4.1';
            case 'app_name':
                return 'NetControl IShare';
            case 'config':
                return localStorage.getItem('config_' + arg) || '';
            case 'option':
                return localStorage.getItem('option_' + arg) || '';
            case 'local_option':
                return localStorage.getItem('local_option_' + arg) || '';
            case 'peer':
                return localStorage.getItem('peer_' + arg) || '[]';
            case 'socks':
                return localStorage.getItem('socks') || '';
            case 'recent_sessions':
                return localStorage.getItem('recent_sessions') || '[]';
            default:
                console.warn('Unhandled getByName:', name, arg);
                return '';
        }
    },
    
    setByName: function(name, value) {
        console.log('setByName:', name, value);
        
        switch(name) {
            case 'remember':
                localStorage.setItem('remember', value);
                break;
            case 'config':
                const parts = value.split('|');
                if (parts.length >= 2) {
                    localStorage.setItem('config_' + parts[0], parts[1]);
                }
                break;
            case 'option':
                try {
                    const data = JSON.parse(value);
                    localStorage.setItem('option_' + data.name, data.value);
                } catch (e) {
                    console.warn('Invalid option JSON:', value);
                }
                break;
            case 'local_option':
                try {
                    const data = JSON.parse(value);
                    localStorage.setItem('local_option_' + data.name, data.value);
                } catch (e) {
                    console.warn('Invalid local_option JSON:', value);
                }
                break;
            case 'session_add_sync':
                console.log('Session add sync:', value);
                break;
            case 'session_start':
                console.log('Session start:', value);
                break;
            case 'send_chat':
                console.log('Send chat:', value);
                break;
            case 'save_ab':
                localStorage.setItem('address_book', value);
                break;
            case 'clear_ab':
                localStorage.removeItem('address_book');
                break;
            case 'load_ab':
                const ab = localStorage.getItem('address_book') || '[]';
                if (window.onLoadAbFinished) {
                    window.onLoadAbFinished(ab);
                }
                break;
            case 'save_group':
                localStorage.setItem('groups', value);
                break;
            case 'clear_group':
                localStorage.removeItem('groups');
                break;
            case 'load_group':
                const groups = localStorage.getItem('groups') || '[]';
                if (window.onLoadGroupFinished) {
                    window.onLoadGroupFinished(groups);
                }
                break;
            default:
                console.warn('Unhandled setByName:', name, value);
        }
    },
    
    // Callback management
    registerCallback: function(name, callback) {
        this.callbacks[name] = callback;
        console.log('Registered callback:', name);
    },
    
    callCallback: function(name, data) {
        if (this.callbacks[name]) {
            this.callbacks[name](data);
        } else {
            console.warn('Callback not found:', name);
        }
    },
    
    // Utility functions
    getScreenInfo: function() {
        return {
            width: window.screen.width,
            height: window.screen.height,
            availWidth: window.screen.availWidth,
            availHeight: window.screen.availHeight,
            colorDepth: window.screen.colorDepth,
            pixelDepth: window.screen.pixelDepth
        };
    },
    
    getBrowserInfo: function() {
        return {
            userAgent: navigator.userAgent,
            platform: navigator.platform,
            language: navigator.language,
            cookieEnabled: navigator.cookieEnabled,
            onLine: navigator.onLine
        };
    }
};

console.log('RustDesk Web Bridge loaded successfully');
