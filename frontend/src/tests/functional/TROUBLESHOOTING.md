# Guide de Dépannage - Tests Selenium E2E

## 🔍 Problèmes Courants et Solutions

### 1. "ChromeDriver not found" ou "Chrome binary not found"

**Symptômes:**
```
Error: The chromedriver.exe file does not exist.
SessionNotCreatedError: Could not start a new session
```

**Solutions:**

**A. Installation globale (Recommandé):**
```bash
npm install -g chromedriver
```

**B. Installation locale:**
```bash
cd frontend
npm install --save-dev chromedriver
```

**C. Vérification de Chrome:**
```bash
# Windows
"C:\Program Files\Google\Chrome\Application\chrome.exe" --version

# Linux/Mac
google-chrome --version
```

**D. Téléchargement manuel:**
1. Aller sur https://chromedriver.chromium.org/downloads
2. Télécharger la version correspondant à votre Chrome
3. Placer `chromedriver.exe` dans le PATH système

---

### 2. "Unable to connect to localhost:5173"

**Symptômes:**
```
Error: ECONNREFUSED
TimeoutError: Waiting for page to load timed out
```

**Solutions:**

**A. Vérifier que le frontend est lancé:**
```bash
cd frontend
npm run dev
```

**B. Vérifier le port dans la console:**
```
VITE v6.3.5  ready in 500 ms

➜  Local:   http://localhost:5173/
➜  Network: use --host to expose
```

**C. Tester manuellement:**
Ouvrir http://localhost:5173 dans votre navigateur

**D. Changer le port si nécessaire:**
Dans les fichiers de test, remplacer `http://localhost:5173` par le port affiché

---

### 3. "Timeout waiting for element"

**Symptômes:**
```
TimeoutError: Wait timed out after 5000ms
ElementNotFoundError: Unable to locate element
```

**Solutions:**

**A. Augmenter les timeouts:**
```javascript
// Dans le fichier de test
this.timeout(30000); // 30 secondes

// Pour un élément spécifique
await driver.wait(until.elementLocated(By.css('.my-element')), 10000);
```

**B. Ajouter des délais:**
```javascript
await driver.sleep(2000); // Attendre 2 secondes
```

**C. Vérifier les sélecteurs:**
```javascript
// Utiliser des sélecteurs plus spécifiques
By.css('[data-testid="login-button"]')
By.css('#username')
By.css('input[name="email"]')
```

**D. Attendre le chargement complet:**
```javascript
await driver.wait(async function() {
    const readyState = await driver.executeScript('return document.readyState');
    return readyState === 'complete';
}, 10000);
```

---

### 4. "Backend API not responding"

**Symptômes:**
```
Network Error
500 Internal Server Error
Tests pass but data not loading
```

**Solutions:**

**A. Vérifier le backend:**
```bash
cd backend
mvn spring-boot:run
```

**B. Tester l'API manuellement:**
```bash
# PowerShell
Invoke-WebRequest -Uri http://localhost:8080/api/patients

# curl
curl http://localhost:8080/api/patients
```

**C. Vérifier les logs du backend:**
Regarder la console où le backend tourne pour les erreurs

**D. Vérifier la connexion à la base de données:**
Dans `backend/src/main/resources/application.properties`

---

### 5. "Tests échouent de façon intermittente"

**Symptômes:**
```
Tests passent parfois, échouent d'autres fois
Éléments trouvés puis perdus
```

**Solutions:**

**A. Utiliser des attentes explicites au lieu de sleep:**
```javascript
// ❌ Mauvais
await driver.sleep(5000);

// ✅ Bon
await driver.wait(until.elementLocated(By.css('.my-element')), 5000);
await driver.wait(until.elementIsVisible(element), 5000);
```

**B. Vérifier les animations:**
Les animations CSS peuvent rendre les éléments non cliquables temporairement
```javascript
// Attendre que l'animation se termine
await driver.sleep(500);
```

**C. Désactiver les animations en mode test:**
Dans votre CSS de test:
```css
*, *::before, *::after {
    animation-duration: 0s !important;
    transition-duration: 0s !important;
}
```

---

### 6. "Mocha not found"

**Symptômes:**
```
'mocha' is not recognized as an internal or external command
```

**Solutions:**

**A. Installer Mocha:**
```bash
npm install --save-dev mocha
```

**B. Utiliser npx:**
```bash
npx mocha src/tests/functional/login.test.js
```

**C. Vérifier l'installation:**
```bash
npx mocha --version
```

---

### 7. "Element not interactable"

**Symptômes:**
```
ElementNotInteractableError: element not interactable
```

**Solutions:**

**A. Scroller jusqu'à l'élément:**
```javascript
const element = await driver.findElement(By.css('.my-button'));
await driver.executeScript("arguments[0].scrollIntoView(true);", element);
await driver.sleep(500);
await element.click();
```

**B. Attendre la visibilité:**
```javascript
const element = await driver.wait(until.elementLocated(By.css('.my-button')), 5000);
await driver.wait(until.elementIsVisible(element), 5000);
await element.click();
```

**C. Utiliser JavaScript pour cliquer:**
```javascript
const element = await driver.findElement(By.css('.my-button'));
await driver.executeScript("arguments[0].click();", element);
```

---

### 8. "Stale element reference"

**Symptômes:**
```
StaleElementReferenceError: stale element reference
```

**Solutions:**

**A. Re-trouver l'élément:**
```javascript
// ❌ Mauvais
const button = await driver.findElement(By.css('button'));
await someAction();
await button.click(); // Peut échouer

// ✅ Bon
await someAction();
const button = await driver.findElement(By.css('button'));
await button.click();
```

**B. Utiliser une fonction wrapper:**
```javascript
async function clickElement(selector) {
    const element = await driver.findElement(By.css(selector));
    await element.click();
}
```

---

### 9. Tests très lents

**Solutions:**

**A. Mode headless:**
```javascript
const chrome = require('selenium-webdriver/chrome');
const options = new chrome.Options();
options.addArguments('--headless');

driver = await new Builder()
    .forBrowser('chrome')
    .setChromeOptions(options)
    .build();
```

**B. Réduire les sleep:**
Remplacer les `driver.sleep()` par des attentes conditionnelles

**C. Paralléliser les tests:**
```bash
npx mocha src/tests/functional/*.test.js --parallel
```

---

### 10. "Cannot read property of undefined"

**Symptômes:**
```javascript
TypeError: Cannot read property 'click' of undefined
```

**Solutions:**

**A. Vérifier que l'élément existe:**
```javascript
const elements = await driver.findElements(By.css('.my-element'));
if (elements.length > 0) {
    await elements[0].click();
} else {
    console.log('Element not found');
}
```

**B. Utiliser try-catch:**
```javascript
try {
    const element = await driver.findElement(By.css('.my-element'));
    await element.click();
} catch (e) {
    console.log('Element not found or not clickable:', e.message);
}
```

---

## 🛠️ Outils de Débogage

### 1. Prendre des screenshots
```javascript
const fs = require('fs');
const screenshot = await driver.takeScreenshot();
fs.writeFileSync('screenshot.png', screenshot, 'base64');
```

### 2. Afficher le HTML de la page
```javascript
const pageSource = await driver.getPageSource();
console.log(pageSource);
```

### 3. Exécuter du JavaScript dans la console
```javascript
const result = await driver.executeScript(`
    console.log('Debug info');
    return document.querySelector('.my-element');
`);
console.log(result);
```

### 4. Logs du navigateur
```javascript
const logs = await driver.manage().logs().get('browser');
logs.forEach(entry => {
    console.log('[Browser]', entry.level.name, entry.message);
});
```

### 5. Mode pas à pas
```javascript
// Ajouter des pauses pour observer
const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
});

await new Promise(resolve => {
    readline.question('Press Enter to continue...', () => {
        readline.close();
        resolve();
    });
});
```

---

## 📞 Aide Supplémentaire

- **Documentation Selenium:** https://www.selenium.dev/documentation/
- **Mocha Documentation:** https://mochajs.org/
- **Stack Overflow:** Tag `selenium-webdriver`
- **GitHub Issues:** Selenium WebDriver repository

---

## ✅ Checklist de Vérification

Avant de demander de l'aide, vérifier:

- [ ] Chrome et ChromeDriver sont installés et compatibles
- [ ] Le frontend tourne sur http://localhost:5173
- [ ] Le backend API tourne sur http://localhost:8080
- [ ] Les dépendances npm sont installées (`npm install`)
- [ ] Pas d'erreurs dans la console du backend
- [ ] Le navigateur peut accéder à l'application manuellement
- [ ] Les tests simples (smoke test) passent
- [ ] Les sélecteurs CSS sont corrects
- [ ] Les timeouts sont suffisants

---

Mis à jour: Décembre 2025
