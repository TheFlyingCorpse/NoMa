<?php

# COPYRIGHT:
#  
# This software is Copyright (c) 2007-2008 NETWAYS GmbH, Christian Doebler 
#                                <support@netways.de>
# 
# (Except where explicitly superseded by other copyright notices)
# 
# 
# LICENSE:
# 
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from http://www.fsf.org.
# 
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 or visit their web page on the internet at
# http://www.fsf.org.
# 
# 
# CONTRIBUTION SUBMISSION POLICY:
# 
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of
# the GNU General Public License and is only of importance to you if
# you choose to contribute your changes and enhancements to the
# community by submitting them to NETWAYS GmbH.)
# 
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with
# this Software, to NETWAYS GmbH, you confirm that
# you are the copyright holder for those contributions and you grant
# NETWAYS GmbH a nonexclusive, worldwide, irrevocable,
# royalty-free, perpetual, license to use, copy, create derivative
# works based on those contributions, and sublicense and distribute
# those contributions and any derivatives thereof.
#
# Nagios and the Nagios logo are registered trademarks of Ethan Galstad.

/**
 * getContent - main function for this module
 *
 * @param		none
 * @return		HTML content
 */
function getContent () {

	// get global variables
	global $authentication_type, $p, $logs;

	// init
	$cols = array (
		'rule' => 'NOTIFICATION_RULE',
		'stime' => 'TIMESTAMP',
		'check_type' => 'CHECK_TYPE',
		'status' => 'CHECK_RESULT',
		'host' => 'HOST',
		'service' => 'SERVICE',
		'method' => 'METHOD',
		'dest' => 'USER',
		'result' => 'RESULT'
	);
	$numresults = 10;
	$begin = 0;

	$templateContent = new nwTemplate(TEMPLATE_STATUS_VIEWER);


	// assign statics
	$templateContent->assign('LOG_VIEWER_OVERVIEW_LINK', LOG_VIEWER_OVERVIEW_LINK);
	$templateContent->assign('LOG_VIEWER_HEADING', LOG_VIEWER_HEADING);
	$templateContent->assign('LOG_VIEWER_FIND', LOG_VIEWER_FIND);
	$templateContent->assign('LOG_VIEWER_NUM_RESULTS', LOG_VIEWER_NUM_RESULTS);
	$templateContent->assign('LOG_VIEWER_HEADING_NOTIFICATION_RULE', LOG_VIEWER_HEADING_NOTIFICATION_RULE);
	$templateContent->assign('LOG_VIEWER_HEADING_TIMESTAMP', LOG_VIEWER_HEADING_TIMESTAMP);
	$templateContent->assign('LOG_VIEWER_HEADING_CHECK_TYPE', LOG_VIEWER_HEADING_CHECK_TYPE);
	$templateContent->assign('LOG_VIEWER_HEADING_HOST', LOG_VIEWER_HEADING_HOST);
	$templateContent->assign('LOG_VIEWER_HEADING_SERVICE', LOG_VIEWER_HEADING_SERVICE);
	$templateContent->assign('LOG_VIEWER_HEADING_CHECK_RESULT', LOG_VIEWER_HEADING_CHECK_RESULT);
	$templateContent->assign('LOG_VIEWER_HEADING_METHOD', LOG_VIEWER_HEADING_METHOD);
	$templateContent->assign('LOG_VIEWER_HEADING_USER', LOG_VIEWER_HEADING_USER);
	$templateContent->assign('LOG_VIEWER_HEADING_RESULT', LOG_VIEWER_HEADING_RESULT);
	$templateContent->assign('LOG_VIEWER_FIND_SUBMIT', LOG_VIEWER_FIND_SUBMIT);


	// set number of results and page
	$limit = null;
	if (isset($p['numresults']) || isset($p['p'])) {

		// determine count
		$numresults = (int)$p['numresults'];
		if (in_array($numresults, $logs['num_results'])) {
			$templateContent->assign('SELECTED_' . $p['numresults'], ' selected');
		} else {
			$numresults = 10;
		}

		// determine start
		$begin = (int)$p['p'];
		if ($begin < 0) $begin = 0;
		if ($begin > 0) $begin--;
		$begin = $begin * $numresults;

	}
	$limit = ' limit ' . $begin . ',' . $numresults;


	// set number-of-results select
	$templateContent->assign('NUM_RESULTS_SELECT', htmlSelect('numresults', $logs['num_results'], $numresults, 'onchange="javascript:document.fform.submit();"'));
	

	// restore find dialogue
	$find = null;
	if (!empty($p['find_value'])) {
		$find = $p['find_value'];
		$templateContent->assign('FIND_VALUE', $find);
	}


	// set filter
	$filter = null;
	if (!empty($find)) {

		$findPrep = prepareDBValue($find);

		$filter = 'where ';
		$sep = null;
		foreach ($cols as $col => $val) {
			$filter .= $sep . $col . ' like \'%%' . $findPrep . '%%\'';
			if (!$sep) $sep = ' or ';
		}

	}


	// set order by
	if (!isset($p['order_by'])) $p['order_by'] = 'id';
	if (array_key_exists($p['order_by'], $cols)) {
		$order_by = $p['order_by'];
	} else {
		$order_by = 'id';
	}

	// set order directory
	if (!isset($p['order_dir'])) $p['order_dir'] = 'desc';
	switch ($p['order_dir']) {
		case 'asc':
			$order_dir = 'asc';
			break;
		case 'desc':
		default:
			$order_dir = 'desc';
			break;
	}

	// set urls and image
	$qStr = getQueryString(array('order_by','order_dir'));
	foreach ($cols as $key => $value) {

		if ($order_by == $key) {

			if ($order_dir == 'asc') {
				$current_dir = 'desc';
				$image = '<img src="images/arrow_down.gif" alt="down" border="0"/>';
			} else {
				$current_dir = 'asc';
				$image = '<img src="images/arrow_up.gif" alt="up" border="0"/>';
			}

		} else {

			$current_dir = 'desc';
			$image = null;

		}

		$url = 'index.php?' . $qStr . '&amp;order_by=' . $key . '&amp;order_dir=' . $current_dir;

		$templateContent->assign('LINK_SORT_' . $value, $url);
		if (!empty($image)) $templateContent->assign('SORT_IMAGE_' . $value, $image);

	}



	// set base query
	$query = 'select %s from tmp_active as a left join tmp_commands as c on a.command_id=c.id ' . $filter . ' %s union select %s from escalation_stati';


	// get complete count
	$dbResult = queryDB(sprintf($query, 'count(*) cnt', '', 'count(*) cnt'));
	$allCount = $dbResult[0]['cnt'];
	if (defined($dbResult[1]['cnt']))
	{
		$allCount+=$dbResult[1]['cnt'];
	} else {
		$allCount*=2;
	}

	// get logs
	$query = sprintf(
		$query . ' order by %s %s',
		'a.id as id,dest,time_string,method,notify_cmd,retries,rule, host,host_alias,service,check_type,status,a.stime as stime,notification_type,concat("ACTIVE ",retries) as result ',
		null,
		'id,"" as dest,time_string,"(internal escalation)" as method,"" as notify_cmd, counter as retries,notification_rule as rule,host,host_alias,service,check_type,status,starttime as stime,type as notification_type,concat("ESC ",counter) as result',
		$order_by,
		$limit
	);
	list($resultCount, $dbResult) = queryDB($query, true);


	if (!empty($p['p'])) {
		$p['p'] = 10;
	}
	// get page navigation
	$templateContent->assign('PAGE_NAVIGATION', getPageNavi($allCount, $resultCount, $numresults, (int)$p['p'], $find));


	// assign logs
	$content = null;
	$rowDark = true;
	foreach ($dbResult as $row) {

		$templateSubContent = new nwTemplate(TEMPLATE_LOG_VIEWER_ROW);

		// set and toggle row background
		$rowClass = ($rowDark) ? 'row' : 'row-light';
		$templateSubContent->assign('ROW_CLASS', $rowClass);
		$rowDark = ($rowDark) ? false : true;

		$templateSubContent->assign('NOTIFICATION_RULE', $row['rule']);
		$templateSubContent->assign('TIMESTAMP', date('D d.m H:i:s', $row['stime']));
		$templateSubContent->assign('CHECK_TYPE', $row['check_type']);
		$templateSubContent->assign('HOST', $row['host']);
		$templateSubContent->assign('SERVICE', $row['service']);
		$templateSubContent->assign('STATUS', $row['status']);
		$templateSubContent->assign('METHOD', $row['method']);
		$templateSubContent->assign('USER', $row['dest']);
		$templateSubContent->assign('RESULT', $row['result']);

		$content .= $templateSubContent->getHTML();

	}

	$templateContent->assign('LOG_ROWS', $content);

	// assign order and page to form
	$templateContent->assign('ORDER_BY', $order_by);
	$templateContent->assign('ORDER_DIR', $order_dir);
	$templateContent->assign('PAGE', (isset($p['p'])) ? $p['p'] : '1');
	


	return $templateContent->getHTML();

}




/**
 * getPageNavi - generates html content for the page navigation
 *
 * @param		integer		$allCount			total number of rows
 * @param		integer		$resultCount		number of found results
 * @param		integer		$resultsPerPage		number of results per page
 * @param		integer		$page				page number
 * @param		string		$find				find value of search dialogue
 * @return		html content
 */
function getPageNavi ($allCount, $resultCount, $resultsPerPage, $page = null, $find = null) {

	global $logs;

	// init
	$content = null;


	// calculate total number of pages
	$numPages = (int)($allCount / $resultsPerPage);
	if ($allCount % $resultsPerPage) $numPages++;

	// set default page
	if (empty($page)) $page = 1;


	// calculate interval of pages to display in navigation
	if ($page > $logs['pages_per_line']) {

		$start = $page;
		if (!($start % $logs['pages_per_line'])) $start--;
		while ($start % $logs['pages_per_line']) $start--;
		$start++;

		if ($numPages > $start + $logs['pages_per_line'] - 1) {
			$end = $start + $logs['pages_per_line'] - 1;
		} else {
			$end = $numPages;
		}

		// add default link for first page
		$href = 'index.php?action=status&amp;numresults=' . $resultsPerPage . '&amp;p=1';
		if (!empty($find)) $href .= '&amp;find_value=' . $find;
		$content .= htmlA($href, '&lt;&lt;', 'class="textLink"') . '&nbsp;';

		// add default link for previous page (before first page of navigation)
		$href = 'index.php?action=status&amp;numresults=' . $resultsPerPage . '&amp;p=' . ($start - 1);
		if (!empty($find)) $href .= '&amp;find_value=' . $find;
		$content .= htmlA($href, '&lt;', 'class="textLink"') . '&nbsp;';

	} else {

		$start = 1;

		if ($numPages > $logs['pages_per_line']) {
			$end = $logs['pages_per_line'];
		} else {
			$end = $numPages;
		}

	}


	// generate main navigation
	for ($x = $start; $x <= $end; $x++) {

		if ($x != $start) $content .= '&nbsp;';

		if ($x == $page) {
			$content .= '<b>' . $x . '</b>';
		} else {
			$href = 'index.php?' . getQueryString('p') . '&amp;p=' . $x;
			$content .= htmlA($href, $x, 'class="textLink"');
		}

		if ($x != $end) $content .= '&nbsp;';

	} 


	// add end links
	if ($end < $numPages) {

		$content .= '&nbsp;';

		// add link for next page (after last page of navigation)
		$href = 'index.php?action=status&amp;numresults=' . $resultsPerPage . '&amp;p=' . ($end + 1);
		if (!empty($find)) $href .= '&amp;find_value=' . $find;
		$content .= htmlA($href, '&gt;', 'class="textLink"') . '&nbsp;';
		
		// add link for last page
		$href = 'index.php?action=status&amp;numresults=' . $resultsPerPage . '&amp;p=' . $numPages;
		if (!empty($find)) $href .= '&amp;find_value=' . $find;
		$content .= htmlA($href, '&gt;&gt;', 'class="textLink"') . '&nbsp;';

	}


	return htmlTr(htmlTd($content, 'align="center" colspan="9"'));

}


?>
