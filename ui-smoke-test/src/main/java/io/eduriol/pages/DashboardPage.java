package io.eduriol.pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

public class DashboardPage {

    private WebDriver driver;
    private WebDriverWait wait;

    public DashboardPage(WebDriver driver) {
        this.driver = driver;
    }

    public boolean isLoaded() {
        wait = new WebDriverWait(driver,10);
        wait.until(ExpectedConditions.urlContains("/ghost/#/dashboard"));
        return driver.getCurrentUrl().endsWith("/ghost/#/dashboard");
    }

    public void close() {
        driver.close();
    }
}
