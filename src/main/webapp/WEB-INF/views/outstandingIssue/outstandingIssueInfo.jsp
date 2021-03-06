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
	<div id="outstandingIssueForm" style="padding:15px">
		<table border="0" style="width: 100%">
			<tr>
				<td style="text-align: right;"><label for="outstandingIssueId">编号：
				</label></td>
				<td><input id="outstandingIssueId" name="outstandingIssueId"
					class="mini-textbox" style="width:300px;" allowInput="false" /></td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td style="text-align: right;"><label for="user">录入人员：
				</label></td>
				<td><input id="userTrueName" name="user.trueName"
					class="mini-textbox" style="width:300px;" allowInput="false" /></td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td style="text-align: right;"><label for="department">部门：
				</label></td>
				<td><input id="departmentName" name="department.name"
					class="mini-textbox" style="width:300px;" allowInput="false" /></td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td style="text-align: right;"><label for="team">小组： </label></td>
				<td><input id="teamName" name="team.name" class="mini-textbox"
					style="width:300px;" allowInput="false" /></td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td style="text-align: right;"><label for="project">项目：
				</label></td>
				<td><input id="projectName" name="project.projectName"
					class="mini-textbox" style="width:300px;" allowInput="false" /></td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td style="text-align: right;"><label for="issueId">关联bugID：
				</label></td>
				<td><input id="issueId" name="issueId" class="mini-textbox"
					allowInput="false" style="width:300px;" /></td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td style="text-align: right;"><label for="issueDescription">问题描述：
				</label></td>
				<td><input id="issueDescription" name="issueDescription"
					class="mini-textarea" allowInput="false"
					style="width:300px;height:100px;" /></td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td style="text-align: right;"><label for="resolveStatusText">解决状态：
				</label></td>
				<td><input id="resolveStatusText" name="resolveStatusText"
					class="mini-textbox" style="width:300px;" allowInput="false" /></td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td style="text-align: right;"><label for="remarkDetail">备注：
				</label></td>
				<td><input id="remarkDetail" name="remarkDetail"
					class="mini-textarea" allowInput="false"
					style="width:300px;height:150px;" /></td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td style="text-align: right;"><label for="createTime">录入时间：
				</label></td>
				<td><input id="createTime" name="createTime"
					class="mini-textbox" style="width:300px;" allowInput="false" /></td>
				<td>&nbsp;</td>
			</tr>
		</table>
		<div class="mini-toolbar"
			style="text-align:center;padding-top:8px;padding-bottom:8px;"
			borderStyle="border:0;">
			<a class="mini-button" style="width:71px;" onclick="onEdit">确定</a>
		</div>
	</div>
	<script type="text/javascript">
		mini.parse();
		var form = new mini.Form('outstandingIssueForm');

		//初始化表单数据
		function init(outstandingIssueId) {
			$
					.ajax({
						url : '<%=basePath%>outstandingIssue/outstandingIssueInfo.json',
						type : 'get',
						data : {
							outstandingIssueId : outstandingIssueId
						},
						success : function(data) {
							form.setData(data.data);
						},
						dataType : 'json'
					});
		}

		function onEdit(e) {
			closeWindow('ok');
		}
	</script>
</body>
</html>
