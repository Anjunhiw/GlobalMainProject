<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>재고 수정</title>
</head>
<body>
<h2>재고 수정</h2>
<c:choose>
    <c:when test="${not empty material}">
        <form action="/stock/editMaterial" method="post">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
            <input type="hidden" name="pk" value="${material.pk}" />
            <label for="category">카테고리:</label>
            <input type="text" id="category" name="category" value="${material.category}" required><br>
            <label for="name">이름:</label>
            <input type="text" id="name" name="name" value="${material.name}" required><br>
            <label for="specification">규격:</label>
            <input type="text" id="specification" name="specification" value="${material.specification}" required><br>
            <label for="unit">단위:</label>
            <input type="text" id="unit" name="unit" value="${material.unit}"><br>
            <label for="price">가격:</label>
            <input type="number" id="price" name="price" value="${material.price}" required><br>
            <label for="stock">재고량:</label>
            <input type="number" id="stock" name="stock" value="${material.stock}" required><br>
            <label for="amount">금액:</label>
            <input type="number" id="amount" name="amount" value="${material.amount}" required><br>
            <button type="submit">저장</button>
        </form>
    </c:when>
    <c:when test="${not empty product}">
        <form action="/stock/editProduct" method="post">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
            <input type="hidden" name="pk" value="${product.pk}" />
            <label for="category">카테고리:</label>
            <input type="text" id="category" name="category" value="${product.category}" required><br>
            <label for="name">이름:</label>
            <input type="text" id="name" name="name" value="${product.name}" required><br>
            <label for="model">모델명:</label>
            <input type="text" id="model" name="model" value="${product.model}"><br>
            <label for="specification">규격:</label>
            <input type="text" id="specification" name="specification" value="${product.specification}" required><br>
            <label for="price">가격:</label>
            <input type="number" id="price" name="price" value="${product.price}" required><br>
            <label for="stock">재고량:</label>
            <input type="number" id="stock" name="stock" value="${product.stock}" required><br>
            <label for="amount">금액:</label>
            <input type="number" id="amount" name="amount" value="${product.amount}" required><br>
            <button type="submit">저장</button>
        </form>
    </c:when>
    <c:otherwise>
        <p>수정할 재고 정보가 없습니다.</p>
    </c:otherwise>
</c:choose>
<a href="/stock">목록으로</a>
</body>
</html>