var type = "normal";
$(document).ready(function () {
	var table1 = $('#table1').DataTable();
	var PlayerID = false;
	var isGang = false;
	$("body").on("keyup", function (key) {
		if (Config.closeKeys.includes(key.which)) {
			CloseUI();
		}
	});
		
	window.addEventListener("message", function (event) {
		if (event.data.action == "display") {
			type = event.data.type
			showMain();
			table1.clear().draw();
			$(".ui").fadeIn();
			$(".mainpage").show();
			$(".playerPage").hide();
			
			isGang = event.data.isGang;
			
			$.each(event.data.players, function (index, player) {
				table1.row.add([player.name, player.grade_label , "<button class='btn btn-sm btn-info viewplayerbtn' data-player='" + player.identifier + "'>مدیریت</button>"]).draw().node();
			});
			
		} else if (event.data.action == "hide") {
			$(".ui").fadeOut();
		} else if (event.data.action == "showplayer") {
			$(".mainpage").hide();
			$(".playerPage").show();
			PlayerID = event.data.playerData.identifier;
			
			$(".firstname").html("-");
			$(".lastname").html("-");
			$(".job_grade").html("-");
			$(".job_sub").html("-");
			$(".ShowSubJob").hide();
			
			$(".firstname").html(event.data.playerData.firstname);
			$(".lastname").html(event.data.playerData.lastname);
			$(".job_grade").html(event.data.playerData.job_grade);
			
			gradeList = '<option value="-">اخراج</option>';
			JobSubsList = '<option value="-">بدون زیرمجموعه</option>';
			
			$.each(event.data.playerData.JobGrades, function(key, data) {
				gradeList += '<option value="' + data.grade + '"';
				
				
				if (event.data.playerData.job_grade == data.grade) {
					gradeList += ' selected="selected"';
				}
				
				gradeList += '>' + data.label_fa + '</option>';
			});
			
			HTMLs = '<select class="form-select Grades" style="margin: 5px auto 10px auto; max-width: 350px">' + gradeList + '</select>';
			
			if (isGang == false) {
				$(".ShowSubJob").show();
				$(".job_sub").html(event.data.playerData.job_sub);
				$.each(event.data.playerData.JobSubs, function(key, data) {
					JobSubsList += '<option value="' + data.job_sub + '"';
					
					if (event.data.playerData.job_sub == data.job_sub) {
						JobSubsList += ' selected="selected"';
					}
					
					JobSubsList += '>' + data.label + '</option>';
				});
				
				HTMLs += '<select class="form-select Subs" style="margin: 5px auto 10px auto; max-width: 350px">' + JobSubsList + '</select>';
			}
			
			HTMLs += '<button class="btn btn-sm btn-success savechanges">ذخیره تغییرات</button>';
			$(".ManageJob").html(HTMLs);
		}
	});

	
	function showMain() {
		$(".ui").fadeIn();
	}

	function CloseUI() {
		$(".ui").fadeOut();
		$.post("https://master_society/NUIFocusOff", JSON.stringify({}));
	}
	
	$(document).on('click', '.backtomain', function(e) {
		$(".mainpage").show();
		$(".playerPage").hide();
	});
	
	$(document).on('click', '.viewplayerbtn', function(e) {
		var player = $(this).data('player');
		$.post("https://master_society/getPlayerInfo", JSON.stringify({
			player: player
		}));
	});
	
	$(document).on('click', '.savechanges', function(e) {
		NewGrade = $('.Grades').val();
		newSub = ''
		
		if (isGang == false) {
			newSub = $('.Subs').val();
		}
		
		$.post("https://master_society/saveChanges", JSON.stringify({
			player: PlayerID,
			grade: NewGrade,
			sub: newSub
		}));
	});
	
	$(document).on('click', '.invitetoJob', function(e) {
		userid = $('#userid').val();
		$.post("https://master_society/InviteToJob", JSON.stringify({
			xTarget: userid
		}));
	});
	
});
