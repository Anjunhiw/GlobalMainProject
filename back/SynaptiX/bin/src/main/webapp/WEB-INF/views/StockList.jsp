<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title>재고관리</title>
    <style>
        table { border-collapse: collapse; width: 100%; margin-bottom: 30px; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: center; }
        th { background: #f0f0f0; }
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0; top: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5);
        }
        .modal-content {
            background: #fff;
            margin: 10% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80%;
        }
        .close {
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
    </style>
    <script>
        function openModal() {
            document.getElementById('resultModal').style.display = 'block';
        }
        function closeModal() {
            document.getElementById('resultModal').style.display = 'none';
        }
        function searchData() {
            var category = document.getElementById('searchType').value;
            var name = document.getElementById('searchName').value;
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'searchStock', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    document.getElementById('modalResultBody').innerHTML = xhr.responseText;
                    openModal();
                }
            };
            xhr.send('category=' + encodeURIComponent(category) + '&name=' + encodeURIComponent(name));
        }
    </script>
</head>
<body>
    <h2>재고관리 검색</h2>
    <form id="searchForm" onsubmit="event.preventDefault(); searchData();">
        <label for="searchType">카테고리:</label>
        <select id="searchType" name="category">
            <option value="material">원자재</option>
            <option value="product">제품</option>
        </select>
        <label for="searchName">이름:</label>
        <input type="text" id="searchName" name="name" placeholder="이름 입력">
        <button type="submit">검색</button>
    </form>

    <!-- 검색 결과 모달 -->
    <div id="resultModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">&times;</span>
            <h3>검색 결과</h3>
            <div id="modalResultBody">
                <!-- Ajax 결과 테이블이 여기에 표시됨 -->
            </div>
        </div>
    </div>

    <h2>원자재 재고 목록</h2>
    <table>
        <thead>
            <tr>
                <th>PK</th>
                <th>카테고리</th>
                <th>원자재명</th>
                <th>규격</th>
                <th>단위</th>
                <th>가격</th>
                <th>재고량</th>
                <th>입고금액</th>
                <th>관리</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="material" items="${materials}">
                <tr>
                    <td>${material.pk}</td>
                    <td>${material.category}</td>
                    <td>${material.name}</td>
                    <td>${material.specification}</td>
                    <td>${material.unit}</td>
                    <td><fmt:formatNumber value="${material.price}" type="number" groupingUsed="true"/></td>
                    <td><fmt:formatNumber value="${material.stock}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
                    <td><fmt:formatNumber value="${material.amount}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
                    <td>
                        <form action="/stock/edit" method="get" style="display:inline;">
                            <input type="hidden" name="pk" value="${material.pk}" />
                            <input type="hidden" name="category" value="material" />
                            <button type="submit">수정</button>
                        </form>
                        <form action="/stock/delete" method="post" style="display:inline;" onsubmit="return confirm('정말 삭제하시겠습니까?');">
                            <input type="hidden" name="pk" value="${material.pk}" />
                            <input type="hidden" name="category" value="material" />
                            <button type="submit">삭제</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <h2>제품 재고 목록</h2>
    <table>
        <thead>
            <tr>
                <th>PK</th>
                <th>카테고리</th>
                <th>제품명</th>
                <th>모델명</th>
                <th>규격</th>
                <th>단가</th>
                <th>재고량</th>
                <th>재고금액</th>
                <th>관리</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="product" items="${products}">
                <tr>
                    <td>${product.pk}</td>
                    <td>${product.category}</td>
                    <td>${product.name}</td>
                    <td>${product.model}</td>
                    <td>${product.specification}</td>
                    <td><fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"/></td>
                    <td><fmt:formatNumber value="${product.stock}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
                    <td><fmt:formatNumber value="${product.amount}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
                    <td>
                        <form action="/stock/edit" method="get" style="display:inline;">
                            <input type="hidden" name="pk" value="${product.pk}" />
                            <input type="hidden" name="category" value="product" />
                            <button type="submit">수정</button>
                        </form>
                        <form action="/stock/delete" method="post" style="display:inline;" onsubmit="return confirm('정말 삭제하시겠습니까?');">
                            <input type="hidden" name="pk" value="${product.pk}" />
                            <input type="hidden" name="category" value="product" />
                            <button type="submit">삭제</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</body>
</html>