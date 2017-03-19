/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.dbexecutor;

/**
 * The StatementCollector will collect SQL statements in files ending in the
 * given RolloutType below.
 * 
 * @author colin
 */
public enum RolloutType {
    ROLLOUT("rollout.sql"),
    ROLLBACK("rollback.sql");
    
    private final String text;
    
    private RolloutType(final String text) {
        this.text = text;
    }
    
    @Override
    public String toString() {
        return text;
    }
}
