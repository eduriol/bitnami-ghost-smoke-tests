package io.eduriol;

import java.util.concurrent.TimeoutException;

import io.eduriol.pages.DashboardPage;
import io.eduriol.pages.LoginPage;

public class GhostUITest {

    public static void main(String[] args) throws InterruptedException, TimeoutException {
        LoginPage loginPage = new LoginPage();
        loginPage.load("http://localhost:8080/ghost/#/signin");
        DashboardPage dashboardPage = loginPage.login("vmware@vmware.com", "vmw@r3p455w0rd");
        if (dashboardPage.isLoaded()) {
            dashboardPage.close();
            System.exit(0);
        } else {
            dashboardPage.close();
            System.exit(1);
        }
    }

}
