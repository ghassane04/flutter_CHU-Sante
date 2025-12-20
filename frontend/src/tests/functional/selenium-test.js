const { Builder, By, Key, until } = require('selenium-webdriver');

(async function example() {
    let driver = await new Builder().forBrowser('chrome').build();
    try {
        // Navigate to local frontend
        await driver.get('http://localhost:5173');

        // Wait for title or a specific element
        await driver.wait(until.titleIs('CHU Santé'), 1000);

        // Example: Find login inputs (if on login page)
        // await driver.findElement(By.name('q')).sendKeys('webdriver', Key.RETURN);
        // await driver.wait(until.titleIs('webdriver - Google Search'), 1000);

        console.log("Test Passed: Page loaded successfully");
    } catch (e) {
        console.error("Test Failed: ", e);
    } finally {
        await driver.quit();
    }
})();
