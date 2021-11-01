package io.eduriol;

import java.util.concurrent.TimeoutException;

import io.eduriol.pages.DashboardPage;
import io.eduriol.pages.LoginPage;

public class GhostUITest {

    public static void main(String[] args) throws InterruptedException, TimeoutException {
        LoginPage loginPage = new LoginPage();
        loginPage.load("http://localhost:" + System.getenv("PORT") + "/ghost/#/signin");
        DashboardPage dashboardPage = loginPage.login(System.getenv("EMAIL"), System.getenv("PASSWORD"));
        if (dashboardPage.isLoaded()) {
            dashboardPage.close();
            System.exit(0);
        } else {
            dashboardPage.close();
            System.exit(1);
        }
    }

}
