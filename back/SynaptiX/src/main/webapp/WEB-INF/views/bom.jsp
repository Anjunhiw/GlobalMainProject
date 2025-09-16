<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
request.setAttribute("pageTitle", "BOM 관리");
%>
<%
request.setAttribute("subNav", "<a href='/bom'>BOM</a> <a href='/mps'>MPS</a> <a href='/qc'>QC</a>");
%>
<%@ include file="header.jsp" %>
    <h2>BOM List</h2>
    <!-- 검색 폼 수정: 카테고리 선택 -->
    <form method="get" action="/bom">
        <label for="category">카테고리:</label>
        <select id="category" name="category">
            <option value="">전체</option>
            <option value="제품">제품</option>
            <option value="원자재">원자재</option>
        </select>
        <label for="name">품명:</label>
        <input type="text" id="name" name="name" />
        <label for="id">품목 ID:</label>
        <input type="text" id="id" name="id" />
        <button type="submit">검색</button>
    </form>
    <br/>
    <button type="button" onclick="openBomPopup()">등록</button>
    <script>
    function openBomPopup() {
        var popup = window.open('', 'BOM 등록', 'width=400,height=400');
        popup.document.write(`
            <html>
            <head><title>BOM 등록</title></head>
            <body>
                <h3>BOM 등록</h3>
                <form id='bomForm'>
                    <label for='productId'>ProductID:</label>
                    <input type='number' id='productId' name='productId' required><br/>
                    <label for='materialId'>MaterialID:</label>
                    <input type='number' id='materialId' name='materialId' required><br/>
                    <label for='materialAmount'>MaterialAmount:</label>
                    <input type='number' step='0.01' id='materialAmount' name='materialAmount' required><br/>
                    <button type='button' onclick='window.opener.submitBomForm(this.form);window.close();'>등록</button>
                    <button type='button' onclick='window.close();'>취소</button>
                </form>
            </body>
            </html>
        `);
    }
    function submitBomForm(form) {
        var data = {
            productId: form.productId.value,
            materialId: form.materialId.value,
            materialAmount: form.materialAmount.value
        };
        fetch('/bom', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        }).then(res => {
            if(res.ok) {
                alert('등록 완료');
                location.reload();
            } else {
                alert('등록 실패');
            }
        });
    }
    </script>
    <table border="1">
        <tr>
            <th>ProductID</th>
            <th>제품명</th>
            <th>MaterialID</th>
            <th>원자재명</th>
            <th>MaterialAmount</th>
            <th>수정</th>
        </tr>
        <c:forEach var="bom" items="${bomList}">
            <tr>
                <td>${bom.productId}</td>
                <td>
                    <c:forEach var="product" items="${productList}">
                        <c:if test="${product.pk == bom.productId}">
                            ${product.name}
                        </c:if>
                    </c:forEach>
                </td>
                <td>${bom.materialId}</td>
                <td>
                    <c:forEach var="material" items="${materialList}">
                        <c:if test="${material.pk == bom.materialId}">
                            ${material.name}
                        </c:if>
                    </c:forEach>
                </td>
                <td>${bom.materialAmount}</td>
                <td>
                    <button type="button" onclick="openBomEditPopup(
                        encodeURIComponent('${bom.productId}'),
                        encodeURIComponent('${bom.materialId}'),
                        encodeURIComponent('${bom.materialAmount != null ? bom.materialAmount : ''}')
                    )">수정</button>
                </td>
            </tr>
        </c:forEach>
    </table>
    <script>
    function openBomEditPopup(productId, materialId, materialAmount) {
        var popup = window.open('', 'BOM 수정', 'width=400,height=400');
        popup.document.write(`
            <html>
            <head><title>BOM 수정</title></head>
            <body>
                <h3>BOM 수정</h3>
                <form id='bomEditForm'>
                    <label for='productId'>ProductID:</label>
                    <input type='number' id='productId' name='productId' readonly><br/>
                    <label for='materialId'>MaterialID:</label>
                    <input type='number' id='materialId' name='materialId' readonly><br/>
                    <label for='materialAmount'>MaterialAmount:</label>
                    <input type='number' step='0.01' id='materialAmount' name='materialAmount' required><br/>
                    <button type='button' onclick='window.opener.submitBomEditForm(this.form);window.close();'>수정</button>
                    <button type='button' onclick='window.close();'>취소</button>
                </form>
            </body>
            </html>
        `);
        // 팝업이 열린 후 input value를 직접 설정
        setTimeout(function() {
            if (popup.document.getElementById('productId')) {
                popup.document.getElementById('productId').value = productId;
                popup.document.getElementById('materialId').value = materialId;
                popup.document.getElementById('materialAmount').value = materialAmount;
            }
        }, 100);
        popup.document.close();
    }
    function submitBomEditForm(form) {
        var data = {
            productId: form.productId.value,
            materialId: form.materialId.value,
            materialAmount: form.materialAmount.value
        };
        fetch('/bom', {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        }).then(res => {
            if(res.ok) {
                alert('수정 완료');
                location.reload();
            } else {
                alert('수정 실패');
            }
        });
    }
    </script>
<%@ include file="footer.jsp" %>