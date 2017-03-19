/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.dbexecutor;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;
import java.sql.Connection;
import net.oletalk.dbexecutor.domain.Version;
import net.oletalk.dbexecutor.service.StatementCollector;
import net.oletalk.dbexecutor.util.MyBatisUtil;
import org.apache.ibatis.io.Resources;
import org.apache.ibatis.jdbc.ScriptRunner;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;

/**
 *
 * @author colin
 */
public class App {
    
    public static final String ROOTDIR = "/Users/colin/java/db";
    
    public static void main(String... args) {
        // are we doing a rollout or a rollback?
        // collect all sql statements for the version we're rolling forward/backward to
        StatementCollector c = new StatementCollector();
        Version v = c.collect(ROOTDIR + "/1", RolloutType.ROLLBACK);
        
        // implement this version, rolling back if things go wrong
        VersionMover mover = new VersionMover();
        mover.implement(v);
        
    }
}
