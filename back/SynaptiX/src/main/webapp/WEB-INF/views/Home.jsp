<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Test JSP</title>
</head>
<body>
    <h2>JSP Test Page</h2>
    <p>This is a test JSP file for your project.</p>
	<p>아이디: ${homeList[0]['id']}</p>
	<p>이름: ${homeList[0]['name']}</p>
</body>
</html>
