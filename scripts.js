// Tracks the Ajax call being most recently requested, used to ignore older results
var AjaxID=0;
var KeyTimer;
$(document).ready(function() {
	// Add debounce timer on search code function
	$('#searchcode').on('keyup', function(event) {
		clearTimeout(KeyTimer);
		if ($(this).val().length < 3) {
			if (typeof $.ui.fancetree !== 'undefined') {
				$.ui.fancetree.getTree('#tree').clearFilter();
				return;
			}
		}
		if (event.key === "Enter" || event.which === 13) {
			SearchCode($(this).val());
		} else {
			KeyTimer=setTimeout(() => {
				SearchCode($(this).val());
			}, 1500);
		}
	});

	function SearchCode(query) {
		if (query.length > 2) { // Limit searches to 3 or more searches
			document.getElementById('search').value=''; // Clear obj field
			document.getElementById('loading').style.display='block'; // Show loading gif
			AjaxID++;
			var FetchAjaxID=AjaxID;
			$.ajax({
				url: 'SearchCode.cfm',
				method: 'GET',
				data: { search: query },
				success: function(Keys) {

					// Only process the results if AjaxID matches the most recent ID this call was for
					if (AjaxID == FetchAjaxID) {
						// Hide loading gif
						document.getElementById('loading').style.display='none';
						// Update tree filter
						$.ui.fancytree.getTree("#tree").filterNodes(function(node) {
							return Keys.includes(node.key);
						})
					};
				}
			});
		} else {
			$.ui.fancytree.getTree('#tree').clearFilter();
		}
	};

	// Add click events to buttons
	document.getElementById('ClearObj').addEventListener('click', function() {
		document.getElementById('search').value='';
		$.ui.fancytree.getTree('#tree').clearFilter();
	});
	document.getElementById('ClearSearch').addEventListener('click', function() {
		document.getElementById('searchcode').value='';
		$.ui.fancytree.getTree('#tree').clearFilter();
	});
	// Add OnKeyUp events to search boxes
	document.getElementById('search').addEventListener('keyup', function() {
		document.getElementById('searchcode').value=''; // Clear code field
		$.ui.fancytree.getTree('#tree').filterNodes(this.value);
	});

	ShowTree();
});

function ShowTree() {
	$("#tree").fancytree({
		extensions: ["filter"],
		// Define filter-extension options:
		filter: {
			autoExpand: true,
			highlight: false,
			leavesOnly: true,
			mode: "hide",
			nodata: true
		},
		click: function(event, data) {
			var ID=data.node.key;
			if (ID.substr(0,1) == 'P') ViewCode(ID);
		},
		activate: function(event, data) {
			var ID=data.node.key;
			if (ID.substr(0,1) == 'P') ViewCode(ID);
		},
		source: Code
	});
};	

function ViewCode(ViewID) {
	var SearchKey=document.getElementById('searchcode').value;
	// Update cookie of ID's viewed (LIFO)
	var BackIDList=getCookie('BACKID');
	// Get last item to check for duplicate
	var LastID=BackIDList.split(',').pop();
	if (LastID != ViewID) {
		BackIDList=BackIDList + ',' + ViewID;
		// Limit history to 30 ID's max to keep in cookie max slize
		if (BackIDList.split(',').length > 31) BackIDList=BackIDList.split(',').slice(1).join(',');
		// Update Cookie
		setCookie('BACKID',BackIDList);
	}
	// Pull object
	$('#code').html('Loading...');
	$.ajax({
		url: 'View.cfm',
		method: 'GET',
		data: {ID:ViewID,SearchKey:SearchKey},
		success: function(data) {
			$('#code').html(data); // Display the code
		}
	});
};

function GoBack() {
	// Fetch Preview ID viewed (LIFO)
	var BackIDArray=getCookie('BACKID').split(',');
	var ViewID=BackIDArray.pop();
	// Update cookie
	var BackIDList=BackIDArray.join(',');
	setCookie('BACKID',BackIDList);
	// Pull object
	$('#code').html('Loading...');
	$.ajax({
		url: 'View.cfm',
		method: 'GET',
		data: {ID:ViewID},
		success: function(data) {
			$('#code').html(data); // Display the code
		}
	});
}


// Helper to get a cookie by name
function getCookie(name) {
	const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
	return match ? decodeURIComponent(match[2]) : null;
}

// Helper to set a cookie
function setCookie(name, value) {
	document.cookie = `${name}=${encodeURIComponent(value)}; path=/`;
}
