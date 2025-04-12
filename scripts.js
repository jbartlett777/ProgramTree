// Tracks the Ajax call being most recently requested, used to ignore older results
var AjaxID=0;

$(document).ready(function() {
	$('#searchcode').on('keyup', function() {
		let query = $(this).val();
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
	});

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
		source: Code
	});
};	

function ViewCode(ID) {
	$.ajax({
		url: 'View.cfm',
		method: 'GET',
		data: {ID:ID},
		success: function(data) {
			$('#code').html(data); // Display the code
		}
	});
};
