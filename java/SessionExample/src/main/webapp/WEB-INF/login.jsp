<%@page contentType="text/html" pageEncoding="US-ASCII"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Login page</title>
        <meta http-equiv="Content-Type" content="text/html; charset=US-ASCII">
    </head>
    <body>
        <c:out value="${errorMsg}"/>
        <form action="/srv/dologin" method="POST">
            Username: <input type="text" name="user">
            <br/>
            Password: <input type="password" name="pwd">
            <br/>
            <input type="submit" value="Login">
        </form>
    </body>
</html>
