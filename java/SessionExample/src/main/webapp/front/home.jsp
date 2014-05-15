<%@page contentType="text/html" pageEncoding="US-ASCII"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=US-ASCII">
        <title>JSP Page</title>
    </head>
    <body>
        <h1>Welcome <c:out value="${user}"/>!</h1>
        <shiro:hasRole name="admin">
            <b>(admin)</b>
        </shiro:hasRole>
    </body>
    <a href="/members/view">Some members-only page example</a>
    
    <form name="logout" action="/logout" method="POST">
        <input type="submit" value="Logout">
    </form>
</html>
