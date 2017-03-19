/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.dbexecutor.util;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.dbexecutor.exception.VersionException;
import org.apache.ibatis.io.Resources;
import org.apache.ibatis.jdbc.ScriptRunner;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;

/**
 *
 * @author colin
 */
public class MyBatisUtil {
    
    // this should be the complete list of statements within a Version.
    public static boolean runStatementsInFiles(List<String> filenames) throws VersionException {
        SqlSession session = null;
        Connection conn = null;
        boolean success = false;
        try {
            // get the config
            Reader reader = Resources.getResourceAsReader("mybatis-config.xml");
            SqlSessionFactory manager = new SqlSessionFactoryBuilder().build(reader);
            reader.close();

            session = manager.openSession();
            conn = session.getConnection();
            // run the sql
            success = runFiles(filenames, conn);

        } catch (IOException ioe) {
            ioe.printStackTrace();
        } finally {
            if (session != null) {
                session.close();
                try {
                    conn.close();  
                } catch (SQLException sqe) {
                    sqe.printStackTrace();
                }
            }
        }
        return success;

    }
    
    private static boolean runFiles(List<String> filenames, Connection conn) throws VersionException {
        boolean success = true;
        if (conn == null) {
            return false; // bail if no connection in the first place
        }
        for (String sqlfile : filenames) {
            Reader reader;
            try {
                reader = new BufferedReader(new FileReader(sqlfile));
                ScriptRunner runner = new ScriptRunner(conn);
                runner.setStopOnError(true);
                runner.setAutoCommit(false);
                runner.runScript(reader);
                reader.close();
                System.out.println("No errors; committing changes.");
                conn.commit();

            } catch (FileNotFoundException ex) {
                System.err.println("Given file was not found: " + sqlfile + ", skipping!");
            } catch (Exception e) {
                success = false;
                System.out.println("Error encountered; rolling back!");
                try {
                    conn.rollback();
                } catch (SQLException sqe) {
                    sqe.printStackTrace();
                }
                throw new VersionException("Execution of " + sqlfile + " failed with " + e.getMessage());
            }
        }
        return success;
    }
}
