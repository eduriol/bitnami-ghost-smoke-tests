package io.eduriol.pages;

import java.util.concurrent.TimeoutException;

import io.github.bonigarcia.wdm.WebDriverManager;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

public class LoginPage {

    private final By USER_INPUT_LOCATOR = By.name("identification");
    private final By PASS_INPUT_LOCATOR = By.name("password");
    private final By SIGN_IN_BUTTON_LOCATOR = By.className("gh-btn-login");

    private WebDriver driver;
    private WebDriverWait wait;

    public void load(String url) throws InterruptedException, TimeoutException {
        WebDriverManager.chromedriver().setup();
        driver = new ChromeDriver();
        int tries = 0;
        while (!driver.getTitle().contains("Sign In - ")) {
            if (tries > 15) {
                throw new TimeoutException("Unable to get login page on time.");
            }
            driver.get(url);
            Thread.sleep(2000);
            tries++;
        }
    }

    public DashboardPage login(String user, String pass) {
        wait = new WebDriverWait(driver,10);
        wait.until(ExpectedConditions.elementToBeClickable(USER_INPUT_LOCATOR));
        driver.findElement(USER_INPUT_LOCATOR).sendKeys(user);
        driver.findElement(PASS_INPUT_LOCATOR).sendKeys(pass);
        driver.findElement(SIGN_IN_BUTTON_LOCATOR).click();
        return new DashboardPage(driver);
    }
}
