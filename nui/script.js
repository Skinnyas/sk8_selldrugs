class StreetCreditUI {
    constructor() {
        this.container = document.getElementById('streetCreditBar');
        this.panel = document.querySelector('.street-credit-panel');
        this.levelText = document.getElementById('levelText');
        this.pointsText = document.getElementById('pointsText');
        this.progressBar = document.getElementById('progressBar');
        this.multiplierText = document.getElementById('multiplierText');
        
        this.currentLevel = 1;
        this.currentPoints = 0;
        this.isVisible = false;
        this.hideTimeout = null;
        
        this.init();
    }
    
    init() {
        window.addEventListener('message', (event) => {
            const data = event.data;
            
            switch(data.action) {
                case 'showStreetCredit':
                    this.showStreetCredit(data.streetCreditData);
                    break;
                case 'hideStreetCredit':
                    this.hideStreetCredit();
                    break;
                case 'updateStreetCredit':
                    this.updateStreetCredit(data.streetCreditData, data.levelUp);
                    break;
                case 'showPoliceAlert':
                    policeAlertUI.showAlert(data.reportData);
                    break;
                case 'hidePoliceAlert':
                    policeAlertUI.hideAlert();
                    break;
            }
        });
    }
    
    showStreetCredit(data) {
        this.updateDisplay(data);
        
        if (this.hideTimeout) {
            clearTimeout(this.hideTimeout);
        }
        
        if (!this.isVisible) {
            this.container.classList.remove('hide');
            this.container.classList.add('show');
            this.isVisible = true;
        }
        
        this.hideTimeout = setTimeout(() => {
            this.hideStreetCredit();
        }, data.duration || 5000);
    }
    
    hideStreetCredit() {
        if (this.isVisible) {
            this.container.classList.remove('show');
            this.container.classList.add('hide');
            this.isVisible = false;
            
            setTimeout(() => {
                this.container.classList.remove('hide');
            }, 400);
        }
        
        if (this.hideTimeout) {
            clearTimeout(this.hideTimeout);
            this.hideTimeout = null;
        }
    }
    
    updateStreetCredit(data, levelUp = false) {
        this.updateDisplay(data);
        
        if (levelUp) {
            this.playLevelUpAnimation();
        }
        
        this.showStreetCredit(data);
    }
    
    updateDisplay(data) {
        const { level, levelName, currentXP, requiredXP, nextRequiredXP, multiplier } = data;
        
        this.currentLevel = level;
        this.currentPoints = currentXP;
        
        this.levelText.textContent = `Level ${level} - ${levelName}`;
        this.multiplierText.textContent = `×${multiplier.toFixed(1)}`;
        
        if (level >= 7) {
            this.pointsText.textContent = `${currentXP} XP - MAX LEVEL`;
            this.progressBar.style.width = '100%';
        } else {
            this.pointsText.textContent = `${currentXP} / ${nextRequiredXP} XP`;
            const progressPercentage = ((currentXP - requiredXP) / (nextRequiredXP - requiredXP)) * 100;
            this.progressBar.style.width = Math.max(0, Math.min(100, progressPercentage)) + '%';
        }
    }
    
    playLevelUpAnimation() {
        this.panel.classList.add('level-up-animation');
        
        setTimeout(() => {
            this.panel.classList.remove('level-up-animation');
        }, 1500);
    }
}

class PoliceAlertUI {
    constructor() {
        this.container = document.getElementById('policeAlert');
        this.panel = document.querySelector('.police-alert-panel');
        this.drugType = document.getElementById('alertDrugType');
        this.coords = document.getElementById('alertCoords');
        this.time = document.getElementById('alertTime');
        
        this.isVisible = false;
        this.hideTimeout = null;
    }
    
    showAlert(reportData) {
        this.updateDisplay(reportData);
        
        if (this.hideTimeout) {
            clearTimeout(this.hideTimeout);
        }
        
        if (!this.isVisible) {
            this.container.classList.remove('hide');
            this.container.classList.add('show');
            this.isVisible = true;
        }
        
        this.hideTimeout = setTimeout(() => {
            this.hideAlert();
        }, 10000);
    }
    
    hideAlert() {
        if (this.isVisible) {
            this.container.classList.remove('show');
            this.container.classList.add('hide');
            this.isVisible = false;
            
            setTimeout(() => {
                this.container.classList.remove('hide');
            }, 400);
        }
        
        if (this.hideTimeout) {
            clearTimeout(this.hideTimeout);
            this.hideTimeout = null;
        }
    }
    
    updateDisplay(reportData) {
        const drugLabels = {
            'cannabis': 'Tráva',
            'cocaine': 'Kokain', 
            'meth': 'Pervitin'
        };
        
        this.drugType.textContent = drugLabels[reportData.drugType] || reportData.drugType;
        this.coords.textContent = `${reportData.coords.x.toFixed(1)}, ${reportData.coords.y.toFixed(1)}`;
        
        const now = new Date();
        const timeString = now.toLocaleTimeString('cs-CZ', { 
            hour: '2-digit', 
            minute: '2-digit' 
        });
        this.time.textContent = timeString;
    }
}

const streetCreditUI = new StreetCreditUI();
const policeAlertUI = new PoliceAlertUI();

window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        streetCreditUI.hideStreetCredit();
        policeAlertUI.hideAlert();
    }
});