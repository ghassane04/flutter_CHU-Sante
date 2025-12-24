/**
 * Selenium WebDriver Configuration
 */

const { Builder } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const { ServiceBuilder } = require('selenium-webdriver/chrome');

/**
 * Create a Chrome WebDriver with optimal settings for testing
 * @param {boolean} headless - Run in headless mode
 * @returns {Promise<WebDriver>}
 */
async function createDriver(headless = false) {
    const options = new chrome.Options();
    
    if (headless) {
        options.addArguments('--headless');
    }
    
    // Additional Chrome options for stability
    options.addArguments('--disable-dev-shm-usage');
    options.addArguments('--no-sandbox');
    options.addArguments('--disable-gpu');
    options.addArguments('--window-size=1920,1080');
    options.addArguments('--disable-blink-features=AutomationControlled');
    options.setUserPreferences({
        'profile.default_content_setting_values.notifications': 2
    });
    
    // Configure ChromeDriver path
    const service = new ServiceBuilder('C:\\chromedriver.exe');
    
    const driver = await new Builder()
        .forBrowser('chrome')
        .setChromeService(service)
        .setChromeOptions(options)
        .build();
    
    // Set implicit wait
    await driver.manage().setTimeouts({ implicit: 5000 });
    
    return driver;
}

/**
 * Configuration constants
 */
const config = {
    baseUrl: 'http://localhost:5173',
    apiUrl: 'http://localhost:8080',
    defaultTimeout: 10000,
    testUser: {
        email: 'ali01',
        password: 'ghassane'
    }
};

module.exports = {
    createDriver,
    config
};
