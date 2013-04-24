<%-- 
    Document   : list
    Created on : Apr 13, 2013, 5:42:09 PM
    Author     : colin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta http-equiv="cache-control" content="max-age=0" />
        <meta http-equiv="cache-control" content="no-cache" />
        <link rel="stylesheet" type="text/css" href="../css/newcss.css">
        <title>List of MP3s with Missing Tags</title>
        <script type="text/javascript" src="../js/buttons.js"></script>
    </head>
    <body>
        <c:choose>
            <c:when test="${fn:length(tags) > 0}">
                <h1>MP3s with missing tags</h1>
                <strong>[Page ${(offset / numrows) + 1}] Showing ${fn:length(tags)} song(s) with missing tags.</strong><br/>
                <!-- the object is 'tags': List<Map<String,Object>> -->
                <div><form id="paginateForm" method="POST">
                        <input type="hidden" name="offset" value="${offset}">
                        <input type="hidden" name="numrows" value="${numrows}">
                        <c:if test="${offset > 0}">
                            <input type="button" value="&lt; Back" onclick="submitPageForm(${offset - numrows})">
                        </c:if>
                        <c:if test="${fn:length(tags) == numrows }">
                            <input type="button" value="Next &gt;" onclick="submitPageForm(${offset + numrows})">
                        </c:if>
                    </form></div>
                <div>Search (filters by Location): <input id="searchbox" onkeyup="filter(this)"></div>
                <table border="0">
                    <tr>
                        <th>Title</th>
                        <th>Artist</th>
                        <th>&nbsp;</th>
                        <th>Location</th>
                    </tr>
                    <c:forEach var="tag" items="${tags}">
                    <tr id="${tag.filehash}" class="trvisible">
                        <td><input type="hidden" name="filehash" value="${tag.filehash}">
                            <input name="title" value="${tag.title}" onclick="setedit(this, true)" readonly="true"></td>
                        <td><input name="artist" value="${tag.artist}" onclick="setedit(this, true)" readonly="true"></td>
                        <td><input type="button" value="OK" onclick="setedit(this, false)"></td>
                        <td class="filepath">${tag.songFilepath}</td>
                    </tr>
                    </c:forEach>
                </table>
            </c:when>
            <c:otherwise>
                <h3>No MP3s have missing tags!</h3>
            </c:otherwise>
        </c:choose>
    </body>
</html>
