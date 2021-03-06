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
<title>房多多质量管理平台</title>
<script type="text/javascript" src="<%=basePath%>scripts/boot.js"></script>
</head>

<body>
	<div id="addForm" style="padding:15px">
		<table border="0" style="width: 100%">
			<tr>
				<td style="text-align: right;"><label for="name">部门名称<span
						style="color:red">(*)</span>：
				</label></td>
				<td><input id="name" name="name" class="mini-textbox"
					emptyText="请输入部门名称" vtype="remote" required="true" onvalidation="onValidation"
					errorMode="none" requiredErrorText="部门名称不能为空" style="width:300px;"/></td>
				<td><div id="name_error"></div></td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td style="text-align: right;"><label for="remark">备注：
				</label></td>
				<td><input id="remark" name="remark" class="mini-textbox" style="width:300px;"/></td>
				<td><div id="remark_error"></div></td>
				<td>&nbsp;</td>
			</tr>
		</table>
	</div>
	<div class="mini-toolbar"
		style="text-align:center;padding-top:8px;padding-bottom:8px;"
		borderStyle="border:0;">
		<a class="mini-button" iconCls="icon-add" style="width:71px;"
			onclick="onAdd">添加</a> <span style="display:inline-block;width:25px"></span>
		<a class="mini-button" iconCls="icon-cancel" style="width:71px;"
			onclick="onCancel">取消</a>
	</div>
	<script type="text/javascript">
		mini.parse();
		var form = new mini.Form('addForm');
		
		/*自定义vtype*/
		mini.VTypes["remoteErrorText"] = "部门已经存在，请更换";
		mini.VTypes["remote"] = function(name) {
			var flag = false;
			$
					.ajax({
						async : false,/*同步请求*/
						url : '<%=basePath%>department/existDepartment.json',
						type : 'post',
						data : {
							name : name
						},
						success : function(data) {
							flag = data.data;
						},
						dataType : 'json'
					});
			return flag;
		};

		function onAdd(e) {
			form.validate();
			if (form.isValid() == false)
				return;

			var messageId = mini.loading('处理中，请稍等......', '提示');

			$
					.ajax({
						url : '<%=basePath%>department/addDepartment.json',
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
			return;
		}
	</script>
</body>
</html>
