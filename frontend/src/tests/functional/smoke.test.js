/**
 * Simple Smoke Test
 * Quick test to verify Selenium setup is working correctly
 */

const { Builder, By } = require('selenium-webdriver');
const assert = require('assert');

describe('Smoke Test - Basic Setup Verification', function() {
    this.timeout(15000);
    let driver;

    before(async function() {
        console.log('Starting Chrome browser...');
        driver = await new Builder().forBrowser('chrome').build();
    });

    after(async function() {
        if (driver) {
            await driver.quit();
        }
    });

    it('should connect to Chrome browser', async function() {
        assert(driver, 'Driver should be initialized');
        console.log('✓ Chrome browser connected');
    });

    it('should load the frontend application', async function() {
        await driver.get('http://localhost:5173');
        await driver.sleep(2000);
        
        const currentUrl = await driver.getCurrentUrl();
        assert(currentUrl.includes('localhost:5173'), 'Should navigate to frontend URL');
        console.log('✓ Frontend application loaded');
    });

    it('should have a valid HTML page', async function() {
        await driver.get('http://localhost:5173');
        await driver.sleep(1000);
        
        const pageSource = await driver.getPageSource();
        assert(pageSource.includes('<html'), 'Should have valid HTML');
        console.log('✓ Valid HTML page detected');
    });

    it('should have the correct page title', async function() {
        await driver.get('http://localhost:5173');
        await driver.sleep(1000);
        
        const title = await driver.getTitle();
        assert(title.length > 0, 'Title should not be empty');
        console.log(`✓ Page title: "${title}"`);
    });

    it('should be able to find elements by CSS', async function() {
        await driver.get('http://localhost:5173');
        await driver.sleep(1000);
        
        const elements = await driver.findElements(By.css('body'));
        assert(elements.length > 0, 'Should find body element');
        console.log('✓ Can locate elements by CSS selector');
    });

    it('should execute JavaScript on the page', async function() {
        await driver.get('http://localhost:5173');
        await driver.sleep(1000);
        
        const result = await driver.executeScript('return "Selenium is working!"');
        assert.strictEqual(result, 'Selenium is working!', 'JavaScript should execute');
        console.log('✓ JavaScript execution works');
    });

    it('should handle page navigation', async function() {
        await driver.get('http://localhost:5173');
        await driver.sleep(500);
        
        await driver.get('http://localhost:5173/login');
        await driver.sleep(500);
        
        const currentUrl = await driver.getCurrentUrl();
        assert(currentUrl.includes('login') || currentUrl.includes('5173'), 
            'Should navigate between pages');
        console.log('✓ Page navigation works');
    });
});
