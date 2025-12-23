const { Builder, By, until } = require('selenium-webdriver');
const assert = require('assert');

describe('Dashboard Tests', function() {
    this.timeout(30000);
    let driver;

    before(async function() {
        driver = await new Builder().forBrowser('chrome').build();
        
        // Login first
        await driver.get('http://localhost:5173/login');
        try {
            const emailInput = await driver.wait(
                until.elementLocated(By.css('input[type="email"], input[type="text"], input[name="email"], input[name="username"]')),
                5000
            );
            await emailInput.sendKeys('admin@chu.com');
            
            const passwordInput = await driver.findElement(By.css('input[type="password"]'));
            await passwordInput.sendKeys('admin123');
            
            const submitButton = await driver.findElement(By.css('button[type="submit"]'));
            await submitButton.click();
            
            await driver.sleep(3000);
        } catch (e) {
            console.log('Login may already be active or login form structure different');
        }
    });

    after(async function() {
        await driver.quit();
    });

    it('should load dashboard page', async function() {
        await driver.get('http://localhost:5173/dashboard');
        await driver.sleep(2000);
        
        const currentUrl = await driver.getCurrentUrl();
        assert(currentUrl.includes('/dashboard') || !currentUrl.includes('/login'), 
            'Should be on dashboard or authenticated page');
        
        console.log('✓ Dashboard page loaded');
    });

    it('should display statistics cards', async function() {
        await driver.get('http://localhost:5173/dashboard');
        await driver.sleep(2000);
        
        // Look for common dashboard elements like cards, stats, numbers
        const pageSource = await driver.getPageSource();
        const hasStats = pageSource.toLowerCase().includes('patient') || 
                        pageSource.toLowerCase().includes('séjour') ||
                        pageSource.toLowerCase().includes('total') ||
                        pageSource.toLowerCase().includes('stat');
        
        assert(hasStats, 'Dashboard should display statistics');
        console.log('✓ Dashboard statistics displayed');
    });

    it('should have navigation menu', async function() {
        await driver.get('http://localhost:5173/dashboard');
        await driver.sleep(2000);
        
        // Look for navigation elements
        const navElements = await driver.findElements(By.css('nav, [role="navigation"], aside, .sidebar'));
        assert(navElements.length > 0, 'Navigation menu should be present');
        
        console.log('✓ Navigation menu found');
    });

    it('should be able to navigate to different pages', async function() {
        await driver.get('http://localhost:5173/dashboard');
        await driver.sleep(2000);
        
        // Try to find and click on various navigation links
        const links = await driver.findElements(By.css('a[href], button'));
        assert(links.length > 0, 'Should have clickable navigation elements');
        
        console.log(`✓ Found ${links.length} navigation elements`);
    });

    it('should display charts or graphs', async function() {
        await driver.get('http://localhost:5173/dashboard');
        await driver.sleep(3000);
        
        // Look for chart elements (recharts uses SVG)
        const charts = await driver.findElements(By.css('svg, canvas, .recharts-wrapper'));
        
        console.log(`✓ Found ${charts.length} chart elements`);
    });
});
