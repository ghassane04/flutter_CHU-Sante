/**
 * Selenium Test Helper Utilities
 * Common functions for E2E tests
 */

const { By, until } = require('selenium-webdriver');

/**
 * Login helper function
 * @param {WebDriver} driver - Selenium WebDriver instance
 * @param {string} email - User email
 * @param {string} password - User password
 */
async function login(driver, email = 'admin@chu.com', password = 'admin123') {
    try {
        await driver.get('http://localhost:5173/login');
        
        const emailInput = await driver.wait(
            until.elementLocated(By.css('input[type="email"], input[type="text"], input[name="email"], input[name="username"]')),
            5000
        );
        await emailInput.clear();
        await emailInput.sendKeys(email);
        
        const passwordInput = await driver.findElement(
            By.css('input[type="password"], input[name="password"]')
        );
        await passwordInput.clear();
        await passwordInput.sendKeys(password);
        
        const submitButton = await driver.findElement(
            By.css('button[type="submit"]')
        );
        await submitButton.click();
        
        await driver.sleep(3000);
        return true;
    } catch (e) {
        console.log('Login error:', e.message);
        return false;
    }
}

/**
 * Wait for element to be visible
 * @param {WebDriver} driver 
 * @param {By} selector 
 * @param {number} timeout 
 */
async function waitForElement(driver, selector, timeout = 5000) {
    return await driver.wait(until.elementLocated(selector), timeout);
}

/**
 * Check if element exists
 * @param {WebDriver} driver 
 * @param {string} cssSelector 
 */
async function elementExists(driver, cssSelector) {
    try {
        const elements = await driver.findElements(By.css(cssSelector));
        return elements.length > 0;
    } catch (e) {
        return false;
    }
}

/**
 * Take a screenshot
 * @param {WebDriver} driver 
 * @param {string} filename 
 */
async function takeScreenshot(driver, filename) {
    const fs = require('fs');
    const path = require('path');
    
    const image = await driver.takeScreenshot();
    const screenshotDir = path.join(__dirname, 'screenshots');
    
    if (!fs.existsSync(screenshotDir)) {
        fs.mkdirSync(screenshotDir, { recursive: true });
    }
    
    fs.writeFileSync(
        path.join(screenshotDir, `${filename}.png`),
        image,
        'base64'
    );
}

/**
 * Wait for page to load
 * @param {WebDriver} driver 
 */
async function waitForPageLoad(driver) {
    await driver.wait(async function() {
        const readyState = await driver.executeScript('return document.readyState');
        return readyState === 'complete';
    }, 10000);
}

/**
 * Click element by text
 * @param {WebDriver} driver 
 * @param {string} text 
 * @param {string} tag - Element tag (button, a, span, etc.)
 */
async function clickElementByText(driver, text, tag = 'button') {
    const elements = await driver.findElements(By.css(tag));
    for (let element of elements) {
        try {
            const elementText = await element.getText();
            if (elementText.includes(text)) {
                await element.click();
                return true;
            }
        } catch (e) {
            continue;
        }
    }
    return false;
}

/**
 * Fill form field
 * @param {WebDriver} driver 
 * @param {string} selector 
 * @param {string} value 
 */
async function fillField(driver, selector, value) {
    const field = await driver.findElement(By.css(selector));
    await field.clear();
    await field.sendKeys(value);
}

/**
 * Get text from element
 * @param {WebDriver} driver 
 * @param {string} selector 
 */
async function getElementText(driver, selector) {
    try {
        const element = await driver.findElement(By.css(selector));
        return await element.getText();
    } catch (e) {
        return null;
    }
}

/**
 * Check if page contains text
 * @param {WebDriver} driver 
 * @param {string} text 
 */
async function pageContainsText(driver, text) {
    const pageSource = await driver.getPageSource();
    return pageSource.includes(text);
}

/**
 * Navigate and wait
 * @param {WebDriver} driver 
 * @param {string} url 
 */
async function navigateAndWait(driver, url, waitTime = 2000) {
    await driver.get(url);
    await driver.sleep(waitTime);
    await waitForPageLoad(driver);
}

module.exports = {
    login,
    waitForElement,
    elementExists,
    takeScreenshot,
    waitForPageLoad,
    clickElementByText,
    fillField,
    getElementText,
    pageContainsText,
    navigateAndWait
};
