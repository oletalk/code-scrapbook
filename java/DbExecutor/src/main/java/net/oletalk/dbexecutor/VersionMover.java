/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.dbexecutor;

import net.oletalk.dbexecutor.domain.Version;
import net.oletalk.dbexecutor.util.MyBatisUtil;

/**
 * Finds and executes statements to move a system from the sourceVersion to the targetVersion.
 * @author colin
 */
public class VersionMover {
    public void implement(Version version) {
        MyBatisUtil.runStatementsInFiles(version.getFilenames());
    }
}
