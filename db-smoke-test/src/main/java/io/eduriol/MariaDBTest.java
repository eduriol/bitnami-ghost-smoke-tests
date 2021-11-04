package io.eduriol;

import java.sql.*;
import java.util.concurrent.TimeoutException;

public class MariaDBTest {

    static final String JDBC_DRIVER = "org.mariadb.jdbc.Driver";
    static final String DB_URL = "jdbc:mariadb://127.0.0.1:3306/" + System.getenv("DB_NAME");
    static final String USER = System.getenv("DB_USER");
    static final String PASS = System.getenv("DB_PASSWORD");;

    public static void main(String[] args) throws TimeoutException {
        Connection conn = null;
        Statement stmt = null;
        try {
            // Register JDBC driver
            Class.forName(JDBC_DRIVER);

            // Open connection, looping until the service starts
            System.out.println("Connecting to the selected database...");
            int tries = 0;
            while (conn == null) {
                if (tries > 15) {
                    throw new TimeoutException("Unable to connect to database.");
                }
                try {
                    conn = DriverManager.getConnection(DB_URL, USER, PASS);
                } catch (SQLNonTransientConnectionException e) {
                    tries++;
                }
                Thread.sleep(2000);
            }
            System.out.println("Connected successfully to database...");

            // Create test table
            System.out.println("Creating test table in given database...");
            stmt = conn.createStatement();
            String dropSql = "DROP TABLE IF EXISTS TEST";
            stmt.executeUpdate(dropSql);
            String createSql = "CREATE TABLE TEST" +
                    "(id INTEGER not NULL," +
                    "field VARCHAR(255)," +
                    "PRIMARY KEY ( id ))";
            stmt.executeUpdate(createSql);

            // Insert dummy value in test table
            System.out.println("Inserting row in test table...");
            String insertSql = "INSERT INTO TEST" +
                    "(id, field)" +
                    "VALUES (1, 'test')";
            stmt.executeUpdate(insertSql);

            // Check the test table contains inserted row
            System.out.println("Getting number of rows in test table...");
            String selectSql = "SELECT COUNT(*) AS 'row_count'" +
                    "FROM TEST";
            ResultSet resultSet = stmt.executeQuery(selectSql);
            resultSet.next();
            int rowCount = resultSet.getInt("row_count");
            if (rowCount != 1) {
                System.exit(1);
            }

            // Drop the test table
            System.out.println("Dropping test table...");
            stmt.executeUpdate(dropSql);

            System.exit(0);

        } catch (SQLException | ClassNotFoundException | InterruptedException e) {
            e.printStackTrace();
            System.exit(1);
        } finally {
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException se) {
                se.printStackTrace();
                System.exit(1);
            }
        }
    }

}
