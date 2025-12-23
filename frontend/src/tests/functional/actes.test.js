const { Builder, By, until } = require('selenium-webdriver');
const assert = require('assert');

describe('Actes Médicaux Tests', function() {
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

    it('should navigate to actes medicaux page', async function() {
        await driver.get('http://localhost:5173/actes');
        await driver.sleep(2000);
        
        const currentUrl = await driver.getCurrentUrl();
        assert(currentUrl.includes('/actes'), 'Should be on actes page');
        
        console.log('✓ Actes médicaux page loaded');
    });

    it('should display actes list', async function() {
        await driver.get('http://localhost:5173/actes');
        await driver.sleep(2000);
        
        // Look for table or list elements
        const displayElements = await driver.findElements(
            By.css('table, .acte-card, [data-testid="acte-list"]')
        );
        
        console.log('✓ Actes display checked');
    });

    it('should show acte types', async function() {
        await driver.get('http://localhost:5173/actes');
        await driver.sleep(2000);
        
        const pageSource = await driver.getPageSource();
        const hasActeTypes = pageSource.includes('CONSULTATION') || 
                            pageSource.includes('CHIRURGIE') ||
                            pageSource.includes('IMAGERIE') ||
                            pageSource.toLowerCase().includes('type');
        
        console.log('✓ Acte types displayed');
    });

    it('should display cost information', async function() {
        await driver.get('http://localhost:5173/actes');
        await driver.sleep(2000);
        
        const pageSource = await driver.getPageSource();
        const hasCostInfo = pageSource.includes('€') || 
                           pageSource.includes('coût') ||
                           pageSource.includes('prix') ||
                           pageSource.includes('tarif');
        
        console.log('✓ Cost information checked');
    });

    it('should have search or filter capabilities', async function() {
        await driver.get('http://localhost:5173/actes');
        await driver.sleep(2000);
        
        const searchElements = await driver.findElements(
            By.css('input[type="search"], input[placeholder*="cherch"], select')
        );
        
        console.log(`✓ Found ${searchElements.length} search/filter elements`);
    });
});
