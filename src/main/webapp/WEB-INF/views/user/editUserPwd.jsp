<%@ page language="java" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>美利金融质量管理平台</title>
<script type="text/javascript" src="<%=basePath%>scripts/boot.js"></script>
</head>

<body>
	<div id="editForm" style="padding:15px">
		<table border="0" style="width: 100%">
			<tr>
				<td><input id="userId" name="userId" class="mini-hidden" /></td>
			</tr>
			<tr>
				<td style="text-align: right;"><label for="password">新登录密码<span
						style="color:red">(*)</span>：
				</label></td>
				<td><input id="password" name="password" class="mini-password"
					emptyText="请输入新登录密码" required="true" onvalidation="onValidation"
					errorMode="none" requiredErrorText="新登录密码不能为空" style="width:300px;" /></td>
				<td><div id="password_error"></div></td>
				<td>&nbsp;</td>
			</tr>
		</table>
	</div>
	<div class="mini-toolbar"
		style="text-align:center;padding-top:8px;padding-bottom:8px;"
		borderStyle="border:0;">
		<a class="mini-button" iconCls="icon-edit" style="width:71px;"
			onclick="onEdit">重置</a> <span style="display:inline-block;width:25px"></span>
		<a class="mini-button" iconCls="icon-cancel" style="width:71px;"
			onclick="onCancel">取消</a>
	</div>
	<script type="text/javascript">
		mini.parse();
		var form = new mini.Form('editForm');

		var _data;
		//初始化表单数据
		function init(userId) {
			$.ajax({
				url : '<%=basePath%>user/userInfo.json',
				type : 'get',
				data : {
					userId : userId
				},
				success : function(data) {
					_data = data.data;
					var userId = mini.get('userId');
					userId.setValue(data.data.userId);
				},
				dataType : 'json'
			});
		}

		function onEdit(e) {
			form.validate();
			if (form.isValid() == false)
				return;

			var messageId = mini.loading('处理中，请稍等......', '提示');

			$.ajax({
				url : '<%=basePath%>user/editUserPwd.json',
				type : 'post',
				data : form.getData(true, false),
				success : function(data) {
					mini.hideMessageBox(messageId);
					if (data.code==200 && data.data) {
						closeWindow('ok');
					} else {
						closeWindow(data.msg);
					}
				},
				dataType : 'json'
			});
		}

		function onCancel() {
			closeWindow('close');
		}
	</script>
</body>
</html>
