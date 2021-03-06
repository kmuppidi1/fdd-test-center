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
<title>质量管理平台</title>
<script type="text/javascript" src="<%=basePath%>scripts/boot.js"></script>
</head>
<body>
	<div id="searchForm">
		<table>
			<tr>
				<td style="text-align: left;"><label for="department">部门：</label>
					<input id="departmentId" name="departmentId"
					class="mini-combobox"
					url="<%=basePath%>department/departmentListAll.json"
					dataField="data" valueField="departmentId" textField="name" allowInput="true"
					emptyText="支持按部门查询" style="width: 120px;"
					onvaluechanged="onDepartmentChanged" /></td>
				<td style="text-align: left;"><label for="team">小组：</label> <input
					id="teamId" name="teamId" class="mini-combobox"
					url="<%=basePath%>team/teamListByDepartmentId.json"
					dataField="data" valueField="teamId" textField="name" allowInput="true"
					emptyText="支持按小组查询" style="width: 120px;" onvaluechanged="onTeamChanged" /></td>
				<td style="text-align: left;"><label for="project">项目：</label>
					<input id="projectId" name="sonarProjectId" class="mini-combobox"
					url="<%=basePath%>sonarProject/enabledSonarProjectListByDepartmentId.json"
					dataField="data" valueField="id" textField="projectName" allowInput="true"
					emptyText="支持按项目查询" style="width: 120px;" /></td>
				<td style="text-align: left;"><label for="statisticType">统计类型：</label>
					<input id="statisticType" name="statisticType"
					class="mini-combobox"
					url="<%=basePath%>sonarStatistic/statisticTypeList.json"
					dataField="data" valueField="statisticType" textField="statisticTypeText"
					allowInput="true" valueFromSelect="false" emptyText="支持按统计类型查询"
					style="width: 140px;" /></td>
			</tr>
		</table>
	</div>

	<div id="actionTb" class="mini-toolbar">
		<table style="width: 100%;">
			<tr>
				<td><a class="mini-button" iconCls="icon-search"
					style="width: 65px;" onclick="showChart">查看</a> <a
					class="mini-button" iconCls="icon-cancel" style="width: 65px;"
					onclick="onCancel">重置</a></td>
			</tr>
		</table>
	</div>

	<div class="mini-fit">
		<div id="chart" style="width: 100%; height: 480px;"></div>
	</div>

	<script src="<%=basePath%>scripts/chart/echarts.min.js"
		type="text/javascript"></script>
	<script type="text/javascript">
	mini.parse();
	var form = new mini.Form('searchForm');
	var department = mini.get("departmentId");
	var team = mini.get("teamId");
	var project = mini.get("projectId");
	var statisticType = mini.get("statisticType");
	function setDefaultValue() {
		if (isEmpty(department.getValue())) {
			department.setValue(0);
		}
		if (isEmpty(team.getValue())) {
			team.setValue(0);
		}
		if (isEmpty(project.getValue())) {
			project.setValue(0);
		}
		if (isEmpty(statisticType.getValue())) {
			statisticType.setValue(0);
		}
	}
	
	function resetDefaultValue() {
		if (isEmpty(department.getValue())) {
			department.setValue();
		}
		if (isEmpty(team.getValue())) {
			team.setValue();
		}
		if (isEmpty(project.getValue())) {
			project.setValue();
		}
		if (isEmpty(statisticType.getValue())) {
			statisticType.setValue();
		}
	}

	showChart();

	function showChart(e) {
		setDefaultValue();
		if(project.getValue()==null || project.getValue()<=0){
			project.select(0);
		}
		if(statisticType.getValue()==null || statisticType.getValue()<=0){
			statisticType.setValue(1);
		}
		// 基于准备好的dom，初始化echarts实例
		var myChart = echarts.init(document.getElementById('chart'));
		var messageId = mini.loading('处理中，请稍等......', '提示');
		$
				.ajax({
					url : '<%=basePath%>sonarStatistic/projectSonarStatisticLineChart.json',
					type : 'post',
					data : form.getData(true, false),
					success : function(data) {
						mini.hideMessageBox(messageId);
						myChart.setOption(data.data);
					},
					dataType : 'json'
				});
		resetDefaultValue();
	}

	function onCancel() {
		var teamUrl = '<%=basePath%>team/teamListByDepartmentId.json';
		team.setUrl(teamUrl);
		var projectUrl = '<%=basePath%>sonarProject/enabledSonarProjectListByDepartmentId.json';
		project.setUrl(projectUrl);
		form.reset();
	}
		
		function onDepartmentChanged(e) {
            var departmentId=department.getValue();
            team.setValue();
            var url="<%=basePath%>team/teamListByDepartmentId.json?departmentId="+departmentId;
            team.setUrl(url);
		}
		
		function onTeamChanged(e) {
            var teamId=team.getValue();
            project.setValue();
            var url="<%=basePath%>sonarProject/enabledSonarProjectListByTeamId.json?teamId="+teamId;
            project.setUrl(url);
		}
	</script>
</body>
</html>