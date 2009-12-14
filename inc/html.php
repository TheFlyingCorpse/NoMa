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


function htmlSelect ($name, $list, $checked = null, $params = null, $first = null) {
	$html = '<select name="' . $name . '"' . (($params) ? (' ' . $params) : null) . '>' . "\n";
	if (is_array($first)) {
		$html .= '<option value="' . $first[0] . '">' . $first[1] . '</option>' . "\n";
	}
	foreach ($list as $value => $label) {
		$checkedStr = null;
		if (is_array($checked)) {
			 if (in_array($value, $checked)) $checkedStr = ' selected="selected"'; 
		} elseif ($checked == $value) {
			$checkedStr = ' selected="selected"';
		}
		$html .= '<option value="' . $value . '"' . $checkedStr . '>' . $label . '</option>' . "\n";
	}
	$html .= '</select>' . "\n";
	return $html;
}


function htmlInput ($name, $type = null, $value = null, $params = null) {
	if (empty($type)) $type = "text";
	$html = '<input name="' . $name . '" type="' . $type . '"';
	if (!empty($value)) $html .= ' value="' . $value . '"';
	if (!empty($params)) $html .= ' ' . $params;
	$html .= '/>';
	return $html;
}


function htmlA ($href, $label, $params = null) {
	$html = '<a href="' . $href . '"' . ((!empty($params)) ? ' ' . $params : null) . '>' . $label . '</a>';
	return $html;
}


function htmlTr ($content, $params = null) {
	$html = '<tr' . ((empty($params)) ? null : ' ') . $params . '>' . "\n";
	$html .= $content;
	$html .= '</tr>' . "\n";
	return $html;
}


function htmlTd ($content, $params = null) {
	$html = '<td' . ((empty($params)) ? null : ' ') . $params . '>' . "\n";
	$html .= $content;
	$html .= '</td>' . "\n";
	return $html;
}

?>
