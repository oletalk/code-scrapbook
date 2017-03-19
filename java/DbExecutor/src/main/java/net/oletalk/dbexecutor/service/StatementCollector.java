/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.dbexecutor.service;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import net.oletalk.dbexecutor.domain.Version;
import java.util.Scanner;
import net.oletalk.dbexecutor.RolloutType;

/**
 * Service to collect all the SQL statements under a version e.g. 1/MYDB/rollout.sql
 * @author colin
 */
public class StatementCollector {
    public Version collect(String dir, RolloutType crit) {
        Version ret = new Version(crit);
        List<String> filenames = new ArrayList<>();
        
        try {
            Files.walk(Paths.get(dir))
                .filter(Files::isRegularFile)
                .forEach((f) -> {
                    String filename = f.toString();
                    if (filename.endsWith(crit.toString())) {
                        System.out.println("Found sql file " + filename);
                        filenames.add(filename);
                    }
                });
        } catch (IOException ioe) {
            ioe.printStackTrace();
        }
        ret.setFilenames(filenames);
        return ret;
    }
}
