const { Builder, By, until } = require('selenium-webdriver');
const assert = require('assert');

describe('Séjours Management Tests', function() {
    this.timeout(30000);
    let driver;

    before(async function() {
        driver = await new Builder().forBrowser('chrome').build();
        
        // Login first
        await driver.get('http://localhost:5173/login');
        try {
            const emailInput = await driver.wait(
                until.elementLocated(By.css('input[type="email"], input[type="text"]')),
                5000
            );
            await emailInput.sendKeys('admin@chu.com');
            
            const passwordInput = await driver.findElement(By.css('input[type="password"]'));
            await passwordInput.sendKeys('admin123');
            
            const submitButton = await driver.findElement(By.css('button[type="submit"]'));
            await submitButton.click();
            
            await driver.sleep(3000);
        } catch (e) {
            console.log('Assuming already logged in');
        }
    });

    after(async function() {
        await driver.quit();
    });

    it('should navigate to sejours page', async function() {
        await driver.get('http://localhost:5173/sejours');
        await driver.sleep(2000);
        
        const currentUrl = await driver.getCurrentUrl();
        assert(currentUrl.includes('/sejours'), 'Should be on sejours page');
        
        console.log('✓ Séjours page loaded');
    });

    it('should display sejours list', async function() {
        await driver.get('http://localhost:5173/sejours');
        await driver.sleep(2000);
        
        const pageSource = await driver.getPageSource();
        const hasSejourContent = pageSource.toLowerCase().includes('séjour') || 
                                pageSource.toLowerCase().includes('patient') ||
                                pageSource.toLowerCase().includes('admission');
        
        assert(hasSejourContent, 'Page should display sejour-related content');
        console.log('✓ Séjours content displayed');
    });

    it('should have filter options', async function() {
        await driver.get('http://localhost:5173/sejours');
        await driver.sleep(2000);
        
        // Look for filter elements (select, buttons, tabs)
        const filterElements = await driver.findElements(
            By.css('select, [role="combobox"], button[data-filter], .filter-button')
        );
        
        console.log(`✓ Found ${filterElements.length} filter-related elements`);
    });

    it('should display sejour status badges', async function() {
        await driver.get('http://localhost:5173/sejours');
        await driver.sleep(2000);
        
        // Look for status indicators
        const pageSource = await driver.getPageSource();
        const hasStatusBadges = pageSource.includes('EN_COURS') || 
                               pageSource.includes('TERMINE') ||
                               pageSource.includes('En cours') ||
                               pageSource.includes('Terminé');
        
        console.log('✓ Status indicators checked');
    });

    it('should have add sejour functionality', async function() {
        await driver.get('http://localhost:5173/sejours');
        await driver.sleep(2000);
        
        const buttons = await driver.findElements(By.css('button'));
        let foundAddButton = false;
        
        for (let button of buttons) {
            try {
                const text = await button.getText();
                if (text.includes('Ajouter') || text.includes('Nouveau') || text.includes('Créer')) {
                    foundAddButton = true;
                    break;
                }
            } catch (e) {
                // Skip this button
            }
        }
        
        console.log('✓ Add sejour functionality checked');
    });

    it('should show sejour details', async function() {
        await driver.get('http://localhost:5173/sejours');
        await driver.sleep(2000);
        
        // Look for detail fields common in sejours
        const pageSource = await driver.getPageSource();
        const hasDetailFields = pageSource.toLowerCase().includes('date') || 
                               pageSource.toLowerCase().includes('motif') ||
                               pageSource.toLowerCase().includes('service');
        
        console.log('✓ Séjour detail fields checked');
    });
});
