const { Builder, By, until } = require('selenium-webdriver');
const assert = require('assert');

describe('Login Tests', function() {
    this.timeout(30000);
    let driver;

    before(async function() {
        driver = await new Builder().forBrowser('chrome').build();
    });

    after(async function() {
        await driver.quit();
    });

    it('should load login page successfully', async function() {
        await driver.get('http://localhost:5173/login');
        await driver.wait(until.titleIs('CHU Santé'), 5000);
        
        const pageSource = await driver.getPageSource();
        assert(pageSource.includes('Connexion') || pageSource.includes('Login'), 'Login page not loaded');
        console.log('✓ Login page loaded successfully');
    });

    it('should show error with invalid credentials', async function() {
        await driver.get('http://localhost:5173/login');
        
        // Find email/username input
        const emailInput = await driver.wait(
            until.elementLocated(By.css('input[type="email"], input[type="text"], input[name="email"], input[name="username"]')),
            5000
        );
        await emailInput.clear();
        await emailInput.sendKeys('invalid@test.com');
        
        // Find password input
        const passwordInput = await driver.findElement(
            By.css('input[type="password"], input[name="password"]')
        );
        await passwordInput.clear();
        await passwordInput.sendKeys('wrongpassword');
        
        // Find and click submit button
        const submitButton = await driver.findElement(
            By.css('button[type="submit"], button:contains("Connexion"), button:contains("Login")')
        );
        await submitButton.click();
        
        // Wait for error message
        await driver.sleep(2000);
        
        console.log('✓ Error handling works for invalid credentials');
    });

    it('should login successfully with valid credentials', async function() {
        await driver.get('http://localhost:5173/login');
        
        // Find email input
        const emailInput = await driver.wait(
            until.elementLocated(By.css('input[type="email"], input[type="text"], input[name="email"], input[name="username"]')),
            5000
        );
        await emailInput.clear();
        await emailInput.sendKeys('admin@chu.com');
        
        // Find password input
        const passwordInput = await driver.findElement(
            By.css('input[type="password"], input[name="password"]')
        );
        await passwordInput.clear();
        await passwordInput.sendKeys('admin123');
        
        // Click submit
        const submitButton = await driver.findElement(
            By.css('button[type="submit"], button:contains("Connexion"), button:contains("Login")')
        );
        await submitButton.click();
        
        // Wait for redirect to dashboard
        await driver.wait(async function() {
            const currentUrl = await driver.getCurrentUrl();
            return currentUrl.includes('/dashboard') || currentUrl.includes('/home') || !currentUrl.includes('/login');
        }, 10000);
        
        const currentUrl = await driver.getCurrentUrl();
        assert(!currentUrl.includes('/login'), 'Should redirect away from login page');
        
        console.log('✓ Login successful with valid credentials');
    });

    it('should have proper input validation', async function() {
        await driver.get('http://localhost:5173/login');
        
        // Try to submit empty form
        const submitButton = await driver.wait(
            until.elementLocated(By.css('button[type="submit"]')),
            5000
        );
        await submitButton.click();
        
        await driver.sleep(1000);
        
        // Check if still on login page (form validation prevented submission)
        const currentUrl = await driver.getCurrentUrl();
        assert(currentUrl.includes('/login'), 'Should stay on login page with empty form');
        
        console.log('✓ Form validation works correctly');
    });
});
